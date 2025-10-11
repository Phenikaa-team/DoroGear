import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildAdminFeatureCard(
            context,
            icon: Icons.inventory_2,
            title: 'Product Management',
            description: 'Add, Edit, Delete Products.',
            color: Colors.blueAccent,
            onTap: () {
              // Product CRUD page (Add/Edit/Delete products)
            },
          ),
          _buildAdminFeatureCard(
            context,
            icon: Icons.people,
            title: 'User Management',
            description: 'View, Ban/Unban User Accounts.',
            color: Colors.green,
            onTap: () {
              // User Management (Ban/Unban users)
            },
          ),
          _buildAdminFeatureCard(
            context,
            icon: Icons.message,
            title: 'Customer Messaging',
            description: 'Respond to user inquiries.',
            color: Colors.orange,
            onTap: () {
              // Messaging/Chat page (Message normal users)
            },
          ),
          _buildAdminFeatureCard(
            context,
            icon: Icons.insights,
            title: 'Analytics & Reports',
            description: 'View sales and inventory data.',
            color: Colors.purple,
            onTap: () {
              // Analytics page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}