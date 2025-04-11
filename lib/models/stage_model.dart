import 'package:room_fit/core/utils/grid.dart';

class StageModel {
  final String id;
  final String name;
  final int height;
  final int width;
  final List<List<bool>> roomGrid;

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
      roomGrid: decodeGrid(json['room_grid'], json['height'], json['width']),
    );
  }
}
