import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:room_fit/pages/stage_creation/components/mode_toggle_button.dart';
import 'package:room_fit/pages/stage_creation/stage_creation_page.dart';

/// 部屋のグリッド編集UI
class RoomGridInput extends HookWidget {
  const RoomGridInput({
    super.key,
    required this.columnCount,
    required this.rowCount,
    required this.cellSize,
    required this.roomGrid,
  });

  final int columnCount;
  final int rowCount;
  final int cellSize;
  final ValueNotifier<List<List<bool>>> roomGrid;

  @override
  Widget build(BuildContext context) {
    final isDragging = useState(false);
    final mode = useState(GridMode.add);
    final startX = useState<int?>(null);
    final startY = useState<int?>(null);
    final currentX = useState<int?>(null);
    final currentY = useState<int?>(null);

    void updateGridInRange(int startX, int startY, int endX, int endY) {
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
        Text('横幅: $columnCount  高さ: $rowCount'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: cellSize * rowCount.toDouble(),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: GestureDetector(
            onPanStart: (details) {
              isDragging.value = true;
              startX.value = (details.localPosition.dx ~/ cellSize).clamp(
                0,
                columnCount,
              );
              startY.value = (details.localPosition.dy ~/ cellSize).clamp(
                0,
                rowCount,
              );

              currentX.value = startX.value;
              currentY.value = startY.value;
            },
            onPanUpdate: (details) {
              if (!isDragging.value) return;
              currentX.value = (details.localPosition.dx ~/ cellSize).clamp(
                0,
                columnCount,
              );
              currentY.value = (details.localPosition.dy ~/ cellSize).clamp(
                0,
                rowCount,
              );
            },
            onPanEnd: (_) {
              if (startX.value != null &&
                  startY.value != null &&
                  currentX.value != null &&
                  currentY.value != null) {
                updateGridInRange(
                  startX.value!,
                  startY.value!,
                  currentX.value!,
                  currentY.value!,
                );
              }
              isDragging.value = false;
              startX.value = null;
              currentX.value = null;
            },
            child: Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                  ),
                  itemCount: columnCount * rowCount,
                  itemBuilder: (context, index) {
                    final x = index % columnCount;
                    final y = index ~/ columnCount;
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
                    startX.value != null &&
                    startY.value != null &&
                    currentX.value != null &&
                    currentY.value != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SelectionPainter(
                        startX: startX.value!,
                        startY: startY.value!,
                        endX: currentX.value!,
                        endY: currentY.value!,
                        cellSize: cellSize.toDouble(),
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

class _SelectionPainter extends CustomPainter {
  _SelectionPainter({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.cellSize,
  });

  final int startX;
  final int startY;
  final int endX;
  final int endY;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.blue.withAlpha(100)
          ..style = PaintingStyle.fill;

    final rect = Rect.fromPoints(
      Offset(startX * cellSize, startY * cellSize),
      Offset((endX + 1) * cellSize, (endY + 1) * cellSize),
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_SelectionPainter oldDelegate) {
    return startX != oldDelegate.startX ||
        startY != oldDelegate.startY ||
        endX != oldDelegate.endX ||
        endY != oldDelegate.endY;
  }
}
