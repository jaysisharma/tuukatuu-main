import '../models/store.dart';
import 'api_service.dart';

class StoreService {
  static Future<Store?> getStoreById(String storeId) async {
    try {
      final data = await ApiService.get('/vendors/$storeId');
      return Store.fromJson(data);
    } catch (e) {
      print('Error fetching store: $e');
      return null;
    }
  }

  static Future<List<Store>> getStores() async {
    try {
      final data = await ApiService.get('/vendors');
      final stores = (data['vendors'] as List)
          .map((json) => Store.fromJson(json))
          .toList();
      return stores;
    } catch (e) {
      print('Error fetching stores: $e');
      return [];
    }
  }

  static Future<List<Store>> getFeaturedStores() async {
    try {
      final data = await ApiService.get('/vendors?featured=true');
      final stores = (data['vendors'] as List)
          .map((json) => Store.fromJson(json))
          .toList();
      return stores;
    } catch (e) {
      print('Error fetching featured stores: $e');
      return [];
    }
  }

  static Future<List<Store>> getStoresByCategory(String category) async {
    try {
      final data = await ApiService.get('/vendors?category=${Uri.encodeComponent(category)}');
      final stores = (data['vendors'] as List)
          .map((json) => Store.fromJson(json))
          .toList();
      return stores;
    } catch (e) {
      print('Error fetching stores by category: $e');
      return [];
    }
  }
} 