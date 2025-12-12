import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/makers_service.dart';
import '../models/maker.dart';
import 'models_screen.dart';

class MakersScreen extends StatelessWidget {
  MakersScreen({super.key});

  final MakersService _makersService = MakersService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Makers')),
      body: StreamBuilder<List<Maker>>(
        stream: _makersService.getMakers(),
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
            return const Center(child: Text('No makers found'));
          }

          final makers = snapshot.data!;

          return ListView.builder(
            itemCount: makers.length,
            itemBuilder: (context, index) {
              final maker = makers[index];

              return ListTile(
                title: Text(maker.name),
                subtitle: Text('ID: ${maker.id}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  context.go(
                    '/models/${maker.id}?makerName=${Uri.encodeComponent(maker.name)}',
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
