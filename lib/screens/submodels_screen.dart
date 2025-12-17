import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/sub_model.dart';
import '../models/model.dart';
import '../services/sub_model_service.dart';

class SubModelScreen extends StatefulWidget {
  final CarModel model;

  const SubModelScreen({super.key, required this.model});

  @override
  State<SubModelScreen> createState() => _SubModelScreenState();
}

class _SubModelScreenState extends State<SubModelScreen> {
  final SubModelService _subModelService = SubModelService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                final submodels = (snapshot.data ?? [])
                    .where((s) => s.name.toLowerCase().contains(_searchQuery))
                    .toList();
                if (submodels.isEmpty) {
                  return const Center(child: Text('No submodels found.'));
                }
                return ListView.builder(
                  itemCount: submodels.length,
                  itemBuilder: (context, index) {
                    final submodel = submodels[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(submodel.name),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
