import 'package:flutter/material.dart';
import 'package:roso_jogja_mobile/shared/widgets/left_drawer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About RosoJogja',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[700],
        elevation: 0,
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Logo and Header with horizontal layout
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange[700]!,
                    Colors.orange[500]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RosoJogja',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your Ultimate Jogja Food Guide',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // App Description Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('About the App'),
                  const SizedBox(height: 12),
                  _buildContentText(
                    'RosoJogja is your digital companion for exploring the rich culinary landscape of Yogyakarta. Our app helps food enthusiasts discover authentic local restaurants, traditional delicacies, and hidden gems across the city.',
                  ),
                  const SizedBox(height: 8),
                  _buildContentText(
                    'Whether you\'re a tourist planning your food adventure or a local looking for new dining spots, RosoJogja provides you with detailed information, reviews, and recommendations to enhance your culinary journey.',
                  ),

                  const SizedBox(height: 32),

                  // Team Section
                  _buildSectionTitle('Meet Team PBP-D11'),
                  const SizedBox(height: 12),
                  _buildContentText(
                    'We are a passionate team of students from the University of Indonesia, dedicated to making Yogyakarta\'s culinary scene more accessible to everyone.',
                  ),
                  const SizedBox(height: 24),

                  // Team Members
                  _buildTeamMemberCard(
                    'Akhdan Taufiq Syofyan',
                    '2306152475',
                    'Responsible for developing the Cart and Order features.',
                  ),
                  _buildTeamMemberCard(
                    'Fadhli Raihan Ardiansyah',
                    '2306207594',
                    'Responsible for developing the Review and Rating features.',
                  ),
                  _buildTeamMemberCard(
                    'Makarim Zufar Prambudyo',
                    '2306241751',
                    'Responsible for developing the Wishlist feature.',
                  ),
                  _buildTeamMemberCard(
                    'Nadia Rahmadina Aristawati ',
                    '2306207972',
                    'Responsible for developing the Promo and Discount features.',
                  ),
                  _buildTeamMemberCard(
                    'Yudayana Arif Prasojo',
                    '2306215160',
                    'Responsible for developing the Restaurant and Food features, managing infrastructure and deployment, and leading the team.',
                  ),

                  // Version Info
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildContentText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildTeamMemberCard(String name, String role, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange[100],
                child: Text(
                  name[0], // First letter of name
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
