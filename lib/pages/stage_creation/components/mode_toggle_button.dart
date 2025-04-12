import 'package:flutter/material.dart';
import 'package:room_fit/pages/stage_creation/stage_creation_page.dart';

/// 追加／削除の切り替えボタン
class ModeToggleButton extends StatelessWidget {
  const ModeToggleButton({super.key, required this.currentMode});

  final ValueNotifier<GridMode> currentMode;

  Widget _buildButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final mode in GridMode.values)
          _buildButton(
            label: mode.label,
            isSelected: currentMode.value == mode,
            onTap: () => currentMode.value = mode,
          ),
      ],
    );
  }
}
