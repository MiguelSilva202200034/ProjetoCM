import 'dart:async';

import 'package:flutter/material.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/core/models/product_ad.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/other/bottom_navigation_notifier.dart';
import 'package:harvestly/pages/profile_page.dart';
import 'package:harvestly/utils/categories.dart';
import 'package:provider/provider.dart';
import '../../core/models/producer_user.dart';
import '../../core/models/store.dart';

class ConsumerHomePage extends StatefulWidget {
  const ConsumerHomePage({super.key});

  @override
  State<ConsumerHomePage> createState() => _ConsumerHomePageState();
}

class _ConsumerHomePageState extends State<ConsumerHomePage> {
  late String userName;
  late List<ProductAd> recommendedAds;
  late List<ProducerUser> nearbyProducers;
  late final ScrollController _scrollController;
  late final List<String> promoImages;
  late AuthNotifier authNotifier;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final user = AuthService().currentUser;
    if (user != null) {
      userName = user.firstName;
    } else {
      userName = 'Utilizador';
    }

    promoImages = [
      'assets/images/discounts_images/75%PT.png',
      'assets/images/discounts_images/50%PT.png',
      'assets/images/discounts_images/25%PT.png',
      'assets/images/discounts_images/10%PT.png',
      'assets/images/discounts_images/5%PT.png',
    ];

    _scrollController = ScrollController();

    _scrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final current = _scrollController.offset;
        double next = current + 130;

        if (next >= maxScroll) next = 0;

        _scrollController.animateTo(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<Map<String, dynamic>> getNearbyStores() {
    final currentUser = authNotifier.currentUser;
    if (currentUser == null || currentUser.city == null) return [];

    final userCity = currentUser.city!.toLowerCase().trim();

    final List<Map<String, dynamic>> nearbyStores = [];

    for (final producer in authNotifier.producerUsers) {
      for (final store in producer.stores) {
        if ((store.city ?? '').toLowerCase().trim() == userCity) {
          nearbyStores.add({'producer': producer, 'store': store});
        }
      }
    }

    return nearbyStores.take(5).toList(); // Mostra no máx 5
  }

  Widget _buildStoreItem(ProducerUser user, Store store) {
    return InkWell(
      onTap:
          () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => ProfilePage(user))),
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  user.imageUrl.isNotEmpty
                      ? NetworkImage(user.imageUrl)
                      : const AssetImage('assets/images/default_user.png')
                          as ImageProvider,
            ),
            const SizedBox(height: 6),
            Text(
              '${user.firstName} ${user.lastName}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              store.city ?? 'Cidade desconhecida',
              style: const TextStyle(fontSize: 10),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.rating.toString(),
                  style: const TextStyle(fontSize: 10),
                ),
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text(
                  '(${store.storeReviews?.length ?? 0})',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductAd>>(
      stream: context.watch<AuthNotifier>().getAllProductAdsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allAds = snapshot.data!;
        final seenIds = <String>{};
        final uniqueAds = allAds.where((ad) => seenIds.add(ad.id)).toList();
        final top5Ads = uniqueAds.take(5).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Olá, $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Descobre os melhores produtos frescos na tua zona!',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),

              _buildPromotionsBanner(),
              const SizedBox(height: 16),
              _buildCategories(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: const Text(
                  'Recomendados para ti',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: top5Ads.length,
                    itemBuilder: (context, index) {
                      final ad = top5Ads[index];
                      return _buildProductItem(ad);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Produtores com bancas perto de ti',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: Builder(
                  builder: (context) {
                    final nearbyStores = getNearbyStores();
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: nearbyStores.length,
                      itemBuilder: (context, index) {
                        final producer =
                            nearbyStores[index]['producer'] as ProducerUser;
                        final store = nearbyStores[index]['store'] as Store;
                        return _buildStoreItem(producer, store);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildPromotionsBanner() {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: promoImages.length,
            padding: const EdgeInsets.only(bottom: 30),
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(promoImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              color: Colors.black.withValues(alpha: 0.5),
              child: const Text(
                'Promoções até 75% em todas a fruta da tua zona!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories =
        Categories.categories.map((c) => c.name).take(5).toList();
    final icons = Categories.categories.map((c) => c.icon).take(5).toList();

    return SizedBox(
      height: 100,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(categories.length, (index) {
              return InkWell(
                onTap: () {
                  Provider.of<BottomNavigationNotifier>(
                    context,
                    listen: false,
                  ).setIndexAndCategory(2, categories[index]);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.green[100],
                        child: Icon(icons[index], color: Colors.green[800]),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        categories[index],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  ProducerUser? findProducerOfAd(ProductAd ad, List<ProducerUser> producers) {
    for (final producer in producers) {
      for (final store in producer.stores) {
        if (store.productsAds?.any((a) => a.id == ad.id) ?? false) {
          return producer;
        }
      }
    }
    return null;
  }

  Widget _buildProductItem(ProductAd ad) {
    final product = ad.product;
    final producer = findProducerOfAd(ad, authNotifier.producerUsers);
    return InkWell(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (ctx) => ProductAdDetailScreen(ad: ad, producer: producer!),
            ),
          ),
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(product.imageUrls.first),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                product.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
