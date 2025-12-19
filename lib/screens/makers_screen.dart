import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../services/makers_service.dart';
import '../models/maker.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
// Add imports for widgets
import '../widgets/makers/makers_app_bar.dart';
import '../widgets/makers/makers_search_bar.dart';
import '../widgets/makers/makerts_card.dart';

class MakersScreen extends StatefulWidget {
  const MakersScreen({super.key});

  @override
  State<MakersScreen> createState() => _MakersScreenState();
}

class _MakersScreenState extends State<MakersScreen> {
  final MakersService _makersService = MakersService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getCrossAxisCount(double width) {
    if (width < 600) return 2; // phones
    if (width < 900) return 3; // tablets/small desktop
    if (width < 1200) return 4;
    return 5; // large desktop
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.purple.shade50,
                Colors.pink.shade50,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // AppBar stays full width
                const MakersAppBar(),
                const SizedBox(height: 16),
                // Center and constrain search bar
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700), // <-- Increased max width here
                    child: MakersSearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = _getCrossAxisCount(width);

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: StreamBuilder<List<Maker>>(
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
                                      Icon(
                                        Icons.error_outline,
                                        size: 64,
                                        color: Colors.red.shade300,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Oops! Something went wrong',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Error: ${snapshot.error}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No makers found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final makers = snapshot.data!
                                  .where((maker) => maker.name
                                      .toLowerCase()
                                      .contains(_searchQuery))
                                  .toList();

                              if (makers.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No results found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 1.1,
                                    ),
                                itemCount: makers.length,
                                itemBuilder: (context, index) {
                                  final maker = makers[index];
                                  return MakerCard(maker: maker);
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Remove _MakerCard class (now replaced by MakerCard widget)
