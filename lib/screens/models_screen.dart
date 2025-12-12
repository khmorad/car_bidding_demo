import 'package:flutter/material.dart';
import '../services/model_service.dart';
import '../models/model.dart';

class ModelsScreen extends StatelessWidget {
  final String makerId;
  final String makerName;

  ModelsScreen({super.key, required this.makerId, required this.makerName});

  final ModelsService _modelsService = ModelsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$makerName Models')),
      body: StreamBuilder<List<CarModel>>(
        stream: _modelsService.getModelsByMaker(makerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No models found for this maker'));
          }

          final models = snapshot.data!;

          return ListView.builder(
            itemCount: models.length,
            itemBuilder: (context, index) {
              final model = models[index];
              return ListTile(
                title: Text(model.name),
                subtitle: Text('Year: ${model.year}'),
                trailing: const Icon(Icons.arrow_forward_ios),
              );
            },
          );
        },
      ),
    );
  }
}
