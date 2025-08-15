import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cached_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final authProvider = context.read<AuthProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    
    if (authProvider.isLoggedIn && authProvider.jwtToken != null) {
      await favoritesProvider.loadFavorites(authProvider.jwtToken!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.orange,
              tabs: const [
                Tab(text: 'Restaurants'),
                Tab(text: 'Stores'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRestaurantsTab(),
                _buildStoresTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        if (favoritesProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final restaurants = favoritesProvider.restaurantFavorites;
        
        if (restaurants.isEmpty) {
          return _buildEmptyState('restaurants');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return _buildFavoriteItem(restaurant, 'restaurant');
          },
        );
      },
    );
  }

  Widget _buildStoresTab() {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        if (favoritesProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final stores = favoritesProvider.storeFavorites;
        
        if (stores.isEmpty) {
          return _buildEmptyState('stores');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];
            return _buildFavoriteItem(store, 'store');
          },
        );
      },
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> item, String type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 60,
            height: 60,
            child: CachedImage(
              imageUrl: item['itemImage'] ?? 'assets/images/products/bread.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          item['itemName'] ?? 'Unknown',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              type == 'restaurant' ? 'Restaurant' : 'Store',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (item['rating'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.orange[600], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    item['rating'].toString(),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 24,
          ),
          onPressed: () => _removeFromFavorites(item['itemId']),
        ),
        onTap: () {
          // TODO: Navigate to restaurant/store details
        },
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'restaurants' ? Icons.restaurant : Icons.store,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No favorite ${type == 'restaurants' ? 'restaurants' : 'stores'} yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding your favorite ${type == 'restaurants' ? 'restaurants' : 'stores'} to see them here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _removeFromFavorites(String itemId) async {
    final authProvider = context.read<AuthProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    
    if (authProvider.isLoggedIn && authProvider.jwtToken != null) {
      final success = await favoritesProvider.removeFromFavorites(
        token: authProvider.jwtToken!,
        itemId: itemId,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
