import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supplier_app/models/history.dart';
import 'package:supplier_app/models/products.dart';
import 'package:supplier_app/models/suppliers.dart';
import 'package:supplier_app/screens/add_history_item_screen.dart';
import 'package:supplier_app/screens/item/update_product_screen.dart';
import 'package:supplier_app/widgets/placeholder/placeholdersmall_history.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  
  late Future<Supplier?> _supplierFuture;

  @override
  void initState() {
    super.initState();
    _supplierFuture = _fetchSupplier(widget.product.supplierId);
  }

  String _formatHarga(double harga) {
    if (harga == harga.toInt()) {
      return NumberFormat("#,###", "id_ID").format(harga.toInt());
    } else {
      return NumberFormat("#,###.##", "id_ID").format(harga);
    }
  }

    Future<Supplier?> _fetchSupplier(String supplierId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('suppliers')
          .doc(supplierId)
          .get();
      if (doc.exists) {
        return Supplier.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error fetching supplier: $e');
    }
    return null;
  }

  Future<void> _deleteProduct() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final historyCollection = FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.product.id)
                    .collection('history');

                final historyDocs = await historyCollection.get();
                for (var doc in historyDocs.docs) {
                  await doc.reference.delete();
                }

                if (widget.product.imageUrl.isNotEmpty) {
                  final ref = FirebaseStorage.instance
                      .refFromURL(widget.product.imageUrl);
                  await ref.delete();
                }

                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.product.id)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pop(context);
                Navigator.pop(context);
              } catch (e) {
                debugPrint('Error deleting product: $e');
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void onSelectedMenu(BuildContext context, int value) {
    switch (value) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateProductScreen(product: widget.product),
          ),
        );
        break;
      case 1:
        _deleteProduct();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 24, 24, 23),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color.fromARGB(255, 24, 24, 23),
        actions: [
          PopupMenuButton<int>(
            iconColor: Colors.white,
            color: Colors.white,
            onSelected: (value) => onSelectedMenu(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('Delete'),
              ),
            ],
          )
        ],
        title: Text(
          widget.product.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 238, 185, 11),
                        ),
                      ),
                      Text(
                        widget.product.category,
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp. ${_formatHarga(widget.product.price)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 238, 185, 11),
                        ),
                      ),
                      Text(
                        'Stok: ${widget.product.stok}',
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            widget.product.imageUrl.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.product.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : const Icon(Icons.image_not_supported, size: 200),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Text(
                'Deskripsi: ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 238, 185, 11),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(10),
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    widget.product.description,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Supplier?>(
              future: _supplierFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text(
                    'Supplier information not available',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  );
                }
                final supplier = snapshot.data!;
                return ExpansionTile(
                  initiallyExpanded: false,
                  title: const Text(
                    'Supplier Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  children: [
                    ListTile(
                      title: const Text(
                        'Name:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Text(
                        supplier.name,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Contact:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Text(
                        supplier.contact,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Lat:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Text(
                        '${supplier.latitude}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Long:',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Text(
                        '${supplier.longitude}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Color.fromARGB(255, 255, 254, 246),
              ),
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -30,
                    left: (MediaQuery.of(context).size.width / 2) - 30,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 238, 185, 11),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddHistoryScreen(product: widget.product),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 45, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              color: const Color.fromARGB(255, 255, 254, 246),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.product.id)
                    .collection('history')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const PlaceholdersmallNoItem();
                  }

                  final histories = snapshot.data!.docs
                      .map((doc) =>
                          History.fromMap(doc.data() as Map<String, dynamic>))
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: histories.length,
                    itemBuilder: (context, index) {
                      final history = histories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: history.transactionType == 'Masuk'
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: history.transactionType == 'Masuk'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            title: Text(
                              'Date: ${DateFormat.yMd().format(history.date)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'Jumlah: ${history.quantity}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Text(
                              history.transactionType,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: history.transactionType == 'Masuk'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}