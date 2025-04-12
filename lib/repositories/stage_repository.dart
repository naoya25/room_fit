import 'package:room_fit/core/utils/grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stage_model.dart';

class StageRepository {
  final _client = Supabase.instance.client;

  Future<List<StageModel>> fetchStages() async {
    final response = await _client.from('stages').select();

    return (response as List).map((json) => StageModel.fromJson(json)).toList();
  }

  Future<StageModel> fetchStageById(String stageId) async {
    final data =
        await _client.from('stages').select().eq('id', stageId).single();

    return StageModel.fromJson(data);
  }

  Future<StageModel> createStage({
    required String name,
    required int height,
    required int width,
    required List<List<bool>> roomGrid,
  }) async {
    final response = await _client.from('stages').insert({
      'name': name,
      'height': height,
      'width': width,
      'room_grid': encodeGrid(roomGrid),
    });

    return StageModel.fromJson(response.data);
  }
}
