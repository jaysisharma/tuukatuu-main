import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:tuukatuu/presentation/screens/profile/addresses_page.dart';
import 'package:tuukatuu/presentation/screens/profile/change_password_page.dart';
import 'package:tuukatuu/presentation/screens/profile/edit_profile_page.dart';
import 'package:tuukatuu/presentation/screens/profile/notification_settings_page.dart';
import 'package:tuukatuu/providers/theme_provider.dart';
import '../auth/login_screen.dart';
import 'package:tuukatuu/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn && authProvider.profile == null) {
      _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.getProfile();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    bool isDestructive = false,
    String? subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDestructive 
                    ? Colors.red[50] 
                    : (iconColor?.withOpacity(0.1) ?? Colors.orange[50]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDestructive 
                    ? Colors.red[600] 
                    : (iconColor ?? Colors.orange[700]),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDestructive 
                          ? Colors.red[600] 
                          : Colors.grey[800],
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) 
                trailing
              else if (!isDestructive)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 80),
      height: 1,
      color: Colors.grey[100],
    );
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = authProvider.profile;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
       
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.orange[400]!,
                              Colors.orange[600]!,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_loading) ...[
                          Container(
                            width: 120,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ] else if (_error != null) ...[
                          Text(
                            'Error loading profile',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ] else if (profile == null) ...[
                          Text(
                            'No profile data',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ] else ...[
                          Text(
                            profile['name'] ?? 'Unknown User',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile['email'] ?? 'No email',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile['phone'] ?? 'No phone',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(
                            name: profile?['name'] ?? '',
                            phone: profile?['phone'] ?? '',
                          ),
                        ),
                      );
                      if (result == true) {
                        await authProvider.getProfile();
                        setState(() {});
                      }
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions Section
            _buildSectionTitle('Quick Actions'),
            _buildSection([
              _buildProfileOption(
                title: 'Your Orders',
                subtitle: 'View past and current orders',
                icon: Icons.receipt_long_outlined,
                iconColor: Colors.blue[600],
                onTap: () {
                  // TODO: Implement orders
                },
              ),
              _buildDivider(),
              _buildProfileOption(
                title: 'Addresses',
                subtitle: 'Manage delivery addresses',
                icon: Icons.location_on_outlined,
                iconColor: Colors.green[600],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddressesPage()),
                  );
                },
              ),
              _buildDivider(),
              _buildProfileOption(
                title: 'Favorites',
                subtitle: 'Your favorite restaurants & stores',
                icon: Icons.favorite_outline,
                iconColor: Colors.red[600],
                onTap: () async {
                  await Navigator.pushNamed(context, '/favorites');
                },
              ),
              _buildDivider(),
              _buildProfileOption(
                title: 'Payment Methods',
                subtitle: 'Cards, wallets & more',
                icon: Icons.payment_outlined,
                iconColor: Colors.purple[600],
                onTap: () {
                  // TODO: Implement payment methods
                },
              ),
            ]),

            // Account Section
            _buildSectionTitle('Account'),
            _buildSection([
              _buildProfileOption(
                title: 'Change Password',
                subtitle: 'Update your password',
                icon: Icons.lock_outline,
                iconColor: Colors.orange[600],
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                  );
                },
              ),
              _buildDivider(),
              _buildProfileOption(
                title: 'Notifications',
                subtitle: 'Push, email & SMS preferences',
                icon: Icons.notifications_outlined,
                iconColor: Colors.blue[600],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsPage(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildProfileOption(
                title: 'Dark Mode',
                subtitle: themeProvider.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
                icon: themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                iconColor: themeProvider.isDarkMode ? Colors.amber[600] : Colors.indigo[600],
                onTap: () {
                  themeProvider.toggleTheme();
                },
                trailing: Switch.adaptive(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: Colors.orange[600],
                ),
              ),
            ]),

            // More Section
            _buildSectionTitle('More'),
            _buildSection([
              _buildProfileOption(
                title: 'Share TuukaTuu',
                subtitle: 'Invite friends and family',
                icon: Icons.share_outlined,
                iconColor: Colors.green[600],
                onTap: () {
                  Share.share('Check out TuukaTuu - Your One-Stop Shopping Destination! 🛒✨');
                },
              ),
              _buildDivider(),
              _buildProfileOption(
                title: 'Rate us',
                subtitle: 'Tell others what you think',
                icon: Icons.star_outline,
                iconColor: Colors.amber[600],
                onTap: () {
                  // TODO: Implement rating
                },
              ),
              _buildDivider(),
              _buildProfileOption(
                title: 'Help & Support',
                subtitle: 'Get help or contact us',
                icon: Icons.help_outline,
                iconColor: Colors.blue[600],
                onTap: () {
                  // TODO: Implement help & support
                },
              ),
              _buildDivider(),
              _buildProfileOption(
                title: 'About TuukaTuu',
                subtitle: 'App info, terms & privacy',
                icon: Icons.info_outline,
                iconColor: Colors.grey[600],
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ]),

            const SizedBox(height: 24),
            
            // Logout Section
            _buildSection([
              _buildProfileOption(
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                icon: Icons.logout,
                onTap: _handleLogout,
                isDestructive: true,
              ),
            ]),

            const SizedBox(height: 32),
            
            // App Version
            Center(
              child: Column(
                children: [
                  Text(
                    'TuukaTuu',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[400]!, Colors.orange[600]!],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'About TuukaTuu',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your one-stop shopping destination for groceries, restaurants, and daily essentials.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildAboutItem('Privacy Policy', () {}),
            _buildAboutItem('Terms of Service', () {}),
            _buildAboutItem('Contact Us', () {}),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.inter(
                color: Colors.orange[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.blue[600],
                decoration: TextDecoration.underline,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.open_in_new,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
} 