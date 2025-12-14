import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../models/model.dart';
import '../models/bid.dart';
import '../services/bid_service.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class ModelDetailScreen extends StatefulWidget {
  final CarModel model;

  const ModelDetailScreen({super.key, required this.model});

  @override
  State<ModelDetailScreen> createState() => _ModelDetailScreenState();
}

class _ModelDetailScreenState extends State<ModelDetailScreen> {
  final BidService _bidService = BidService();
  final TextEditingController _bidController = TextEditingController();

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    final userId = authState.user.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// LIVE BIDS
            Expanded(
              child: StreamBuilder<List<BidModel>>(
                stream: _bidService.streamBidsForModel(widget.model.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final bids = snapshot.data ?? [];
                  final highestBid = bids.isNotEmpty ? bids.first.amount : 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Highest Bid: \$${highestBid.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Recent Bids',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: bids.length,
                          itemBuilder: (context, index) {
                            final bid = bids[index];
                            return ListTile(
                              title: Text('\$${bid.amount.toStringAsFixed(2)}'),
                              subtitle: Text(
                                bid.createdAt.toLocal().toString(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            /// PLACE BID
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bidController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Enter bid amount',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(_bidController.text.trim());

                    if (amount == null || amount <= 0) {
                      return;
                    }

                    await _bidService.placeBid(
                      modelId: widget.model.id,
                      userId: userId,
                      amount: amount,
                    );

                    _bidController.clear();
                  },
                  child: const Text('Place Bid'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
