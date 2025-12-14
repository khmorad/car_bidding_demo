import 'package:car_bidding_system/models/model.dart';
import 'package:car_bidding_system/screens/model_detail_screen.dart';
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/makers_screen.dart';
import '../screens/models_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/makers', builder: (context, state) => MakersScreen()),
    GoRoute(
      path: '/models/:makerId',
      builder: (context, state) {
        final makerId = state.pathParameters['makerId']!;
        final makerName = state.uri.queryParameters['makerName'] ?? '';
        return ModelsScreen(makerId: makerId, makerName: makerName);
      },
    ),
    GoRoute(
      path: '/model',
      builder: (context, state) {
        final model = state.extra as CarModel;
        return ModelDetailScreen(model: model);
      },
    ),
  ],
);
