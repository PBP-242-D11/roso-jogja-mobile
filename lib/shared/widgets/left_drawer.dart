import 'package:flutter/material.dart';
import "package:go_router/go_router.dart";
import 'package:provider/provider.dart';
import 'package:roso_jogja_mobile/features/auth/provider/auth_provider.dart';
import 'package:roso_jogja_mobile/shared/config/app_config.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          if (authProvider.isLoggedIn) _buildLoggedInUserTile(context, user!),
          if (!authProvider.isLoggedIn) _buildLoginTile(context),
          const Divider(),
          _buildMotivationalText(),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home',
            onTap: () => context.go(authProvider.isLoggedIn ? "/home" : "/"),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.restaurant,
            title: 'Restaurants',
            onTap: () => context.go("/restaurant"),
          ),
          if (authProvider.isLoggedIn)
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => _handleLogout(context, authProvider),
            ),
        ],
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
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 70,
          ),
          const SizedBox(height: 16),
          Text(
            "Roso Jogja Mobile",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInUserTile(BuildContext context, dynamic user) {
    return ListTile(
      leading: user.profilePicture == null
          ? CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.username[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                '${AppConfig.apiUrl}${user.profilePicture}',
              ),
            ),
      title: Text(
        user.username,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        user.address,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildLoginTile(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.login,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text(
        'Log In',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () => context.push('/login'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildMotivationalText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Ayo makan-makan!',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _handleLogout(
      BuildContext context, AuthProvider authProvider) async {
    final response = await authProvider.cookieRequest.logout(
      '${AppConfig.apiUrl}/mobile_logout/',
    );
    final message = response["message"];

    if (context.mounted) {
      final snackBar = SnackBar(content: Text(message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      if (response['status']) {
        final uname = response["username"];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("$message. Sampai jumpa, $uname."),
        ));
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
        color: Theme.of(context).colorScheme.primary,
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
      hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
    );
  }
}
