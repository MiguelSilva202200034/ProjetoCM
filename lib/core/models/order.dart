import 'product.dart';
import 'product_ad.dart';

enum OrderState { Entregue, Pendente, Enviada, Abandonada }

class Order {
  final String id;
  final DateTime pickupDate;
  DateTime? deliveryDate;
  final String address;
  final OrderState state;
  final List<ProductAd> productsAds;
  final double totalPrice;
  final String consumerId;
  final String producerId;

  Order({
    required this.id,
    required this.pickupDate,
    required this.deliveryDate,
    required this.address,
    required this.state,
    required this.productsAds,
    required this.totalPrice,
    required this.consumerId,
    required this.producerId,
  });
}
