import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    final supabase = Supabase.instance.client;
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final AuthResponse res = await supabase.auth.signUp(email: event.email, password: event.password);
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
        final AuthResponse res = await supabase.auth.signInWithPassword(email: event.email, password: event.password);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(res.user?.toJson()) ?? '');
        await prefs.setString('session', jsonEncode(res.session?.toJson()) ?? '');

        emit(Authenticated(res.session, res.user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<CheckLoginEvent>((event, emit) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('user') && prefs.containsKey('session')) {
        final sessionJson = prefs.getString('session');
        final userJson = prefs.getString('user');
        Session? session = Session.fromJson(jsonDecode(sessionJson!));
        User? user = User.fromJson(jsonDecode(userJson!));
        emit(Authenticated(session, user)); // Assuming you can create Authenticated without session/user from shared preferences if needed, or adjust accordingly.
      } else {
        emit(AuthInitial());
      }
    });
  }
}
