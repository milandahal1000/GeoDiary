import 'package:flutter/material.dart';
import 'package:geodiary/routes/app_routes.dart';
import 'package:geodiary/theme/app_theme.dart';

void main() {
  runApp(const GeoDiaryApp());
}

class GeoDiaryApp extends StatelessWidget {
  const GeoDiaryApp({super.key});

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
