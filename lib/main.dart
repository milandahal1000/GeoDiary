import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

import 'package:geodiary/services/authentication_service.dart';
import 'package:geodiary/services/profile_service.dart';
import 'package:geodiary/features/journal/data/memory_repository.dart';
import 'package:geodiary/core/database/database_helper.dart';
import 'package:geodiary/bloc/authentication_bloc.dart';
import 'package:geodiary/bloc/authentication_event.dart';
import 'package:geodiary/bloc/authentication_state.dart';
import 'package:geodiary/features/auth/presentation/pages/login_page.dart';
import 'package:geodiary/routes/app_routes.dart';
import 'package:geodiary/routes/route_names.dart';
import 'package:geodiary/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GeoDiaryApp());
}

class GeoDiaryApp extends StatelessWidget {
  const GeoDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FirebaseAuth>(create: (_) => FirebaseAuth.instance),
        RepositoryProvider<GoogleSignIn>(create: (_) => GoogleSignIn.instance),
        RepositoryProvider<FirebaseFirestore>(
          create: (_) => FirebaseFirestore.instance,
        ),
        RepositoryProvider<ProfileService>(
          create: (_) => ProfileService(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
          ),
        ),
        RepositoryProvider<MemoryRepository>(
          create: (_) => MemoryRepository(DatabaseHelper.instance()),
        ),
      ],
      child: RepositoryProvider(
        create: (context) => AuthenticationService(
          firebaseAuth: RepositoryProvider.of<FirebaseAuth>(context),
          googleSignIn: RepositoryProvider.of<GoogleSignIn>(context),
          profileService: RepositoryProvider.of<ProfileService>(context),
        ),
        child: BlocProvider(
          create: (context) => AuthenticationBloc(
            RepositoryProvider.of<AuthenticationService>(context),
          )..add(AuthenticationCheckStatus()),
          child: const GeoDiaryAppView(),
        ),
      ),
    );
  }
}

class GeoDiaryAppView extends StatelessWidget {
  const GeoDiaryAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationAuthenticated) {
          return const _GeoDiaryAuthenticatedApp();
        }
        if (state is AuthenticationUnauthenticated ||
            state is AuthenticationInitial ||
            state is AuthenticationChecking ||
            state is AuthenticationSigningIn ||
            state is AuthenticationSigningOut ||
            state is AuthenticationError) {
          return const _GeoDiaryUnauthenticatedApp();
        }
        return const _GeoDiaryUnauthenticatedApp(); // fallback
      },
    );
  }
}

class _GeoDiaryAuthenticatedApp extends StatelessWidget {
  const _GeoDiaryAuthenticatedApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoDiary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      routes: AppRoutes.getRoutes(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // Handle unknown routes gracefully
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Route not found')),
          body: const Center(child: Text('The requested route was not found.')),
        ),
      ),
    );
  }
}

class _GeoDiaryUnauthenticatedApp extends StatelessWidget {
  const _GeoDiaryUnauthenticatedApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoDiary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      initialRoute: RouteNames.login,
      routes: AppRoutes.getRoutes(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      // Handle unknown routes gracefully
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}
