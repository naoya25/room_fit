class StageModel {
  final String id;
  final String name;
  final int height;
  final int width;
  final List<List<int>> roomGrid;

  StageModel({
    required this.id,
    required this.name,
    required this.height,
    required this.width,
    required this.roomGrid,
  });

  factory StageModel.fromJson(Map<String, dynamic> json) {
    return StageModel(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      width: json['width'],
      roomGrid: decodeRoomGrid(
        json['room_grid'],
        json['height'],
        json['width'],
      ),
    );
  }
}

List<List<int>> decodeRoomGrid(String flat, int height, int width) {
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

String encodeRoomGrid(List<List<int>> grid) {
  return grid.expand((row) => row).join();
}
