import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/config/app_navigation.dart';
import '../../../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isCheckingAuth = false;
  String _loadingText = 'Loading...';

  @override
  void initState() {
    super.initState();
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.lightGray,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Text animations
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));

    // Fade animation for background elements
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    await _logoController.forward();
    
    // Start text animation after logo
    await Future.delayed(const Duration(milliseconds: 300));
    await _textController.forward();
    
    // Start fade animation
    await Future.delayed(const Duration(milliseconds: 200));
    await _fadeController.forward();
    
    // Wait a bit more and check authentication
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      await _checkAuthenticationAndNavigate();
    }
  }

  Future<void> _checkAuthenticationAndNavigate() async {
    if (!mounted) return;
    
    setState(() {
      _isCheckingAuth = true;
      _loadingText = 'Checking authentication...';
    });

    try {
      // Get auth provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Check if user is logged in
      if (authProvider.isLoggedIn && authProvider.jwtToken != null) {
        setState(() {
          _loadingText = 'Welcome back!';
        });
        
        // Validate the token
        final isTokenValid = await authProvider.validateToken();
        
        if (isTokenValid) {
          // Token is valid, get user profile and navigate to home
          await authProvider.getProfile();
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            _navigateToHome();
          }
        } else {
          // Token is invalid or expired, logout and go to login
          setState(() {
            _loadingText = 'Session expired, please login again';
          });
          
          await Future.delayed(const Duration(milliseconds: 1000));
          await authProvider.logout();
          
          if (mounted) {
            _navigateToLogin();
          }
        }
      } else {
        setState(() {
          _loadingText = 'Ready to start!';
        });
        
        await Future.delayed(const Duration(milliseconds: 800));
        
        if (mounted) {
          _navigateToLogin();
        }
      }
    } catch (e) {
      // If there's any error, go to login screen
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.white,
                  AppTheme.lightGray,
                ],
              ),
            ),
          ),
          
          // Animated background elements
          FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // Top right circle
                Positioned(
                  top: -50,
                  right: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryOrange.withOpacity(0.1),
                    ),
                  ),
                ),
                
                // Bottom left circle
                Positioned(
                  bottom: -80,
                  left: -80,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.secondaryOrange.withOpacity(0.1),
                    ),
                  ),
                ),
                
                // Center small circle
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  right: 50,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryOrange.withOpacity(0.15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo container with shadow and animations
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Opacity(
                        opacity: _logoOpacityAnimation.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryOrange.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Image.asset(
                                'assets/images/logo/logo.png',
                                fit: BoxFit.contain,
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // App name with slide and fade animations
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textOpacityAnimation,
                    child: Column(
                      children: [
                        Text(
                          'TuukaTuu',
                          style: GoogleFonts.poppins(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your One-Stop Shopping Destination',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Loading indicator
                FadeTransition(
                  opacity: _textOpacityAnimation,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isCheckingAuth ? AppTheme.primaryOrange : AppTheme.textTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _loadingText,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _isCheckingAuth ? AppTheme.primaryOrange : AppTheme.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom version info
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2025 TuukaTuu. All rights reserved.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 