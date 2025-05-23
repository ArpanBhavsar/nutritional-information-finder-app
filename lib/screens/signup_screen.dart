import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _showPasswordRequirements = false;

  double _passwordStrength = 0.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUp() {
    context.read<AuthBloc>().add(
      SignUpEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _updatePasswordStrength(String password) {
    // Reset strength
    _passwordStrength = 0.0;

    if (password.isNotEmpty) {
      // Add points for length
      if (password.length >= 8) _passwordStrength += 0.25;
      if (password.length >= 12) _passwordStrength += 0.25;

      // Add points for character types
      if (RegExp(r'[A-Z]').hasMatch(password)) _passwordStrength += 0.125;
      if (RegExp(r'[a-z]').hasMatch(password)) _passwordStrength += 0.125;
      if (RegExp(r'[0-9]').hasMatch(password)) _passwordStrength += 0.125;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password))
        _passwordStrength += 0.125;

      // Ensure strength is capped at 1.0
      _passwordStrength = _passwordStrength.clamp(0.0, 1.0);
    }

    setState(() {});
  }

  Color _getPasswordStrengthColor() {
    if (_passwordStrength < 0.25) {
      return Colors.red;
    } else if (_passwordStrength < 0.5) {
      return Colors.orange;
    } else if (_passwordStrength < 0.75) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  String _getPasswordStrengthLabel() {
    if (_passwordStrength == 0) {
      return ''; // No label when no input
    } else if (_passwordStrength < 0.25) {
      return 'Weak';
    } else if (_passwordStrength < 0.5) {
      return 'Medium';
    } else if (_passwordStrength < 0.75) {
      return 'Strong';
    } else {
      return 'Very Strong';
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (kDebugMode) {
            print(state.toString());
          }
          // Suggested code may be subject to a license. Learn more: ~LicenseLog:4181069863.
          if (state is Authenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return SafeArea(child: Center(child: _signUpForm(state, context)));
          }
        },
      ),
    );
  }

  Widget _signUpForm(AuthState authState, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Sign Up',
            style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40.0),
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _showPasswordRequirements
                                ? Icons.info
                                : Icons.info_outline,
                            color:
                                _showPasswordRequirements
                                    ? Theme.of(context).primaryColor
                                    : null,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPasswordRequirements =
                                  !_showPasswordRequirements;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  onChanged: _updatePasswordStrength,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 8.0),
                LinearProgressIndicator(
                  value: _passwordStrength,
                  backgroundColor: Colors.grey[300],
                  color: _getPasswordStrengthColor(),
                  minHeight: 5.0,
                ),
                const SizedBox(height: 4.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _getPasswordStrengthLabel(),
                    style: TextStyle(
                      color: _getPasswordStrengthColor(),
                      fontSize: 12.0,
                    ),
                  ),
                ),
                if (_showPasswordRequirements)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(top: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password must contain:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4.0),
                        Text('- Minimum 8 characters'),
                        Text('- At least one uppercase letter'),
                        Text('- At least one lowercase letter'),
                        Text('- At least one number'),
                        Text('- At least one special character'),
                      ],
                    ),
                  ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process signup
                      // For now, just navigate to LoginScreen
                      _onSignUp();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Already have account?"),
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
