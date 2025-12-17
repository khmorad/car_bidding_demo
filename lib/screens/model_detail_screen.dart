import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../models/model.dart';
import '../models/bid.dart';
import '../services/bid_service.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../models/sub_model.dart';

class ModelDetailScreen extends StatefulWidget {
  final SubModel submodel;

  const ModelDetailScreen({super.key, required this.submodel});

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.submodel.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          // Optionally display modelId or other info
                        ],
                      ),
                    ),
                    // ...existing code...
                  ],
                ),
              ),
              // Content
              Expanded(
                child: StreamBuilder<List<BidModel>>(
                  stream: _bidService.streamBidsForSubModel(widget.submodel.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading bids: ${snapshot.error}'),
                      );
                    }

                    final bids = snapshot.data ?? [];
                    final highestBid = bids.isNotEmpty
                        ? bids.first.amount
                        : 0.0;

                    return Column(
                      children: [
                        // Highest Bid Card
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 28,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Current Highest Bid',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '\$${highestBid.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Bid History Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.history,
                                color: Color(0xFF667eea),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Bid History',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF667eea,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${bids.length} bid${bids.length != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF667eea),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Bid List
                        Expanded(
                          child: bids.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.gavel,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No bids yet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Be the first to place a bid!',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: bids.length,
                                  itemBuilder: (context, index) {
                                    final bid = bids[index];
                                    final isHighest = index == 0;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: isHighest
                                            ? const Color(
                                                0xFF667eea,
                                              ).withOpacity(0.1)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isHighest
                                              ? const Color(
                                                  0xFF667eea,
                                                ).withOpacity(0.3)
                                              : Colors.grey.shade200,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: isHighest
                                                ? const LinearGradient(
                                                    colors: [
                                                      Color(0xFF667eea),
                                                      Color(0xFF764ba2),
                                                    ],
                                                  )
                                                : null,
                                            color: isHighest
                                                ? null
                                                : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            isHighest
                                                ? Icons.emoji_events
                                                : Icons.monetization_on,
                                            color: isHighest
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                            size: 24,
                                          ),
                                        ),
                                        title: Text(
                                          '\$${bid.amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: isHighest
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            fontSize: 18,
                                            color: const Color(0xFF2D3748),
                                          ),
                                        ),
                                        subtitle: Text(
                                          bid.createdAt
                                              .toLocal()
                                              .toString()
                                              .substring(0, 19),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        trailing: isHighest
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          Color(0xFF667eea),
                                                          Color(0xFF764ba2),
                                                        ],
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'Leading',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
              // Place Bid Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: StreamBuilder<List<BidModel>>(
                  stream: _bidService.streamBidsForSubModel(widget.submodel.id),
                  builder: (context, snapshot) {
                    final currentHighestBid =
                        (snapshot.data?.isNotEmpty ?? false)
                        ? snapshot.data!.first.amount
                        : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _bidController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter your bid',
                            hintText:
                                'Min: \$${(currentHighestBid + 1).toStringAsFixed(2)}',
                            prefixIcon: const Icon(
                              Icons.attach_money,
                              color: Color(0xFF667eea),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF667eea),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final amount = double.tryParse(
                              _bidController.text.trim(),
                            );

                            if (amount == null || amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid amount'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
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
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            try {
                              await _bidService.placeBid(
                                submodelId: widget.submodel.id,
                                userId: userId,
                                amount: amount,
                              );

                              _bidController.clear();

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Bid placed successfully!'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to place bid: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF667eea),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.gavel, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Place Bid',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
