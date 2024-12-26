import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supplier_app/models/suppliers.dart';
import 'package:supplier_app/widgets/dialogs/map_dialog.dart';
import 'package:supplier_app/widgets/textfields/supplier/contact_supplier_textfield.dart';
import 'package:supplier_app/widgets/textfields/supplier/latitude_supplier_textfield.dart';
import 'package:supplier_app/widgets/textfields/supplier/longitude_supplier_textfield.dart';
import 'package:supplier_app/widgets/textfields/supplier/name_supplier_textfield.dart';
import 'package:location/location.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final TextEditingController controllerTypedSupplierName =
      TextEditingController();
  final TextEditingController controllerTypedSupplierContact =
      TextEditingController();
  final TextEditingController controllerLongitude = TextEditingController();
  final TextEditingController controllerLatitude = TextEditingController();
  bool _isLoading = false;

  LatLng? selectedPosition;

  void _addSupplier() async {
    if (controllerTypedSupplierName.text.isEmpty ||
        controllerTypedSupplierContact.text.isEmpty ||
        controllerLongitude.text.isEmpty ||
        controllerLatitude.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields must be filled!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final newSupplier = Supplier(
      id: FirebaseFirestore.instance.collection('suppliers').doc().id,
      name: controllerTypedSupplierName.text,
      contact: controllerTypedSupplierContact.text,
      latitude: double.parse(controllerLatitude.text),
      longitude: double.parse(controllerLongitude.text),
    );

    await FirebaseFirestore.instance
        .collection('suppliers')
        .doc(newSupplier.id)
        .set(newSupplier.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Supplier added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      _isLoading = false;
    });
    _clearForm();
  }

  void _clearForm() {
    controllerTypedSupplierName.clear();
    controllerTypedSupplierContact.clear();
    controllerLongitude.clear();
    controllerLatitude.clear();
  }

  Future<void> _openMap() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    LocationData currentLocation = await location.getLocation();
    LatLng initialPosition =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: MapDialog(
          initialPosition: initialPosition,
          onLocationSelected: (LatLng location) {
            setState(() {
              selectedPosition = location;
              controllerLongitude.text = location.longitude.toString();
              controllerLatitude.text = location.latitude.toString();
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    controllerTypedSupplierName.dispose();
    controllerTypedSupplierContact.dispose();
    controllerLongitude.dispose();
    controllerLatitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  const Text('Name', style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                  NameSupplierTextfield(
                      controllerTyped: controllerTypedSupplierName),
                  const Text('Phone Contact', style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                  ContactSupplierTextfield(
                      controllerTyped: controllerTypedSupplierContact),
                  const Text('Supplier Longitude', style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                  LongitudeSupplierTextfield(
                      controllerTyped: controllerLongitude),
                  const Text('Supplier Latitude', style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                  LatitudeSupplierTextfield(
                      controllerTyped: controllerLatitude),
                  const Text(
                    '*Use add location to set the supplier location',
                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 150,
                        child: MaterialButton(
                            height: 40,
                            onPressed: _openMap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: const Color.fromARGB(255, 255, 255, 255),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.location_city,
                                  size: 16,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add Location',
                                  style: TextStyle(
                                      color: Colors.black),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: MaterialButton(
                      onPressed: _addSupplier,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: const Color.fromARGB(255, 238, 185, 11),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
