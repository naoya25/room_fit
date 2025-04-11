List<List<int>> decodeGrid(String flat, int height, int width) {
  final grid = <List<int>>[];

  for (int row = 0; row < height; row++) {
    final start = row * width;
    final end = start + width;
    final rowValues =
        flat.substring(start, end).split('').map(int.parse).toList();
    grid.add(rowValues);
  }

  return grid;
}

String encodeGrid(List<List<int>> grid) {
  return grid.expand((row) => row).join();
}
