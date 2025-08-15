import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/app_config.dart';
import '../../core/config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../screens/main_screen.dart';

class OrderPlacedScreen extends StatefulWidget {
  final String orderId;
  const OrderPlacedScreen({super.key, required this.orderId});

  @override
  State<OrderPlacedScreen> createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _loading = true;
  String? _error;
  Timer? _timer;
  String? _orderStatus;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _steps = [
    {
      'status': 'pending',
      'label': 'Order Received',
      'icon': Icons.receipt_long,
      'description': 'We\'ve received your order',
    },
    {
      'status': 'accepted',
      'label': 'Order Confirmed',
      'icon': Icons.check_circle,
      'description': 'Your order has been confirmed',
    },
    {
      'status': 'preparing',
      'label': 'Preparing',
      'icon': Icons.restaurant,
      'description': 'Your items are being prepared',
    },
    {
      'status': 'on_the_way',
      'label': 'On the Way',
      'icon': Icons.delivery_dining,
      'description': 'Your order is on its way',
    },
    {
      'status': 'delivered',
      'label': 'Delivered',
      'icon': Icons.home,
      'description': 'Enjoy your order!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchStatus();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchStatus());
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    if (!mounted) return;
    
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final headers = <String, String>{};
      if (authProvider.jwtToken != null) {
        headers['Authorization'] = 'Bearer ${authProvider.jwtToken}';
      }
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/orders/${widget.orderId}'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final order = json.decode(response.body);
        _orderStatus = order['status'];
        final idx = _steps.indexWhere((step) => step['status'] == _orderStatus);
        
        if (mounted) {
          setState(() {
            _currentStep = idx >= 0 ? idx : 0;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Failed to fetch order status';
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Network error. Please check your connection.';
          _loading = false;
        });
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  void _navigateToOrders() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen(initialTabIndex: 2)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Header
                  _buildHeader(),
                  
                  const SizedBox(height: 32),
                  
                  // Main Content
                  Expanded(
                    child: _loading
                        ? _buildLoadingState()
                        : _error != null
                            ? _buildErrorState()
                            : _buildSuccessState(),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Order Status',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48), // Balance the back button
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sync,
                    size: 40,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Checking order status...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 40,
              color: AppTheme.errorRed,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Oops!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Something went wrong',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            onPressed: _fetchStatus,
            text: 'Try Again',
            icon: Icons.refresh,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      children: [
        // Success Icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.successGreen.withOpacity(0.1),
                      AppTheme.successGreen.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: AppTheme.successGreen,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Success Message
        Text(
          'Order Placed Successfully!',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Your order #${widget.orderId} has been confirmed',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 40),
        
        // Order Progress
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _buildProgressSteps(),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Action Buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildProgressSteps() {
    return ListView.builder(
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        final step = _steps[index];
        final isActive = index <= _currentStep;
        final isCompleted = index < _currentStep;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              // Step Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? AppTheme.successGreen 
                      : isActive 
                          ? AppTheme.primaryOrange 
                          : AppTheme.borderColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step['icon'],
                  color: AppTheme.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Step Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['label'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isCompleted 
                            ? AppTheme.successGreen 
                            : isActive 
                                ? AppTheme.textPrimary 
                                : AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status Indicator
              if (isActive && !isCompleted)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          onPressed: _navigateToOrders,
          text: 'View All Orders',
          icon: Icons.shopping_bag,
          isPrimary: true,
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          onPressed: _navigateToHome,
          text: 'Back to Home',
          icon: Icons.home,
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppTheme.primaryOrange : AppTheme.white,
          foregroundColor: isPrimary ? AppTheme.white : AppTheme.primaryOrange,
          elevation: 0,
          shadowColor: isPrimary 
              ? AppTheme.primaryOrange.withOpacity(0.3)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isPrimary 
                ? BorderSide.none
                : const BorderSide(color: AppTheme.primaryOrange),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 