import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, String> order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        backgroundColor: const Color.fromRGBO(59, 126, 98, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /* Image.asset(
                order['imagePath']!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ), */
              const SizedBox(height: 20),
              Text('Encomenda N°${order['orderNumber']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
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
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                'Produtos comprados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Lista de produtos
              ..._buildProductList(order),  
              const SizedBox(height: 80), // espaço extra para não ficar colado ao botão
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para contactar o vendedor
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contactar vendedor...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(59, 126, 98, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Contactar Vendedor'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para ver fatura
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ver fatura...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Ver Fatura'),
              ),
            ),
          ],
        ),
      ),
    );
  }


List<Widget> _buildProductList(Map<String, String> order) {
  final products = order['products']!.split(', ');
  final quantities = order['quantities']!.split(', ');

  return List.generate(products.length, (index) {
    final product = products[index];
    final quantity = quantities[index];
    final unitPrice = 2.50; // preço por unidade simulado
    final total = (int.parse(quantity) * unitPrice).toStringAsFixed(2);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Quantidade: $quantity'),
                  Text('Preço/unidade: ${unitPrice.toStringAsFixed(2)} €'),
                  Text('Subtotal: $total €'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                // lógica de comprar novamente
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(198, 220, 211, 1),
                foregroundColor: const Color.fromRGBO(59, 126, 98, 1),
              ),
              child: const Text('Comprar'),
            ),
          ],
        ),
      ),
    );
  });
}



}
