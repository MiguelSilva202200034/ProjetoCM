import 'package:flutter/material.dart';

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
                  // Imagem do produto
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

                  // Informações do produto
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

                  // Botões de ação
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão de coração (remover dos favoritos)
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          // Implementar lógica para remover dos favoritos
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item['product']} removido dos favoritos'),
                            ),
                          );
                        },
                      ),
                      
                      // Botão "Ver em loja"
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(59, 126, 98, 1),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(100, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          // Navegar para página da loja
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(title: Text(item['product']!)),
                                body: Center(child: Text('Página de ${item['product']}')),
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