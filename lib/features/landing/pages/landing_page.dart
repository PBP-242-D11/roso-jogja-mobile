import 'package:flutter/material.dart';
import 'package:roso_jogja_mobile/features/promo/pages/promo_home.dart';

class RosoJogjaLandingPage extends StatelessWidget {
  const RosoJogjaLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Header
              _buildHeader(context),

              // Hero Section
              _buildHeroSection(context),

              // Features Section
              _buildFeaturesSection(context),

              // About Section
              _buildAboutSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 70,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to RosoJogja',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          SizedBox(height: 16),
          Text(
            'Your ultimate guide to exploring Yogyakarta\'s diverse culinary scene. Discover hidden gems, plan your meals, and enjoy authentic local flavors.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Features',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16),
          _buildFeatureCard(
            icon: Icons.restaurant_menu,
            title: 'Restaurant Search',
            description: 'Find the best culinary spots in Jogja with ease',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RosoJogjaLandingPage()),
              );
            },
          ),
          SizedBox(height: 12),
          _buildFeatureCard(
            icon: Icons.shopping_cart,
            title: 'Easy Ordering',
            description: 'Order your favorite meals directly from the app',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RosoJogjaLandingPage()),
              );
            },
          ),
          SizedBox(height: 12),
          _buildFeatureCard(
            icon: Icons.rate_review,
            title: 'Restaurant Reviews',
            description: 'Share and read authentic restaurant experiences',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RosoJogjaLandingPage()),
              );
            },
          ),
          SizedBox(height: 12),
          _buildFeatureCard(
            icon: Icons.discount,
            title: 'Exclusive Promos',
            description:
                'Discover special discounts and offers from local restaurants',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PromoHome()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required void Function() onPressed,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.orange[700],
            size: 40,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: onPressed, // Use the provided callback here
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About RosoJogja',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          SizedBox(height: 16),
          Text(
            'RosoJogja is designed to bring Yogyakarta\'s culinary experiences to your fingertips. Whether you\'re a local or a visitor, our app helps you navigate through the rich flavors and unique dining options the city has to offer. With intuitive features and user-friendly design, RosoJogja makes discovering and enjoying food simpler and more enjoyable.',
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
