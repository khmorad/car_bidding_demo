import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../models/model.dart';
import '../models/bid.dart';
import '../services/bid_service.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../models/sub_model.dart';

// Import new widgets
import '../widgets/models/model_detail_app_bar.dart';
import '../widgets/models/highest_bid_card.dart';
import '../widgets/models/bid_history_list.dart';
import '../widgets/models/place_bid_section.dart';

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
              // AppBar is now full width (not inside Center/ConstrainedBox)
              ModelDetailAppBar(
                submodelName: widget.submodel.name,
                onBack: () => context.pop(),
              ),
              // Content
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: StreamBuilder<List<BidModel>>(
                      stream: _bidService.streamBidsForSubModel(
                        widget.submodel.id,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading bids: ${snapshot.error}',
                            ),
                          );
                        }

                        final bids = snapshot.data ?? [];
                        final highestBid = bids.isNotEmpty
                            ? bids.first.amount
                            : 0.0;

                        return Column(
                          children: [
                            // Highest Bid Card
                            HighestBidCard(highestBid: highestBid),
                            // Bid History Header & List
                            BidHistoryList(bids: bids),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Place Bid Section: full width background, constrained input/button
              Container(
                width: double.infinity,
                color: Colors.white,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: PlaceBidSection(
                      submodelId: widget.submodel.id,
                      userId: userId,
                      bidController: _bidController,
                      bidService: _bidService,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
