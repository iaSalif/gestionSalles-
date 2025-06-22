import 'package:flutter/material.dart';
import '../routes/routes.dart';
import '../widgets/auth_state_listener.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Salles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: AppRoutes.chefScolariteDashboard,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,

      builder: (context, child) {
        return AuthStateListener(
          autoRedirect: true,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
