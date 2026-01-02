import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/portfolio/add_asset_screen.dart';

void main() {
  runApp(const ProviderScope(child: InvestDashApp()));
}

class InvestDashApp extends StatelessWidget {
  const InvestDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invest Dash',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/add_asset': (context) => const AddAssetScreen(),
      },
    );
  }
}
