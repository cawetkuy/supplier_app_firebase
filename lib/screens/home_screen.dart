import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supplier_app/auth/login_screen.dart';
import 'package:supplier_app/screens/item/add_item/add_item_screen.dart';
import 'package:supplier_app/screens/item/product_list_screen.dart';
import 'package:supplier_app/screens/supplier/add_supplier/add_supplier_screen.dart';
import 'package:supplier_app/screens/supplier/supplier_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<int> getTotalItems() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getTotalSuppliers() {
    return FirebaseFirestore.instance
        .collection('suppliers')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  void _showMenuOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add Item'),
                onTap: () {
                  Navigator.pop(context); // Close the menu
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddItemScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Add Supplier'),
                onTap: () {
                  Navigator.pop(context); // Close the menu
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddSupplierScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPersonOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context); // Close the menu
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 254, 246),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 24, 24, 23),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          onPressed: () => _showMenuOptions(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showPersonOptions(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            height: 350,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 24, 24, 23),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello !',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 254, 246),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Jessica Carmelita',
                  style: TextStyle(
                    color: Color.fromARGB(255, 238, 185, 11),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tracking barang anda melalui inventory Management',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 254, 246),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Content section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Manage your needs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Inventory card
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductListScreen(),
                    ),
                  ),
                  child: _buildCard(
                    icon: Icons.inventory,
                    label: 'Inventory',
                    color: const Color.fromARGB(255, 24, 24, 23),
                    stream: getTotalItems(),
                  ),
                ),
                // Supplier card
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SupplierListScreen(),
                    ),
                  ),
                  child: _buildCard(
                    icon: Icons.handshake,
                    label: 'Supplier',
                    color: const Color.fromARGB(255, 24, 24, 23),
                    stream: getTotalSuppliers(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for dashboard cards
  Widget _buildCard({
    required IconData icon,
    required String label,
    required Color color,
    required Stream<int> stream,
  }) {
    return Container(
      width: 173,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 238, 185, 11),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          StreamBuilder<int>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(
                  color: Colors.white,
                );
              }
              return Text(
                '${snapshot.data ?? 0}',
                style: const TextStyle(
                  color: Color.fromARGB(177, 255, 255, 255),
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
