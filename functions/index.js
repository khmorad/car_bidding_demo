/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
// force redeploy
// Import necessary modules

//run firebase deploy --only functions to deploy only functions
//new
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const csv = require("csv-parser");
const { Storage } = require("@google-cloud/storage");

admin.initializeApp();
const db = admin.firestore();
const storage = new Storage();

// FIXED — this is the correct bucket getter:
const bucket = admin.storage().bucket();
exports.importCars = functions.https.onRequest(async (req, res) => {
  try {
    const makers = [];
    const models = [];
    const submodels = [];
    const engines = [];
    // Read makes CSV
    await new Promise((resolve, reject) => {
      bucket
        .file("csv/makes-sample.csv")
        .createReadStream()
        .pipe(csv())
        .on("data", (row) => makers.push(row))
        .on("end", resolve)
        .on("error", reject);
    });

    // Read models CSV
    await new Promise((resolve, reject) => {
      bucket
        .file("csv/models-sample.csv")
        .createReadStream()
        .pipe(csv())
        .on("data", (row) => models.push(row))
        .on("end", resolve)
        .on("error", reject);
    });
    // Read submodels CSV
    await new Promise((resolve, reject) => {
      bucket
        .file("csv/submodels-sample.csv")
        .createReadStream()
        .pipe(csv())
        .on("data", (row) => submodels.push(row))
        .on("end", resolve)
        .on("error", reject);
    });
    // Read engines CSV
    await new Promise((resolve, reject) => {
      bucket
        .file("csv/engines-sample.csv")
        .createReadStream()
        .pipe(csv())
        .on("data", (row) => engines.push(row))
        .on("end", resolve)
        .on("error", reject);
    });
    // Write makers to Firestore
    const makerBatch = db.batch();
    makers.forEach((m) => {
      const ref = db.collection("makers").doc(String(m["Make Id"]));
      makerBatch.set(
        ref,
        {
          id: m["Make Id"],
          name: m["Make Name"],
        },
        { merge: true }
      );
    });
    await makerBatch.commit();

    // Write models to Firestore
    const modelBatch = db.batch();
    models.forEach((m) => {
      const ref = db.collection("models").doc(String(m["Model Id"]));
      modelBatch.set(
        ref,
        {
          id: m["Model Id"],
          name: m["Model Name"],
          make_id: m["Make Id"],
          year: m["Model Year"],
        },
        { merge: true }
      );
    });
    await modelBatch.commit();

    // Write submodels to Firestore
    const submodelBatch = db.batch();
    submodels.forEach((s) => {
      const ref = db
        .collection("models")
        .doc(String(s["Model Id"]))
        .collection("submodels")
        .doc(String(s["Submodel Id"]));

      // Build data object, omitting undefined, null, or empty string fields
      const rawData = {
        id: s["Submodel Id"],
        name: s["Submodel Name"],
        model_id: s["Model Id"],
        year: s["Year"] ? String(s["Year"]).trim() : undefined,
        trim: s["Trim"] ? String(s["Trim"]).trim() : undefined,
      };
      // Remove fields that are undefined, null, or empty string
      const filteredData = Object.fromEntries(
        Object.entries(rawData).filter(
          ([_, v]) => v !== undefined && v !== null && v !== ""
        )
      );
      submodelBatch.set(ref, filteredData, { merge: true });
    });
    await submodelBatch.commit();

    // Write engines to Firestore (chunked)
    const engineOps = [];

    engines.forEach((e) => {
      const ref = db
        .collection("models")
        .doc(String(e["Model Id"]))
        .collection("engines")
        .doc(String(e["Engine Id"]));

      const rawData = {
        id: e["Engine Id"],
        model_id: e["Model Id"],
        submodel_id: e["Submodel Id"],
        trim_id: e["Trim Id"],
        year: e["Model Year"],

        engine_type: e["Engine Type"],
        fuel_type: e["Engine Fuel Type"],

        cylinders: e["Engine Cylinders"]
          ? Number(e["Engine Cylinders"])
          : undefined,
        size: e["Engine Size"] ? Number(e["Engine Size"]) : undefined,
        horsepower_hp: e["Engine Horsepower Hp"]
          ? Number(e["Engine Horsepower Hp"])
          : undefined,
        horsepower_rpm: e["Engine Horsepower Rpm"]
          ? Number(e["Engine Horsepower Rpm"])
          : undefined,
        torque_ft_lbs: e["Engine Torque Ft Lbs"]
          ? Number(e["Engine Torque Ft Lbs"])
          : undefined,
        torque_rpm: e["Engine Torque Rpm"]
          ? Number(e["Engine Torque Rpm"])
          : undefined,
        valves: e["Engine Valves"] ? Number(e["Engine Valves"]) : undefined,

        valve_timing: e["Engine Valve Timing"],
        cam_type: e["Engine Cam Type"],
        drive_type: e["Engine Drive Type"],
        transmission: e["Engine Transmission"],
      };

      const filteredData = Object.fromEntries(
        Object.entries(rawData).filter(
          ([_, v]) =>
            v !== undefined &&
            v !== null &&
            v !== "" &&
            !(typeof v === "number" && Number.isNaN(v))
        )
      );

      engineOps.push({ ref, data: filteredData });
    });

    await commitInChunks(engineOps);

    return res.status(200).send("Import complete!");
  } catch (error) {
    console.error(error);
    return res.status(500).send("Import failed.");
  }
});

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// Helper to commit Firestore writes in chunks (max 500 per batch, use 450 for safety)
async function commitInChunks(ops, chunkSize = 450) {
  for (let i = 0; i < ops.length; i += chunkSize) {
    const batch = db.batch();
    ops.slice(i, i + chunkSize).forEach(({ ref, data }) => {
      batch.set(ref, data, { merge: true });
    });
    await batch.commit();
  }
}
