import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/address.dart';
import '../services/api_service.dart';

class LocationProvider with ChangeNotifier {
  final CameraPosition initialPosition = const CameraPosition(
    target: LatLng(28.6139, 77.2090),
    zoom: 14,
  );

  GoogleMapController? _mapController;
  LatLng? selectedPosition;
  List<Address> addresses = [];
  bool isLoading = false;

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void updateMapPosition(CameraPosition position) {
    selectedPosition = position.target;
    notifyListeners();
  }

  Future<void> useCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled || permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      selectedPosition = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(selectedPosition!),
      );
      notifyListeners();
    }
  }

  Future<void> fetchAddresses(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      addresses = await ApiService.getAddresses(token);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> addAddress(String token, Address address) async {
  //   isLoading = true;
  //   notifyListeners();
  //   try {
  //     final newAddress = await ApiService.addAddress(token, address);
  //     addresses.insert(0, newAddress);
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Future<void> updateAddress(String token, Address address) async {
  //   isLoading = true;
  //   notifyListeners();
  //   try {
  //     final updated = await ApiService.updateAddress(token, address);
  //     final idx = addresses.indexWhere((a) => a.id == address.id);
  //     if (idx != -1) addresses[idx] = updated;
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> deleteAddress(String token, String id) async {
    isLoading = true;
    notifyListeners();
    try {
      await ApiService.deleteAddress(token, id);
      addresses.removeWhere((a) => a.id == id);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(String token, String id) async {
    isLoading = true;
    notifyListeners();
    try {
      final updated = await ApiService.setDefaultAddress(token, id);
      final idx = addresses.indexWhere((a) => a.id == id);
      if (idx != -1) addresses[idx] = updated;
      // Optionally, refetch all addresses to update isDefault flags
      await fetchAddresses(token);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
