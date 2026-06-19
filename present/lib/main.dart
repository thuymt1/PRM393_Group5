import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'views/before_optimization/product_list_view_bad.dart';
import 'views/after_optimization/product_list_view_good.dart';

void main() {
  runApp(const PerformanceApp());
}

class PerformanceApp extends StatefulWidget {
  const PerformanceApp({super.key});

  @override
  State<PerformanceApp> createState() => _PerformanceAppState();
}

class _PerformanceAppState extends State<PerformanceApp> {
  bool _showPerformanceOverlay = false;
  bool _showRepaintRainbow = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: _showPerformanceOverlay,
      showSemanticsDebugger: false,
      debugShowMaterialGrid: false,
      title: 'Flutter Performance MVVM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: MainMenu(
        showPerformanceOverlay: _showPerformanceOverlay,
        showRepaintRainbow: _showRepaintRainbow,
        onToggleOverlay: () => setState(() => _showPerformanceOverlay = !_showPerformanceOverlay),
        onToggleRainbow: () => setState(() {
          _showRepaintRainbow = !_showRepaintRainbow;
          debugRepaintRainbowEnabled = _showRepaintRainbow;
        }),
      ),
    );
  }
}

class MainMenu extends StatelessWidget {
  final bool showPerformanceOverlay;
  final bool showRepaintRainbow;
  final VoidCallback onToggleOverlay;
  final VoidCallback onToggleRainbow;

  const MainMenu({
    super.key,
    required this.showPerformanceOverlay,
    required this.showRepaintRainbow,
    required this.onToggleOverlay,
    required this.onToggleRainbow,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tối ưu hiệu suất Flutter'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.speed, color: showPerformanceOverlay ? Colors.orange : null),
            onPressed: onToggleOverlay,
            tooltip: 'Bật biểu đồ hiệu suất',
          ),
          IconButton(
            icon: Icon(Icons.color_lens, color: showRepaintRainbow ? Colors.orange : null),
            onPressed: onToggleRainbow,
            tooltip: 'Bật cầu vồng repaint',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Demo MVVM & Optimization',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _MenuCard(
              title: '1. TRƯỚC TỐI ƯU (BAD)',
              subtitle: 'Logic trong Build, setState toàn cục, không tách Widget.',
              color: Colors.red,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductListViewBad()),
              ),
            ),
            const SizedBox(height: 20),
            _MenuCard(
              title: '2. SAU TỐI ƯU (GOOD)',
              subtitle: 'Mô hình MVVM, const Widget, tách Logic khỏi UI.',
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductListViewGood()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, color: color),
        onTap: onTap,
      ),
    );
  }
}
