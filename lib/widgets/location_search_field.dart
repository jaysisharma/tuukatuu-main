// import 'package:flutter/material.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:google_api_headers/google_api_headers.dart';

// const String kGoogleApiKey = "AIzaSyC4T-nrxWDY5Iblq11Sh3n8dn_s4DvBtU8"; // Replace this

// class LocationSearchField extends StatelessWidget {
//   const LocationSearchField({super.key});

//   Future<void> _handleSearchTap(BuildContext context) async {
//     Prediction? prediction = await PlacesAutocomplete.show(
//       context: context,
//       apiKey: kGoogleApiKey,
//       mode: Mode.overlay, // or Mode.fullscreen
//       language: "en",
//       components: [Component(Component.country, "in")],
//       types: [], // keep empty to show all
//       hint: "Enter Area, Locality or Landmark",
//       // debounce: 500,
//     );

//     if (prediction != null) {
//       final GoogleMapsPlaces _places = GoogleMapsPlaces(
//         apiKey: kGoogleApiKey,
//         apiHeaders: await GoogleApiHeaders().getHeaders(),
//       );

//       final detail = await _places.getDetailsByPlaceId(prediction.placeId!);
//       final address = detail.result.formattedAddress;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Selected: $address")),
//       );

//       // You can now use `address` as needed
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       elevation: 4,
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         onTap: () => _handleSearchTap(context),
//         child: IgnorePointer(
//           child: TextField(
//             decoration: InputDecoration(
//               hintText: "Enter Area, Locality or Landmark",
//               prefixIcon: const Icon(Icons.search),
//               contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
