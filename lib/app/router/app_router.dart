import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:range_line/app/router/routes.dart';
import 'package:range_line/app/shell/main_shell.dart';
import 'package:range_line/features/dashboard/dashboard_screen.dart';
import 'package:range_line/features/history/history_screen.dart';
import 'package:range_line/features/quick_log/quick_log_screen.dart';
import 'package:range_line/features/vehicle/vehicle_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _shellNavigatorQuickLogKey = GlobalKey<NavigatorState>(debugLabel: 'quicklog');
final _shellNavigatorHistoryKey = GlobalKey<NavigatorState>(debugLabel: 'history');
final _shellNavigatorVehicleKey = GlobalKey<NavigatorState>(debugLabel: 'vehicle');

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDashboardKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorQuickLogKey,
            routes: [
              GoRoute(
                path: AppRoutes.quickLog,
                builder: (context, state) => const QuickLogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHistoryKey,
            routes: [
              GoRoute(
                path: AppRoutes.history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorVehicleKey,
            routes: [
              GoRoute(
                path: AppRoutes.vehicle,
                builder: (context, state) => const VehicleScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final appRouter = createAppRouter();
