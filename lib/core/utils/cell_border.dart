import 'package:flutter/material.dart';

Border? getBorder(int x, int y, List<List<bool>> grid, int colNum, int rowNum) {
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
      } else if (dir[0] == 0 && dir[1] == 1) {
        bottom = BorderSide(color: Colors.black, width: 1);
      } else if (dir[0] == -1 && dir[1] == 0) {
        left = BorderSide(color: Colors.black, width: 1);
      } else if (dir[0] == 1 && dir[1] == 0) {
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
