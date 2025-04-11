import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../repositories/furniture_repository.dart';
import '../../models/furniture_model.dart';
import 'dart:math';
import 'dart:collection';

/// 常に5つの家具を保持する
final continuousFurnitureQueueProvider = StateNotifierProvider<
  ContinuousFurnitureQueueNotifier,
  Queue<FurnitureModel>?
>((ref) {
  return ContinuousFurnitureQueueNotifier();
});

class ContinuousFurnitureQueueNotifier
    extends StateNotifier<Queue<FurnitureModel>?> {
  ContinuousFurnitureQueueNotifier() : super(null) {
    _init();
  }

  Future<void> _init() async {
    final furnitures = await FurnitureRepository().fetchAllFurnitures();
    final random = Random();
    final queue = Queue<FurnitureModel>();
    while (queue.length < 5) {
      queue.add(furnitures[random.nextInt(furnitures.length)]);
    }
    state = queue;
  }

  void removeFirst() {
    if (state != null && state!.isNotEmpty) {
      state!.removeFirst();
      _addRandomFurniture();
    }
  }

  Future<void> _addRandomFurniture() async {
    final furnitures = await FurnitureRepository().fetchAllFurnitures();
    final random = Random();
    while (state!.length < 5) {
      state!.add(furnitures[random.nextInt(furnitures.length)]);
    }
  }
}
