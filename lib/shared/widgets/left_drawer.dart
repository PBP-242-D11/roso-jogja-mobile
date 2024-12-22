import 'package:flutter/material.dart';
import "package:go_router/go_router.dart";
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/models/user.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(context),

            // User Profile Section
            if (user != null) _buildLoggedInUserTile(context, user),

            // Login Prompt for Non-Logged In Users
            if (!authProvider.isLoggedIn) _buildLoginTile(context),

            const Divider(thickness: 1, indent: 16, endIndent: 16),

            // Navigation Sections
            _buildNavigationSection(context, authProvider),

            const Divider(thickness: 1, indent: 16, endIndent: 16),

            // App Information and Additional Options
            _buildAdditionalOptionsSection(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange[700]!,
            Colors.orange[500]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 80,
            width: 80,
          ),
          const SizedBox(height: 12),
          Text(
            "Roso Jogja",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.1,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black26,
                  offset: Offset(1.0, 1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInUserTile(BuildContext context, User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Hero(
            tag: 'profile_picture',
            child: user.profilePicture == null
                ? CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.orange[700],
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      '${AppConfig.apiUrl}${user.profilePicture}',
                    ),
                  ),
          ),
          title: Text(
            user.username,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            user.address,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(
            Icons.login,
            color: Colors.orange[700],
            size: 30,
          ),
          title: const Text(
            'Log In to RosoJogja',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Discover more features',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.orange[700],
            size: 20,
          ),
          onTap: () => context.push('/login'),
        ),
      ),
    );
  }

  Widget _buildNavigationSection(
      BuildContext context, AuthProvider authProvider) {
    final isRestaurantOwner =
        authProvider.user != null && authProvider.user!.role == "R";

    final isGuest = !authProvider.isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Navigation',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.home_outlined,
          title: 'Home',
          onTap: () => context.go(authProvider.isLoggedIn ? "/home" : "/"),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.restaurant_menu_outlined,
          title: 'Restaurants',
          onTap: () => context.go("/restaurant"),
        ),
        if (!isGuest)
          _buildDrawerItem(
            context,
            icon: Icons.discount,
            title: 'Promos',
            onTap: () => context.go("/promo"),
          ),
        if (!isGuest && !isRestaurantOwner)
          _buildDrawerItem(
            context,
            icon: Icons.shopping_cart,
            title: 'Cart',
            onTap: () => context.go("/cart"),
          ),
        if (!isGuest && !isRestaurantOwner)
          _buildDrawerItem(
            context,
            icon: Icons.history,
            title: 'Orders',
            onTap: () => context.go("/order_history"),
          ),
        if (!isGuest && !isRestaurantOwner)
          _buildDrawerItem(
            context,
            icon: Icons.favorite_border,
            title: 'Wishlist',
            onTap: () => context.go('/wishlist'),
          ),
      ],
    );
  }

  Widget _buildAdditionalOptionsSection(
      BuildContext context, AuthProvider authProvider) {
    final isGuest = !authProvider.isLoggedIn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'More',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildDrawerItem(
          context,
          icon: Icons.info_outline,
          title: 'The Team',
          onTap: () => context.go('/about'),
        ),
        if (!isGuest)
          _buildDrawerItem(
            context,
            icon: Icons.logout_outlined,
            title: 'Logout',
            onTap: () => _handleLogout(context, authProvider),
          ),
      ],
    );
  }

  Future<void> _handleLogout(
      BuildContext context, AuthProvider authProvider) async {
    final response = await authProvider.logout(
      '${AppConfig.apiUrl}/mobile_logout/',
    );
    final message = response["message"];

    if (context.mounted) {
      if (response['status']) {
        final uname = response["username"];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$message. Sampai jumpa, $uname."),
            backgroundColor: Colors.orange[700],
          ),
        );
        context.go('/');
      }
    }
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.orange[700],
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hoverColor: Color.fromRGBO(255, 165, 0, 0.1),
    );
  }
}
