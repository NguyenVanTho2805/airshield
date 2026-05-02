import 'package:flutter/material.dart';

/// Dashboard Loading Widget
///
/// Uses a single AnimationController shared across all shimmer cells
/// to avoid the performance cost of N independent controllers.
class DashboardLoadingWidget extends StatefulWidget {
  const DashboardLoadingWidget({super.key});

  @override
  State<DashboardLoadingWidget> createState() => _DashboardLoadingWidgetState();
}

class _DashboardLoadingWidgetState extends State<DashboardLoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cell(height: 20, width: 150),
              const SizedBox(height: 24),
              _cell(height: 200, width: double.infinity),
              const SizedBox(height: 24),
              _cell(height: 20, width: 100),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _cell(height: 80)),
                const SizedBox(width: 12),
                Expanded(child: _cell(height: 80)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _cell(height: 80)),
                const SizedBox(width: 12),
                Expanded(child: _cell(height: 80)),
              ]),
              const SizedBox(height: 24),
              _cell(height: 80, width: double.infinity),
            ],
          ),
        );
      },
    );
  }

  Widget _cell({required double height, double? width}) {
    final v = _shimmer.value;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFF16213E),
            Color(0xFF1F2B47),
            Color(0xFF16213E),
          ],
          stops: [
            (v - 0.3).clamp(0.0, 1.0),
            v.clamp(0.0, 1.0),
            (v + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}
