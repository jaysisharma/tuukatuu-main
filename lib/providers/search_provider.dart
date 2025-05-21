import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<String> _selectedCategories = [];
  String _sortBy = 'Popular'; // Popular, Rating, Delivery Time
  double _minPrice = 0;
  double _maxPrice = 1000;
  bool _onlyAvailable = false;
  bool _freeDelivery = false;

  String get query => _query;
  List<String> get selectedCategories => _selectedCategories;
  String get sortBy => _sortBy;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get onlyAvailable => _onlyAvailable;
  bool get freeDelivery => _freeDelivery;

  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }

  void toggleOnlyAvailable() {
    _onlyAvailable = !_onlyAvailable;
    notifyListeners();
  }

  void toggleFreeDelivery() {
    _freeDelivery = !_freeDelivery;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategories = [];
    _sortBy = 'Popular';
    _minPrice = 0;
    _maxPrice = 1000;
    _onlyAvailable = false;
    _freeDelivery = false;
    notifyListeners();
  }

  bool get hasActiveFilters {
    return _selectedCategories.isNotEmpty ||
        _sortBy != 'Popular' ||
        _minPrice > 0 ||
        _maxPrice < 1000 ||
        _onlyAvailable ||
        _freeDelivery;
  }
} 