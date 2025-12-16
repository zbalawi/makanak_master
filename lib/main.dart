import 'package:flutter/material.dart';
import 'package:mkanak_master/presentation/presenters/state/auth_provider.dart';
import 'package:mkanak_master/presentation/presenters/state/order_provider.dart';
import 'package:provider/provider.dart';

import 'core/di.dart';
import 'core/roots/app_roots.dart';
import 'core/roots/app_router.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const MakanakApp());
}

class MakanakApp extends StatelessWidget {
  const MakanakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(create: (_) => OrderProvider(orderRepository)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Makanak MVP',
        theme: AppTheme.light(),
        // ✅ الثيم
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
