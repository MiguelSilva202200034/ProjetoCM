import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:harvestly/core/models/store.dart';

import '../../models/order.dart';
import '../../models/product_ad.dart';

class StoreService with ChangeNotifier {
  StoreService._privateConstructor();

  static final StoreService instance = StoreService._privateConstructor();

  final List<Store> _allStores = [];

  List<Store> get allStores => List.unmodifiable(_allStores);

  final firestore = cf.FirebaseFirestore.instance;

  Future<void> loadStores() async {
    final snapshot = await firestore.collection('stores').get();

    _allStores.clear();

    for (final doc in snapshot.docs) {
      final storeData = doc.data();
      final storeId = doc.id;

      final store = Store.fromJson({...storeData, 'id': storeId});

      final adsSnapshot =
          await firestore
              .collection('stores')
              .doc(storeId)
              .collection('ads')
              .get();

      final ads =
          adsSnapshot.docs.map((adDoc) {
            return ProductAd.fromJson(adDoc.data());
          }).toList();

      store.productsAds = ads;

      _allStores.add(store);
    }

    notifyListeners();
  }

  List<Store> getStoresByOwner(String ownerId) {
    final stores =
        _allStores.where((store) => store.ownerId == ownerId).toList();

    for (final store in stores) {
      _loadOrdersForStore(store);
    }

    return stores;
  }

  Future<void> _loadOrdersForStore(Store store) async {
    final orderSnapshot =
        await firestore
            .collection('orders')
            .where('storeId', isEqualTo: store.id)
            .get();

    store.orders =
        orderSnapshot.docs.map((doc) {
          final data = doc.data();
          return Order.fromJson({...data, 'id': doc.id});
        }).toList();

    notifyListeners();
  }

  Future<void> updateStoreData({
    required String name,
    required String slogan,
    required String description,
    required String address,
    required String city,
    required String municipality,
    required LatLng? coordinates,
    String? profileImageUrl,
    String? backgroundImageUrl,
    required String storeId,
  }) async {
    final storeRef = cf.FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId);

    await storeRef.update({
      'name': name,
      'slogan': slogan,
      'description': description,
      'address': address,
      'city': city,
      'municipality': municipality,
      'coordinates': {
        'latitude': coordinates!.latitude,
        'longitude': coordinates.longitude,
      },
      if (profileImageUrl != null) 'imageUrl': profileImageUrl,
      if (backgroundImageUrl != null) 'backgroundImageUrl': backgroundImageUrl,
    });
  }

  Future<String> updateProfileImage(File file, String storeId) async {
    final ref = FirebaseStorage.instance.ref().child(
      'stores/$storeId/profile.jpg',
    );

    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> updateBackgroundImage(File file, String storeId) async {
    final ref = FirebaseStorage.instance.ref().child(
      'stores/$storeId/background.jpg',
    );

    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> editProductAd(ProductAd ad, String storeId) async {
    final FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      final docRef = firestore
          .collection('stores')
          .doc(storeId)
          .collection('ads')
          .doc(ad.id);

      final List<String> imageUrls = [];

      for (int i = 0; i < ad.product.imageUrls.length; i++) {
        final image = ad.product.imageUrls[i];

        if (image.startsWith('http')) {
          imageUrls.add(image);
        } else {
          final imageFile = File(image);
          final imageRef = _storage.ref().child(
            'stores/$storeId/ads/${ad.id}/image_$i.jpg',
          );
          final uploadTask = await imageRef.putFile(imageFile);
          final imageUrl = await uploadTask.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }
      }

      await docRef.set({
        'title': ad.product.name,
        'description': ad.description,
        'imageUrls': imageUrls,
        'category': ad.product.category,
        'minQty': ad.product.minAmount,
        'unit': ad.product.unit.name,
        'price': ad.product.price,
        'stock': ad.product.stock,
        'visibility': ad.visibility,
        'highlightType': ad.highlightType?.name,
        'highlightDate': ad.highlightDate,
        'keywords': ad.keywords,
        'updatedAt': cf.FieldValue.serverTimestamp(),
      }, cf.SetOptions(merge: true));
    } catch (e) {
      print("Erro ao editar anúncio: $e");
      rethrow;
    }
  }
}
