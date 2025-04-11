import 'package:flutter/material.dart';
import 'grid_cell.dart';

class CustomGridView extends StatelessWidget {
  const CustomGridView({
    super.key,
    required this.grid,
    required this.colNum,
    required this.rowNum,
    required this.cellSize,
    this.onCellTap,
    this.cellColor,
  });

  final List<List<bool>> grid;
  final int colNum;
  final int rowNum;
  final double cellSize;
  final Function(int x, int y)? onCellTap;
  final Color? cellColor;

  Border? _getBorder(int x, int y) {
    if (!grid[y][x]) return null;

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
          newX >= colNum ||
          newY < 0 ||
          newY >= rowNum ||
          !grid[newY][newX];

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
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colNum,
      ),
      physics: NeverScrollableScrollPhysics(),
      itemCount: rowNum * colNum,
      itemBuilder: (context, index) {
        final x = index % colNum;
        final y = index ~/ colNum;
        final cellValue = grid[y][x];

        return GridCell(
          size: cellSize,
          isActive: cellValue,
          border: _getBorder(x, y),
          color: cellColor,
          onTap: () => onCellTap?.call(x, y),
        );
      },
    );
  }
}
