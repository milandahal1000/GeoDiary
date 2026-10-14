import 'package:flutter/material.dart';
import 'package:geodiary/features/journal/presentation/pages/journal_page.dart';
import 'package:geodiary/features/map/presentation/pages/map_page.dart';
import 'package:geodiary/routes/route_names.dart';

/// Defines the application routes and navigation.
class AppRoutes {
  /// Returns the route table for the application.
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      RouteNames.journal: (_) => const JournalPage(),
      RouteNames.map: (_) => const MapPage(),
      // AddMemory, MemoryDetails, EditMemory will be added later.
    };
  }

  /// Handles route generation for named routes.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // If you need to handle dynamic routes or transitions, implement here.
    // For now, we rely on the static getRoutes map.
    return null;
  }
}
