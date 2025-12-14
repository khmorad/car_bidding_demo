import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthUnauthenticated());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      final user = await _authService.login(email, password);

      if (user == null) {
        emit(AuthError('Invalid email or password'));
      } else {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }

  Future<void> register(String email, String password) async {
    emit(AuthLoading());

    try {
      final user = await _authService.register(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Registration failed: ${e.toString()}'));
    }
  }

  void logout() {
    emit(AuthUnauthenticated());
  }
}
