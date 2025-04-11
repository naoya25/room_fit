import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../repositories/furniture_repository.dart';
import '../models/furniture_model.dart';
import 'dart:math';

final furnitureListProvider = FutureProvider<List<FurnitureModel>>((ref) async {
  return FurnitureRepository().fetchAllFurnitures();
});

final randomFurnitureQueueProvider = FutureProvider<List<FurnitureModel>>((
  ref,
) async {
  final furnitures = await ref.watch(furnitureListProvider.future);
  final shuffled = List<FurnitureModel>.from(furnitures)..shuffle(Random());
  return shuffled.take(3).toList();
});
