import 'package:flutter/material.dart';

class CustomGridDisplay extends StatelessWidget {
  const CustomGridDisplay({
    super.key,
    required this.grid,
    required this.width,
    required this.height,
    this.cellSize = 10,
  });

  final List<List<int>> grid;
  final int width;
  final int height;
  final int cellSize;

  Border? _getBorder(int x, int y) {
    if (grid[y][x] == 0) return null;

    final directions = [
      [0, -1],
      [0, 1],
      [-1, 0],
      [1, 0],
    ];

    BorderSide? top;
    BorderSide? bottom;
    BorderSide? left;
    BorderSide? right;

    for (var dir in directions) {
      final newX = x + dir[0];
      final newY = y + dir[1];

      final isBoundary =
          newX < 0 ||
          newX >= width ||
          newY < 0 ||
          newY >= height ||
          grid[newY][newX] == 0;

      if (isBoundary) {
        if (dir[0] == 0 && dir[1] == -1) {
          top = BorderSide(color: Colors.black, width: 1);
        }
        if (dir[0] == 0 && dir[1] == 1) {
          bottom = BorderSide(color: Colors.black, width: 1);
        }
        if (dir[0] == -1 && dir[1] == 0) {
          left = BorderSide(color: Colors.black, width: 1);
        }
        if (dir[0] == 1 && dir[1] == 0) {
          right = BorderSide(color: Colors.black, width: 1);
        }
      }
    }

    if (top == null && bottom == null && left == null && right == null) {
      return null;
    }

    return Border(
      top: top ?? BorderSide.none,
      bottom: bottom ?? BorderSide.none,
      left: left ?? BorderSide.none,
      right: right ?? BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: SizedBox(
        width: width * cellSize.toDouble(),
        height: height * cellSize.toDouble(),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: width,
          ),
          physics: NeverScrollableScrollPhysics(),
          itemCount: height * width,
          itemBuilder: (context, index) {
            final x = index % width;
            final y = index ~/ width;
            final cellValue = grid[y][x];

            return Container(
              width: cellSize.toDouble(),
              height: cellSize.toDouble(),
              decoration: BoxDecoration(
                color: cellValue == 1 ? Colors.white : Colors.transparent,
                border: _getBorder(x, y),
              ),
            );
          },
        ),
      ),
    );
  }
}
