import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/sub_model.dart';
import '../models/model.dart';
import '../services/sub_model_service.dart';
import '../services/engine_service.dart';
import '../models/engine.dart';
import '../widgets/engine_info_sheet.dart';

class SubModelScreen extends StatefulWidget {
  final CarModel model;

  const SubModelScreen({super.key, required this.model});

  @override
  State<SubModelScreen> createState() => _SubModelScreenState();
}

class _SubModelScreenState extends State<SubModelScreen> {
  final SubModelService _subModelService = SubModelService();
  final EngineService _engineService = EngineService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEngineInfo(BuildContext context, String submodelId) async {
    print('Querying engine for submodelId: $submodelId');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return FutureBuilder<Engine?>(
          future: _engineService.getEngineBySubmodel(submodelId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const AlertDialog(
                title: Text('Engine Info'),
                content: Text('No engine info found for this submodel.'),
              );
            }
            final engine = snapshot.data!;
            return EngineInfoSheet(engine: engine); // <-- Use the widget here
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.model.name} Submodels'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search submodels...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<SubModel>>(
              stream: _subModelService.getSubModelsByModel(widget.model.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final submodels = (snapshot.data ?? []);
                print(
                  'Loaded submodels: ${submodels.map((s) => s.id).toList()}',
                ); // <-- Add this line
                final filteredSubmodels = submodels
                    .where((s) => s.name.toLowerCase().contains(_searchQuery))
                    .toList();
                if (filteredSubmodels.isEmpty) {
                  return const Center(child: Text('No submodels found.'));
                }
                return ListView.builder(
                  itemCount: filteredSubmodels.length,
                  itemBuilder: (context, index) {
                    final submodel = filteredSubmodels[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(submodel.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.info_outline,
                                color: Colors.blue,
                              ),
                              tooltip: 'Show engine info',
                              onPressed: () =>
                                  _showEngineInfo(context, submodel.id),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        onTap: () {
                          context.push('/model', extra: submodel);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
