import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geodiary/bloc/authentication_bloc.dart';
import 'package:geodiary/bloc/authentication_event.dart';
import 'package:geodiary/bloc/authentication_state.dart';

/// Login page for GeoDiary application with Google Sign-In.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              if (state is AuthenticationError) {
                _showErrorDialog(context, state.message);
              }
            },
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo/Icon
                    const Icon(
                      Icons.map,
                      size: 80,
                      color: Color(0xFF287D65), // Primary Green
                    ),
                    const SizedBox(height: 16),

                    // App Name
                    const Text(
                      'GeoDiary',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF287D65), // Primary Green
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tagline
                    const Text(
                      'Your memories, mapped.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF205B4C), // Deep Green
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Continue with Google Button
                    _buildGoogleSignInButton(context),
                    const SizedBox(height: 24),

                    // Version or additional info
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        final bool isLoading =
            state is AuthenticationSigningIn ||
            state is AuthenticationSigningOut;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.g_mobiledata),
            label: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Continue with Google'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: Color(0xFFE1EEE7), // Soft Sage
                  width: 1,
                ),
              ),
              elevation: 2,
            ),
            onPressed: isLoading
                ? null
                : () {
                    context.read<AuthenticationBloc>().add(
                      AuthenticationSignInWithGoogle(),
                    );
                  },
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
