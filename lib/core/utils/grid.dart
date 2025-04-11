List<List<bool>> decodeGrid(String flat, int height, int width) {
  final grid = <List<bool>>[];

  for (int row = 0; row < height; row++) {
    final start = row * width;
    final end = start + width;
    final rowValues =
        flat.substring(start, end).split('').map(int.parse).toList();
    grid.add(rowValues.map((e) => e == 1).toList());
  }

  return grid;
}

String encodeGrid(List<List<bool>> grid) {
  return grid.expand((row) => row).map((e) => e ? 1 : 0).join();
}
