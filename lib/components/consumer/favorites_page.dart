import 'package:flutter/material.dart';
import 'product_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  final List<Map<String, String>> favorites = const [
    {
      'product': 'Batata',
      'seller': 'Banca Zé das Couve',
      'imagePath': 'assets/images/mock_images/batata.jpg',
    },
    {
      'product': 'Cenoura',
      'seller': 'Banca Joel Loures',
      'imagePath': 'assets/images/mock_images/cenoura.jpg',
    },
    {
      'product': 'Tomate',
      'seller': 'Banca António Silva',
      'imagePath': 'assets/images/mock_images/tomate.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final item = favorites[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item['imagePath']!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  const SizedBox(width: 12),


                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['product']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['seller']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //heart button
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Color.fromRGBO(66, 139, 112, 1)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item['product']} removido dos favoritos'),
                            ),
                          );
                        },
                      ),
                      
                      //ver em loja button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(59, 126, 98, 1),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProductDetailPage(
                                    product: item['product']!,
                                    seller: item['seller']!,
                                    imagePath: item['imagePath']!,
                                  ),
                           ),
                          );
                        },
                        child: const Text('Ver em loja'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}