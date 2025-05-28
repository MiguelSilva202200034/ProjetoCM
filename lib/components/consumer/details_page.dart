import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, String> order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes'),//'Encomenda N°${order['orderNumber']}'),
        backgroundColor: const Color.fromRGBO(59, 126, 98, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              order['imagePath']!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text('Encomenda N°${order['orderNumber']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Produtor: ${order['producer']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Valor: ${order['price']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Tipo de entrega: ${order['delivery']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Data: ${order['date']}',
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
