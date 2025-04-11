import 'package:flutter/material.dart';

class GridCell extends StatelessWidget {
  const GridCell({
    super.key,
    required this.size,
    required this.isActive,
    this.border,
    this.color,
    this.onTap,
  });

  final double size;
  final bool isActive;
  final Border? border;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isActive ? (color ?? Colors.white) : Colors.transparent,
          border: border,
        ),
      ),
    );
  }
}
