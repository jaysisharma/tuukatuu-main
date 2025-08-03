import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  final String label;
  final String address;

  const AddressCard({super.key, required this.label, required this.address});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(label == "Home" ? Icons.home : Icons.work),
      title: Text(label),
      subtitle: Text(address),
      trailing: TextButton(onPressed: () {}, child: const Text("Deliver Here")),
    );
  }
}
