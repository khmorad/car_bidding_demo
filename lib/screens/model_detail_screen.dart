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
            /// LIVE BIDS - Single source of truth
            Expanded(
              child: StreamBuilder<List<BidModel>>(
                stream: _bidService.streamBidsForModel(widget.model.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error loading bids: ${snapshot.error}'),
                    );
                  }

                  // Derive all state from stream
                  final bids = snapshot.data ?? [];
                  final highestBid = bids.isNotEmpty ? bids.first.amount : 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Colors.deepPurple.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Highest Bid:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${highestBid.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bid History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: bids.isEmpty
                            ? const Center(
                                child: Text('No bids yet. Be the first!'),
                              )
                            : ListView.builder(
                                itemCount: bids.length,
                                itemBuilder: (context, index) {
                                  final bid = bids[index];
                                  final isHighest = index == 0;

                                  return Card(
                                    color: isHighest
                                        ? Colors.green.shade50
                                        : null,
                                    child: ListTile(
                                      leading: Icon(
                                        isHighest
                                            ? Icons.emoji_events
                                            : Icons.monetization_on,
                                        color: isHighest
                                            ? Colors.amber
                                            : Colors.grey,
                                      ),
                                      title: Text(
                                        '\$${bid.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: isHighest
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${bid.createdAt.toLocal().toString().substring(0, 19)}',
                                      ),
                                      trailing: isHighest
                                          ? const Chip(
                                              label: Text('Leading'),
                                              backgroundColor: Colors.green,
                                              labelStyle: TextStyle(
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
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

            /// PLACE BID with validation
            const Divider(height: 32),
            StreamBuilder<List<BidModel>>(
              stream: _bidService.streamBidsForModel(widget.model.id),
              builder: (context, snapshot) {
                final currentHighestBid = (snapshot.data?.isNotEmpty ?? false)
                    ? snapshot.data!.first.amount
                    : 0.0;

                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _bidController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Enter bid amount',
                          hintText:
                              'Minimum: \$${(currentHighestBid + 1).toStringAsFixed(2)}',
                          border: const OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final amount = double.tryParse(
                          _bidController.text.trim(),
                        );

                        // Validation before write
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid amount'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (amount <= currentHighestBid) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Bid must be higher than \$${currentHighestBid.toStringAsFixed(2)}',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          // Write to Firestore
                          await _bidService.placeBid(
                            modelId: widget.model.id,
                            userId: userId,
                            amount: amount,
                          );

                          _bidController.clear();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bid placed successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to place bid: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.gavel),
                      label: const Text('Place Bid'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
