

/* class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Encomendas"));
  }
} */


import 'package:flutter/material.dart';
import 'details_page.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  final List<Map<String, String>> orders = const [
    {
      'orderNumber': '46325',
      'producer': 'Zé das Couves',
      'price': '191.88 €',
      'delivery': 'Entrega em mãos',
      'date': '13/04/2025',
      'imagePath': 'assets/images/mock_images/centeio.jpg',
    },
    {
      'orderNumber': '46326',
      'producer': 'Maria das Flores',
      'price': '120.50 €',
      'delivery': 'Entrega padrão',
      'date': '14/04/2025',
      'imagePath': 'assets/images/mock_images/centeio.jpg',
    },
    {
      'orderNumber': '46327',
      'producer': 'João das Frutas',
      'price': '85.75 €',
      'delivery': 'Retirada no local',
      'date': '15/04/2025',
      'imagePath': 'assets/images/mock_images/centeio.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Coluna com imagem, preço e tipo de entrega
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        order['imagePath']!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order['price']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      order['delivery']!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                // Restante das informações da encomenda
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Encomenda N°${order['orderNumber']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Produtor: ${order['producer']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data: ${order['date']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Botão de detalhes (mantido igual)
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(198, 220, 211, 1),
                      foregroundColor: const Color.fromRGBO(59, 126, 98, 1),
                      minimumSize: const Size(40,15),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                    ),
                    onPressed: () {
                      /* showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text(
                                'Encomenda N°${order['orderNumber']}',
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Produtor: ${order['producer']}'),
                                  Text('Valor: ${order['price']}'),
                                  Text('Tipo de entrega: ${order['delivery']}'),
                                  Text('Data: ${order['date']}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Fechar'),
                                ),
                              ],
                            ),
                      ); */
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsPage(order: order),
                        ),
                      );
                    },
                    child: const Text('Ver detalhes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}