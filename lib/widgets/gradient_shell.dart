import 'package:flutter/material.dart';

class GradientShell extends StatelessWidget {
  const GradientShell({
    super.key,
    required this.child,
    this.safeAreaTop = true,
  });

  final Widget child;
  final bool safeAreaTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07111F), Color(0xFF0C1A2B), Color(0xFF13243A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(top: safeAreaTop, bottom: false, child: child),
    );
  }
}
