import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const Skeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect reduce motion settings
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      return _buildSkeletonContainer(0.3); // Static opacity
    }

    return FadeTransition(
      opacity: Tween<double>(begin: 0.2, end: 0.6).animate(_controller),
      child: _buildSkeletonContainer(1.0),
    );
  }

  Widget _buildSkeletonContainer(double opacity) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(opacity * 0.5),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
    );
  }
}
