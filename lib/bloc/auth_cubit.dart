import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authService) : super(AuthInitial());

  final AuthService _authService;

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final user = await _authService.login(email, password);

    if (user == null) {
      emit(AuthError('Invalid credentials'));
    } else {
      emit(AuthAuthenticated(user));
    }
  }

  Future<void> register(String email, String password) async {
    emit(AuthLoading());
    final user = await _authService.register(email, password);
    emit(AuthAuthenticated(user));
  }

  void logout() {
    emit(AuthUnauthenticated());
  }
}
