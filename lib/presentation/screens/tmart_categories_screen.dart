import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuukatuu/services/api_service.dart';
import 'package:tuukatuu/presentation/widgets/tmart_category_card.dart';

class TMartCategoriesScreen extends StatefulWidget {
  const TMartCategoriesScreen({super.key});

  @override
  State<TMartCategoriesScreen> createState() => _TMartCategoriesScreenState();
}

class _TMartCategoriesScreenState extends State<TMartCategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Swiggy color scheme
  static const Color swiggyOrange = Color(0xFFFC8019);
  static const Color swiggyRed = Color(0xFFE23744);
  static const Color swiggyDark = Color(0xFF1C1C1C);
  static const Color swiggyLight = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await ApiService.get('/tmart/categories');
      
      if (response['success']) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response['data'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response['message'] ?? 'Failed to load categories';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading categories: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: swiggyLight,
      appBar: AppBar(
        backgroundColor: swiggyOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Categories',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/tmart-search', arguments: '');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorWidget()
              : _buildCategoriesGrid(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading categories',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCategories,
            style: ElevatedButton.styleFrom(
              backgroundColor: swiggyOrange,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return TMartCategoryCard(
            category: category,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/tmart-category-products',
                arguments: {
                  'categoryName': category['name'],
                  'categoryDisplayName': category['displayName'],
                },
              );
            },
          );
        },
      ),
    );
  }
} 