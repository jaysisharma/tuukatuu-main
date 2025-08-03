import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real favourite shops from provider
    final favouriteShops = [
      {
        'name': 'T-Mart Express',
        'description': 'Get your essentials delivered in 15-30 minutes',
        'image': 'https://images.unsplash.com/photo-1604719312566-8912e9227c6a',
        'rating': 4.8,
      },
      {
        'name': 'Wine Gallery',
        'description': 'Premium wines and spirits delivered to your door',
        'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3',
        'rating': 4.5,
      },
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Favourite Shops')),
      body: favouriteShops.isEmpty
          ? const Center(child: Text('No favourite shops yet.'))
          : ListView.builder(
              itemCount: favouriteShops.length,
              itemBuilder: (context, index) {
                final shop = favouriteShops[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(shop['image'] as String),
                  ),
                  title: Text(shop['name'] as String),
                  subtitle: Text(shop['description'] as String),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      Text(shop['rating'].toString()),
                      StatefulBuilder(
                        builder: (context, setState) {
                          bool isFavourite = true;
                          return IconButton(
                            icon: Icon(
                              isFavourite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                isFavourite = !isFavourite;
                                // TODO: Call provider/backend to update favourite status
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Navigate to store details
                  },
                );
              },
            ),
    );
  }
} 