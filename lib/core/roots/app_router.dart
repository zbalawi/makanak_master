import 'package:flutter/material.dart';

import '../../presentation/presenters/screens/client_home_screen.dart';
import '../../presentation/presenters/screens/login_screen.dart';
import '../../presentation/presenters/screens/new_order_screen.dart';
import '../../presentation/presenters/screens/register_screen.dart';
import '../../presentation/presenters/screens/settings_screen.dart';
import '../../presentation/presenters/screens/splash_screen.dart';
import '../../presentation/presenters/screens/technician_home_screen.dart';


import 'app_roots.dart';


class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.clientHome: {
        final args = settings.arguments as ClientHomeArgs?;
        if (args == null) return _error('ClientHomeArgs is required');
        return MaterialPageRoute(
          builder: (_) => ClientHomeScreen(clientName: args.clientName),
        );
      }

      case AppRoutes.technicianHome: {
        final args = settings.arguments as TechnicianHomeArgs?;
        if (args == null) return _error('TechnicianHomeArgs is required');
        return MaterialPageRoute(
          builder: (_) => TechnicianHomeScreen(technicianName: args.technicianName),
        );
      }

      case AppRoutes.newOrder: {
        final args = settings.arguments as NewOrderArgs?;
        if (args == null) return _error('NewOrderArgs is required');
        return MaterialPageRoute(
          builder: (_) => NewOrderScreen(clientName: args.clientName),
        );
      }

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return _error('Route not found: ${settings.name}');
    }
  }

  static MaterialPageRoute _error(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Navigation Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}

class ClientHomeArgs {
  final String clientName;
  ClientHomeArgs({required this.clientName});
}

class TechnicianHomeArgs {
  final String technicianName;
  TechnicianHomeArgs({required this.technicianName});
}

class NewOrderArgs {
  final String clientName;
  NewOrderArgs({required this.clientName});
}
