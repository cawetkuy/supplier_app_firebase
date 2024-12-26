import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:supplier_app/widgets/dialogs/custom_video_dialog.dart';
import 'package:supplier_app/screens/item/add_item/add_item_screen.dart';
import 'package:supplier_app/screens/supplier/add_supplier/add_supplier_screen.dart';
import 'package:supplier_app/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedNavbarIndex = 0;
  void _onTabChange(int index) {
    if (index == 3) {
      showCustomLottieDialog(context);
    }
    setState(() {
      _selectedNavbarIndex = index;
    });
  }

  Widget _getSelectedView() {
    switch (_selectedNavbarIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const AddItemScreen();
      case 2:
        return const AddSupplierScreen();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedView(),
      bottomNavigationBar: GNav(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        backgroundColor: const Color.fromARGB(255, 246, 245, 239),
        activeColor: const Color.fromARGB(255, 255, 254, 246),
        tabBackgroundColor: const Color.fromARGB(255, 24, 24, 23),
        tabBorderRadius: 15,
        tabMargin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        gap: 5,
        selectedIndex: _selectedNavbarIndex,
        onTabChange: _onTabChange,
        tabs: [
          const GButton(
            icon: Icons.home, // Hilangkan icon bawaan
            text: 'Dashboard',
            iconColor: Color.fromARGB(255, 24, 24, 23),
          ),
          GButton(
            icon: Icons.clear,
            text: 'Add Item',
            leading: Image.asset(
              'assets/icons/additem.png',
              width: 24,
              height: 24,
              color: const Color.fromARGB(255, 24, 24, 23),
            ),
          ),
          GButton(
            icon: Icons.clear,
            text: 'Add Supplier',
            leading: Image.asset(
              'assets/icons/addsupplier.png',
              width: 24,
              height: 24,
              color: const Color.fromARGB(255, 24, 24, 23),
            ),
          ),
        ],
      ),
    );
  }
}
