import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supplier_app/models/products.dart';
import 'package:supplier_app/screens/item/detail_product_screen.dart';
import 'package:supplier_app/widgets/placeholder/placeholder_home.dart';
import 'package:shimmer/shimmer.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color.fromARGB(255, 24, 24, 23),
        title: const Text(
          'Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const PlaceholderNoItem();
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final product = Product.fromMap(doc.data() as Map<String, dynamic>);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: product),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 220, // Ukuran total kartu
                      child: Card(
                        color: const Color.fromARGB(255, 24, 24, 23),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Tata letak kiri
                          children: [
                            // Bagian Gambar
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      height: 140, // Tinggi gambar
                                      width: double.infinity, // Lebar penuh
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          height: 140,
                                          width: double.infinity,
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      height: 140,
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            // Bagian Teks
                            Padding(
                              padding: const EdgeInsets.all(12.0), // Jarak dari tepi
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Kolom kiri: Nama Barang dan Kategori
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 238, 185, 11),
                                        ),
                                        overflow: TextOverflow.ellipsis, // Jika teks terlalu panjang
                                      ),
                                      const SizedBox(height: 4), // Jarak antar teks
                                      Text(
                                        'Kategori: ${product.category}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(255, 255, 254, 246),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  // Kolom kanan: Harga dan Stok
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rp. ${NumberFormat("#,###", "id_ID").format(product.price)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 238, 185, 11),
                                        ),
                                      ),
                                      const SizedBox(height: 4), // Jarak antar teks
                                      Text(
                                        'Stok: ${product.stok}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(255, 255, 254, 246),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }
}
