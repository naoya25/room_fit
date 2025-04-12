import 'package:flutter/material.dart';

/// 幅・高さ入力用Widget
class GridSizeInput extends StatelessWidget {
  const GridSizeInput({
    super.key,
    required this.widthController,
    required this.heightController,
    required this.widthError,
    required this.heightError,
  });

  final TextEditingController widthController;
  final TextEditingController heightController;
  final String? widthError;
  final String? heightError;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 横幅
        Expanded(
          child: TextField(
            controller: widthController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '横幅',
              border: const OutlineInputBorder(),
              errorText: widthError,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 高さ
        Expanded(
          child: TextField(
            controller: heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '高さ',
              border: const OutlineInputBorder(),
              errorText: heightError,
            ),
          ),
        ),
      ],
    );
  }
}
