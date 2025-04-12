import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:room_fit/pages/stage_creation/components/mode_toggle_button.dart';
import 'package:room_fit/pages/stage_creation/components/selection_painter.dart';
import 'package:room_fit/pages/stage_creation/stage_creation_page.dart';

/// 部屋のグリッド編集UI
class RoomGridInput extends HookWidget {
  const RoomGridInput({
    super.key,
    required this.width,
    required this.height,
    required this.calculatedHeight,
    required this.roomGrid,
  });

  final int width;
  final int height;
  final double calculatedHeight;
  final ValueNotifier<List<List<bool>>> roomGrid;

  @override
  Widget build(BuildContext context) {
    final isDragging = useState(false);
    final mode = useState(GridMode.add);
    final startPosition = useState<Offset?>(null);
    final currentPosition = useState<Offset?>(null);

    void updateGridInRange(Offset start, Offset end) {
      final cellSize = calculatedHeight / height;
      final startX = (start.dx / cellSize).floor().clamp(0, width - 1);
      final startY = (start.dy / cellSize).floor().clamp(0, height - 1);
      final endX = (end.dx / cellSize).floor().clamp(0, width - 1);
      final endY = (end.dy / cellSize).floor().clamp(0, height - 1);

      final minX = startX < endX ? startX : endX;
      final maxX = startX < endX ? endX : startX;
      final minY = startY < endY ? startY : endY;
      final maxY = startY < endY ? endY : startY;

      final newValue = (mode.value == GridMode.add);
      final newGrid =
          roomGrid.value.map((row) => List<bool>.from(row)).toList();

      for (var y = minY; y <= maxY; y++) {
        for (var x = minX; x <= maxX; x++) {
          newGrid[y][x] = newValue;
        }
      }

      roomGrid.value = newGrid;
    }

    return Column(
      children: [
        ModeToggleButton(currentMode: mode),
        const SizedBox(height: 16),
        Text('部屋の配置をタップまたはドラッグして設定してください'),
        Text('横幅: $width  高さ: $height'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: calculatedHeight,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: GestureDetector(
            onPanStart: (details) {
              isDragging.value = true;
              final cellSize = calculatedHeight / height;
              final startX = (details.localPosition.dx / cellSize).floor();
              final startY = (details.localPosition.dy / cellSize).floor();
              startPosition.value = Offset(
                startX * cellSize,
                startY * cellSize,
              );
              currentPosition.value = startPosition.value;
            },
            onPanUpdate: (details) {
              if (!isDragging.value) return;
              final cellSize = calculatedHeight / height;
              final currentX = (details.localPosition.dx / cellSize).floor();
              final currentY = (details.localPosition.dy / cellSize).floor();
              currentPosition.value = Offset(
                currentX * cellSize,
                currentY * cellSize,
              );
            },
            onPanEnd: (_) {
              if (startPosition.value != null &&
                  currentPosition.value != null) {
                updateGridInRange(startPosition.value!, currentPosition.value!);
              }
              isDragging.value = false;
              startPosition.value = null;
              currentPosition.value = null;
            },
            child: Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: width,
                  ),
                  itemCount: width * height,
                  itemBuilder: (context, index) {
                    final x = index % width;
                    final y = index ~/ width;
                    final isActive = roomGrid.value[y][x];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        color: isActive ? Colors.blue.shade200 : Colors.white,
                      ),
                    );
                  },
                ),
                if (isDragging.value &&
                    startPosition.value != null &&
                    currentPosition.value != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: SelectionPainter(
                        start: startPosition.value!,
                        end: currentPosition.value!,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
