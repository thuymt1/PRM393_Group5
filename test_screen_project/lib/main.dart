import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'routes/app_router.dart';

// Theme
import 'widgets/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khoi tao Supabase — chi dung cho Auth + Storage
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // ProviderScope bat buoc de Riverpod hoat dong
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hearth & Horizon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(AppTheme.accentOrange),
      routerConfig: appRouter,
    );
  }
}
