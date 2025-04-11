import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../repositories/stage_repository.dart';
import '../models/stage_model.dart';

final stageListProvider = FutureProvider<List<StageModel>>((ref) async {
  return StageRepository().fetchStages();
});

final stageDetailProvider = FutureProvider.family<StageModel, String>((
  ref,
  id,
) async {
  return StageRepository().fetchStageById(id);
});
