import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supplier_app/models/products.dart';
import 'package:supplier_app/widgets/chips/category_chip.dart';
import 'package:supplier_app/widgets/textfields/item/item_description_textfield.dart';
import 'package:supplier_app/widgets/textfields/item/item_name_textfield.dart';
import 'package:supplier_app/widgets/textfields/item/item_price_textfield.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  File? selectedImage;
  final TextEditingController controllerTypedItemName = TextEditingController();
  final TextEditingController controllerTypedPriceName =
      TextEditingController();
  final TextEditingController controllerTypedDescriptionName =
      TextEditingController();
  bool _isLoading = false;
  String selectedCategory = "";
  String? _selectedSupplierId;

  Future<void> _addItem() async {
    if (controllerTypedItemName.text.isEmpty ||
        controllerTypedPriceName.text.isEmpty ||
        controllerTypedDescriptionName.text.isEmpty ||
        selectedCategory.isEmpty ||
        selectedImage == null ||
        _selectedSupplierId == null) {
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

    final productId =
        FirebaseFirestore.instance.collection('products').doc().id;
    final ref = FirebaseStorage.instance.ref('products/$productId.jpg');
    await ref.putFile(selectedImage!);
    final imageUrl = await ref.getDownloadURL();

    final newProduct = Product(
      id: productId,
      name: controllerTypedItemName.text,
      price: double.parse(controllerTypedPriceName.text),
      category: selectedCategory,
      description: controllerTypedDescriptionName.text,
      stok: 0,
      imageUrl: imageUrl,
      supplierId: _selectedSupplierId!,
    );

    await FirebaseFirestore.instance
        .collection('products')
        .doc(newProduct.id)
        .set(newProduct.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Product added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() {
      _isLoading = false;
    });
    _clearForm();
  }

  Future<void> _pickImageOption() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final returnedImage = await ImagePicker().pickImage(source: source);
      if (returnedImage != null) {
        setState(() {
          selectedImage = File(returnedImage.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengambil gambar'),
        ),
      );
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void _clearForm() {
    setState(() {
      controllerTypedItemName.clear();
      controllerTypedPriceName.clear();
      controllerTypedDescriptionName.clear();
      selectedCategory = "";
      selectedImage = null;
    });
  }

  @override
  void dispose() {
    controllerTypedItemName.dispose();
    controllerTypedPriceName.dispose();
    controllerTypedDescriptionName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
      color: Color.fromARGB(255, 24, 24, 23)
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImageOption,
                      child: selectedImage == null
                          ? Container(
                              width: 320,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color.fromARGB(255, 238, 185, 11)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 34.0,
                                      color: Color.fromARGB(255, 238, 185, 11),
                                    ),
                                    Text(
                                      "Tap to upload image",
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(selectedImage!.path),
                                width: 320,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 255, 254, 246),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Name', 
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                              ItemNameTextfield(
                                  controllerTyped: controllerTypedItemName),
                              const Text('Price',style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                              ItemPriceTextfield(
                                  controllerTyped: controllerTypedPriceName),
                              const Text('Category', style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                              CategoryChipWidget(
                                  selectedCategory: selectedCategory,
                                  onCategorySelected: _onCategorySelected),
                              const Text('Description', style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                ),
                              ),
                              ItemDescriptionTextfield(
                                  controllerTyped:
                                      controllerTypedDescriptionName),
                              const SizedBox(
                                height: 16,
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('suppliers')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }
                                  final suppliers = snapshot.data!.docs;
                                  if (suppliers.isEmpty) {
                                    return const Text(
                                      'Tidak ada supplier',
                                      style: TextStyle(color: Colors.grey),
                                    );
                                  }
                                  return DropdownButton<String>(
                                    value: _selectedSupplierId,
                                    hint: const Text('Select Supplier', style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSupplierId = value;
                                      });
                                    },
                                    items: suppliers.map((doc) {
                                      return DropdownMenuItem<String>(
                                        value: doc.id,
                                        child: Text(doc['name']),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: MaterialButton(
                                  height: 48,
                                  onPressed: _addItem,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: const Color.fromARGB(255, 238, 185, 11),
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
