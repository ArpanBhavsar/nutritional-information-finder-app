import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', res.user?.toJson().toString() ?? '');
        await prefs.setString('session', res.session?.toJson().toString() ?? '');


        emit(Authenticated(res.session, res.user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<CheckLoginEvent>((event, emit) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('user') && prefs.containsKey('session')) {
        Session? session = Session.fromJson(prefs.getString('session')! as Map<String, dynamic>);
        User? user = User.fromJson(prefs.getString('user')! as Map<String, dynamic>);
        emit(Authenticated(session, user)); // Assuming you can create Authenticated without session/user from shared preferences if needed, or adjust accordingly.
      } else {
        emit(AuthInitial());
      }
    });
  }
}
