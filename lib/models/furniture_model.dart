import 'package:room_fit/core/utils/grid.dart';

class FurnitureModel {
  final String id;
  final String name;
  final int height;
  final int width;
  final List<List<int>> grid;

  FurnitureModel({
    required this.id,
    required this.name,
    required this.height,
    required this.width,
    required this.grid,
  });

  factory FurnitureModel.fromJson(Map<String, dynamic> json) {
    return FurnitureModel(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      width: json['width'],
      grid: decodeGrid(json['grid'], json['height'], json['width']),
    );
  }
}
