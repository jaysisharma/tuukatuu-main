import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
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
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? (isDark ? Colors.red[900] : Colors.red[50])
              : (isDark ? Colors.orange[900] : Colors.orange[50]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive
              ? (isDark ? Colors.red[300] : Colors.red)
              : (iconColor ?? (isDark ? Colors.orange[300] : Colors.orange[700])),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive
              ? (isDark ? Colors.red[300] : Colors.red)
              : theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: isDark ? Colors.grey[400] : Colors.grey),
    );
  }

  Widget _buildSection(List<Widget> children) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: theme.cardColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Colors.orange[900]!.withOpacity(0.3),
                            Colors.orange[800]!.withOpacity(0.1),
                          ]
                        : [
                            Colors.orange[50]!,
                            Colors.orange[100]!.withOpacity(0.5),
                          ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark ? Colors.orange[900] : Colors.orange[100],
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: isDark ? Colors.orange[300] : Colors.white,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.orange[300] : Colors.orange[700],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'John Doe',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+977 9876543210',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('YOUR INFORMATION'),
                _buildSection([
                  _buildProfileOption(
                    title: 'Edit Profile',
                    icon: Icons.person_outline,
                    onTap: () {
                      // TODO: Implement edit profile
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    title: 'Change Password',
                    icon: Icons.lock_outline,
                    onTap: () {
                      // TODO: Implement change password
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    title: 'Addresses',
                    icon: Icons.location_on_outlined,
                    onTap: () {
                      // TODO: Implement addresses
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    title: 'Your Orders',
                    icon: Icons.shopping_bag_outlined,
                    onTap: () {
                      // TODO: Implement orders
                    },
                  ),
                ]),

                _buildSectionTitle('PREFERENCES'),
                _buildSection([
                  _buildProfileOption(
                    title: 'Theme Mode',
                    icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    iconColor: themeProvider.isDarkMode ? Colors.purple[300] : Colors.amber[700],
                    onTap: () {
                      themeProvider.toggleTheme();
                    },
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: isDark ? Colors.purple[300] : Colors.purple[700],
                      inactiveThumbColor: Colors.amber[700],
                    ),
                  ),
                ]),

                _buildSectionTitle('OTHER INFORMATION'),
                _buildSection([
                  _buildProfileOption(
                    title: 'Share the App',
                    icon: Icons.share_outlined,
                    onTap: () {
                      Share.share('Check out TuukaTuu - Your One-Stop Shopping Destination!');
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    title: 'About Us',
                    icon: Icons.info_outline,
                    onTap: () {
                      // TODO: Implement about us
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    title: 'Privacy Policy',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {
                      // TODO: Implement privacy policy
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    title: 'Account Privacy',
                    icon: Icons.security_outlined,
                    onTap: () {
                      // TODO: Implement account privacy
                    },
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(
                    title: 'Terms & Conditions',
                    icon: Icons.description_outlined,
                    onTap: () {
                      // TODO: Implement terms & conditions
                    },
                  ),
                ]),

                const SizedBox(height: 16),
                _buildSection([
                  _buildProfileOption(
                    title: 'Logout',
                    icon: Icons.logout,
                    onTap: _handleLogout,
                    trailing: const SizedBox(),
                    isDestructive: true,
                  ),
                ]),

                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'App Version 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 