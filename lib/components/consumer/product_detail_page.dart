import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final String product;
  final String seller;
  final String imagePath;

  const ProductDetailPage({
    super.key,
    required this.product,
    required this.seller,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    const unitPrice = 1.43; // Preço fixo de exemplo

    return Scaffold(
      appBar: AppBar(
        title: const Text("Produto"),
        backgroundColor: const Color.fromRGBO(59, 126, 98, 1),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ação do botão "+"
        },
        backgroundColor: const Color.fromRGBO(59, 126, 98, 1),
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem com nome e preço
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${unitPrice.toStringAsFixed(2)} €/un.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vendedor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  seller,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // ação "Ver banca"
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(198, 220, 211, 1),
                    foregroundColor: const Color.fromRGBO(59, 126, 98, 1),
                  ),
                  child: const Text('Ver banca'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sobre o Produto
            const Text(
              'Sobre o Produto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Se quer comprar $product, é no $seller!',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Críticas (simulado)
            const Text(
              'Críticas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('⭐ 4.5 (38 avaliações)'),
          ],
        ),
      ),
    );
  }
}
