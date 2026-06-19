import 'package:flutter/material.dart';
import 'views/optimized_list_screen.dart';
import 'views/unoptimized_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Performance Comparison Demo',
      theme: ThemeData(useMaterial3: true),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Hiệu Suất Layout')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCard(
              context,
              title: "1. CHƯA TỐI ƯU",
              subtitle: "2,000 items - Không Builder - Có IntrinsicHeight",
              color: Colors.red.shade400,
              target: const UnoptimizedListScreen(),
            ),
            const SizedBox(height: 20),
            _buildCard(
              context,
              title: "2. ĐÃ TỐI ƯU",
              subtitle: "10,000 items - ListView.builder - Có itemExtent",
              color: Colors.green.shade400,
              target: const OptimizedListScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required Widget target,
  }) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => target)),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
