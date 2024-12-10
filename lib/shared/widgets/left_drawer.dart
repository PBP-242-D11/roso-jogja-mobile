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
          DrawerHeader(
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                )
              ],
            ),
          ),
          if (authProvider.isLoggedIn)
            // Logged-in User Section
            ListTile(
              leading: user?.profilePicture == null
                  ? CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user!.username[
                            0], // Use the first letter of the user's name
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                          '${AppConfig.apiUrl}${user!.profilePicture!}'),
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
            ),
          if (!authProvider.isLoggedIn)
            ListTile(
              leading: Icon(
                Icons.login,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Log In',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => context.push('/login'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          const Divider(),
          // Motivational Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Ayo makan-makan!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16),
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
              onTap: () async {
                final response = await authProvider.cookieRequest.logout(
                  '${AppConfig.apiUrl}/mobile_logout/',
                );
                String message = response["message"];
                if (context.mounted) {
                  if (response['status']) {
                    String uname = response["username"];
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("$message. Sampai jumpa, $uname."),
                    ));
                    context.go('/');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
    );
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
