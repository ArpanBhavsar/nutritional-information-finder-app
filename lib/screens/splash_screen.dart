import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/screens/home_screen.dart';

import '../blocs/auth/auth_bloc.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      context.read<AuthBloc>().add(CheckLoginEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
          if (state is AuthInitial) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          }
        },
        child: Center(child: Image.asset('assets/images/logo.png', width: 250, height: 250)),
      ),
    );
  }
}
