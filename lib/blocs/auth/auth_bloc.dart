import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    final supabase = Supabase.instance.client;
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final AuthResponse res = await supabase.auth.signUp(
          email: event.email,
          password: event.password,
        );
        emit(Authenticated(res.session, res.user));
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
        emit(AuthError(e.toString()));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final AuthResponse res = await supabase.auth.signInWithPassword(
          email: event.email,
          password: event.password,
        );
        emit(Authenticated(res.session, res.user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}
