import 'package:flutter/material.dart';
import 'package:room_fit/core/utils/cell_border.dart';
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
  final int cellSize;
  final Function(int x, int y)? onCellTap;
  final Color? cellColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(rowNum, (y) {
        return Row(
          children: List.generate(colNum, (x) {
            final cellValue = grid[y][x];
            return SizedBox(
              width: cellSize.toDouble(),
              height: cellSize.toDouble(),
              child: GridCell(
                size: cellSize,
                isActive: cellValue,
                border: getBorder(x, y, grid, colNum, rowNum),
                color: cellColor,
                onTap: () => onCellTap?.call(x, y),
              ),
            );
          }),
        );
      }),
    );
  }
}
