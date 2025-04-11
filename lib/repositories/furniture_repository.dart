import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/furniture_model.dart';

class FurnitureRepository {
  final _client = Supabase.instance.client;

  Future<List<FurnitureModel>> fetchAllFurnitures() async {
    final data = await _client.from('furnitures').select();
    return (data as List).map((e) => FurnitureModel.fromJson(e)).toList();
  }
}
