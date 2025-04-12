import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../repositories/stage_repository.dart';
import '../models/stage_model.dart';

final stageListProvider =
    AsyncNotifierProvider<StageListNotifier, List<StageModel>>(() {
      return StageListNotifier();
    });

final stageDetailProvider = FutureProvider.family<StageModel, String>((
  ref,
  id,
) async {
  return StageRepository().fetchStageById(id);
});

class StageListNotifier extends AsyncNotifier<List<StageModel>> {
  @override
  Future<List<StageModel>> build() async {
    return await StageRepository().fetchStages();
  }

  Future<void> createStage({
    required String name,
    required int height,
    required int width,
    required List<List<bool>> roomGrid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newStage = await StageRepository().createStage(
        name: name,
        height: height,
        width: width,
        roomGrid: roomGrid,
      );
      return [...state.value ?? [], newStage];
    });
  }
}
