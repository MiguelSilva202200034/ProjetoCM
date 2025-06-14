import 'dart:io';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:harvestly/core/models/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../models/consumer_user.dart';
import '../../models/offer.dart';
import '../../models/order.dart';
import '../../models/producer_user.dart';
import '../../models/product_ad.dart';
import '../../models/store.dart';
import '../chat/chat_list_notifier.dart';

class AuthService {
  static bool? _isLoggingIn;
  static bool? _isProducer;
  static AppUser? _currentUser;
  static final List<AppUser> _users = [];
  static StreamSubscription? _userChangesSubscription;
  static final _userStream = Stream<AppUser?>.multi((controller) async {
    final authChanges = FirebaseAuth.instance.authStateChanges();

    await for (final user in authChanges) {
      if (user == null) {
        _currentUser = null;
        controller.add(null);
      } else {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (doc.exists) {
          final data = doc.data()!;
          if (data['isProducer'] == true) {
            _currentUser = ProducerUser.fromJson({...data, 'id': user.uid});
          } else {
            _currentUser = ConsumerUser.fromJson({...data, 'id': user.uid});
          }
        } else {
          _currentUser = _toAppUser(user);
        }

        controller.add(_currentUser);
      }
    }
  });

  static Store? _myStore;

  AuthService() {
    listenToUserChanges();
  }

  Future<AppUser?> initializeAndGetUser() async {
    final user = await getCurrentUser();

    if (user is ProducerUser) {
      final completer = Completer<void>();

      FirebaseFirestore.instance
          .collection('stores')
          .where('ownerId', isEqualTo: user.id)
          .get()
          .then((snapshot) {
            user.stores.clear();
            for (var doc in snapshot.docs) {
              final data = doc.data();
              final store = Store.fromJson({
                ...data,
                'id': doc.id,
                if (data['createdAt'] is Timestamp)
                  'createdAt': (data['createdAt'] as Timestamp).toDate(),
                if (data['updatedAt'] is Timestamp)
                  'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
              });
              user.stores.add(store);
            }
            completer.complete();
          });

      await completer.future;
    }

    return user;
  }

  Future<AppUser?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    return await _userStream.firstWhere(
      (user) => user != null || FirebaseAuth.instance.currentUser == null,
    );
  }

  void listenToUserChanges() {
    _userChangesSubscription = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((snapshot) async {
          _users.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final id = doc.id;

            AppUser user;
            if (data['isProducer'] == true) {
              user = ProducerUser.fromJson({...data, 'id': id});
            } else {
              user = ConsumerUser.fromJson({...data, 'id': id});
            }

            _users.add(user);

            if (_currentUser != null && _currentUser!.id == id) {
              _currentUser = user;

              if (_currentUser is ProducerUser) {
                _listenToMyStores(_currentUser!.id);
              }
            }
          }
        });
  }

  void _listenToMyStores(String userId) {
    FirebaseFirestore.instance.collection('stores').snapshots().listen((
      snapshot,
    ) {
      (_currentUser as ProducerUser).stores.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['ownerId'] == userId) {
          final store = Store.fromJson({
            ...data,
            'id': doc.id,
            if (data['createdAt'] is Timestamp)
              'createdAt': (data['createdAt'] as Timestamp).toDate(),
            if (data['updatedAt'] is Timestamp)
              'updatedAt': (data['updatedAt'] as Timestamp).toDate(),
          });
          (_currentUser as ProducerUser).stores.add(store);
        }
      }
    });
  }

  List<AppUser> get users => _users;

  bool get isLoggingIn => _isLoggingIn ?? false;

  Store getMyStore() => _myStore!;

  void setProducerState(bool state) => _isProducer = state;

  void setLoggingInState(bool state) => _isLoggingIn = state;

  AppUser? get currentUser {
    return _currentUser;
  }

  Stream<AppUser?> get userChanges {
    return _userStream;
  }

  Future<void> signup(
    String firstName,
    String lastName,
    String email,
    String password,
    File? image,
    String phone,
    String recoveryEmail,
    String dateOfBirth,
    String country,
    String city,
    String municipality,
    List<Offer>? offers,
  ) async {
    final signup = await Firebase.initializeApp(
      name: 'userSignup',
      options: Firebase.app().options,
    );

    final auth = FirebaseAuth.instanceFor(app: signup);

    UserCredential credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      final imageName = '${credential.user!.uid}_profile.jpg';
      final imageUrl = await _uploadUserImage(image, imageName);

      final fullName = '$firstName $lastName';
      await credential.user?.updateDisplayName(fullName);
      await credential.user?.updatePhotoURL(imageUrl);

      await login(email, password, "Normal");

      _currentUser = _toAppUser(
        credential.user!,
        firstName,
        lastName,
        phone,
        recoveryEmail,
        imageUrl,
        dateOfBirth,
        _isProducer ?? false,
        country,
        city,
        municipality,
        offers,
      );
      await _saveAppUser(_currentUser!);

      final store = FirebaseFirestore.instance;
      final docRef = store.collection('users').doc(credential.user!.uid);
      await docRef.update({'firstName': firstName, 'lastName': lastName});
    }

    await signup.delete();
  }

  Future<void> login(String email, String password, String typeOfLogin) async {
    if (typeOfLogin == "Normal")
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    else if (typeOfLogin == "Google")
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      } on Exception catch (e) {
        print('exception->$e');
      }
    else if (typeOfLogin == "Facebook") {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    }
    ChatListNotifier.instance.listenToChats();
  }

  Future<void> logout() async {
    if (_currentUser == null) return;

    await _userChangesSubscription?.cancel();
    _userChangesSubscription = null;

    final auth = FirebaseAuth.instance;

    _currentUser = null;
    _users.clear();

    await auth.signOut();
  }

  Future<void> recoverPassword(String email) async {
    final auth = FirebaseAuth.instance;
    await auth.sendPasswordResetEmail(email: email);
  }

  Future<String> updateProfileImage(File? profileImage) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "";

    if (profileImage != null) {
      final profileImageName = '${user.uid}_profile.jpg';
      final profileImageUrl = await _uploadUserImage(
        profileImage,
        profileImageName,
      );
      await user.updatePhotoURL(profileImageUrl);
      _currentUser!.imageUrl = profileImageUrl!;

      final store = FirebaseFirestore.instance;
      final docRef = store.collection('users').doc(user.uid);
      await docRef.update({'imageUrl': profileImageUrl});
      return profileImageUrl;
    }
    return "";
  }

  Future<String> updateBackgroundImage(File? backgroundImage) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) "";

    if (backgroundImage != null) {
      final backgroundImageName = '${user!.uid}_background.jpg';
      final backgroundImageUrl = await _uploadUserImage(
        backgroundImage,
        backgroundImageName,
      );
      _currentUser!.backgroundUrl = backgroundImageUrl;

      final store = FirebaseFirestore.instance;
      final docRef = store.collection('users').doc(user.uid);
      await docRef.update({'backgroundImageUrl': backgroundImageUrl});
      return backgroundImageUrl!;
    }
    return "";
  }

  Future<String?> _uploadUserImage(File? image, String imageName) async {
    if (image == null) return null;

    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('user_images').child(imageName);
    await imageRef.putFile(image);
    return await imageRef.getDownloadURL();
  }

  Future<void> updateSingleUserField({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? aboutMe,
    String? dateOfBirth,
    String? recoveryEmail,
    String? country,
    String? city,
    String? municipality,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.uid);

    if (firstName != null) {
      await user.updateDisplayName(
        "${firstName} ${lastName ?? _currentUser?.lastName ?? ''}",
      );
      await docRef.update({'firstName': firstName});
      _currentUser!.firstName = firstName;
    }

    if (lastName != null) {
      await user.updateDisplayName(
        "${firstName ?? _currentUser?.firstName ?? ''} ${lastName}",
      );
      await docRef.update({'lastName': lastName});
      _currentUser!.lastName = lastName;
    }

    if (email != null) {
      await user.verifyBeforeUpdateEmail(email);
    }

    if (phone != null) {
      await docRef.update({'phone': phone});
      _currentUser!.phone = phone;
    }

    if (aboutMe != null) {
      await docRef.update({'aboutMe': aboutMe});
      _currentUser!.aboutMe = aboutMe;
    }
    if (dateOfBirth != null) {
      await docRef.update({'dateOfBirth': dateOfBirth});
      _currentUser!.dateOfBirth = dateOfBirth;
    }
    if (recoveryEmail != null) {
      await docRef.update({'recoveryEmail': recoveryEmail});
      _currentUser!.recoveryEmail = recoveryEmail;
    }
    if (country != null) {
      await docRef.update({'country': country});
      _currentUser!.country = country;
    }
    if (city != null) {
      await docRef.update({'city': city});
      _currentUser!.city = city;
    }
    if (municipality != null) {
      await docRef.update({'municipality': municipality});
      _currentUser!.municipality = municipality;
    }
  }

  Future<void> syncEmailWithFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.uid);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final firestoreEmail = docSnapshot.data()?['email'];
        final authEmail = user.email;

        if (firestoreEmail != authEmail) {
          await docRef.update({'email': authEmail});
        }
      }
    } catch (e) {
      print("Erro ao sincronizar email com Firestore: $e");
    }
  }

  Future<void> _saveAppUser(AppUser user) async {
    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.id);

    return docRef.set({
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'phone': user.phone,
      'recoveryEmail': user.recoveryEmail,
      'imageUrl': user.imageUrl,
      'dateOfBirth': user.dateOfBirth,
      'isProducer': user.isProducer,
      'aboutMe': user.aboutMe,
      'backgroundImageUrl': user.backgroundUrl,
      'country': user.country,
      'city': user.city,
      'municipality': user.municipality,
    });
  }

  static AppUser _toAppUser(
    User user, [
    String? firstName,
    String? lastName,
    String? phone,
    String? recoveryEmail,
    String? imageUrl,
    String? dateOfBirth,
    bool? isProducer,
    String? country,
    String? city,
    String? municipality,
    List<Offer>? offers,
  ]) {
    final bool producer = isProducer ?? false;
    if (producer) {
      return ProducerUser(
        id: user.uid,
        email: user.email!,
        firstName:
            firstName ??
            user.displayName?.split(' ')[0] ??
            user.email!.split('@')[0],
        lastName:
            lastName ??
            (((user.displayName?.split(' ').length ?? 0) > 1)
                ? user.displayName?.split(' ')[1]
                : "") ??
            "",
        isProducer: true,
        phone: phone ?? '',
        imageUrl: imageUrl ?? user.photoURL ?? 'assets/images/avatar.png',
        recoveryEmail: recoveryEmail ?? '',
        dateOfBirth: dateOfBirth ?? '',
        baskets: [],
        country: country ?? '',
        city: city ?? '',
        municipality: municipality ?? "",
      );
    } else {
      return ConsumerUser(
        id: user.uid,
        email: user.email!,
        firstName:
            firstName ??
            user.displayName?.split(' ')[0] ??
            user.email!.split('@')[0],
        lastName:
            lastName ??
            ((user.displayName?.split(' ').length ?? 0) > 1
                ? user.displayName?.split(' ')[1]
                : "") ??
            "",
        isProducer: false,
        phone: phone ?? '',
        imageUrl: imageUrl ?? user.photoURL ?? 'assets/images/avatar.png',
        recoveryEmail: recoveryEmail ?? '',
        dateOfBirth: dateOfBirth ?? '',
        country: country ?? '',
        city: city ?? '',
        municipality: municipality ?? '',
        offers: offers ?? [],
      );
    }
  }

  Future<void> addStore({
    required String name,
    required String subName,
    required String description,
    required String city,
    required String municipality,
    required String address,
    required File imageFile,
    required File backgroundImageFile,
    required List<String> deliveryMethods,
    required LatLng coordinates,
  }) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      final docRef = _firestore.collection('stores').doc();
      final storeId = docRef.id;

      final imageRef = _storage.ref().child('stores/$storeId/image.jpg');
      final imageUploadTask = await imageRef.putFile(imageFile);
      final imageUrl = await imageUploadTask.ref.getDownloadURL();

      final bgRef = _storage.ref().child('stores/$storeId/background.jpg');
      final bgUploadTask = await bgRef.putFile(backgroundImageFile);
      final backgroundImageUrl = await bgUploadTask.ref.getDownloadURL();

      await _firestore.collection('stores').doc(storeId).set({
        'id': storeId,
        'ownerId': currentUser!.id,
        'name': name,
        'subName': subName,
        'description': description,
        'city': city,
        'municipality': municipality,
        'address': address,
        'imageUrl': imageUrl,
        'backgroundImageUrl': backgroundImageUrl,
        'deliveryMethods': deliveryMethods,
        'coordinates': {
          'latitude': coordinates.latitude,
          'longitude': coordinates.longitude,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Store criada com sucesso!");
    } catch (e) {
      print("Erro ao criar store: $e");
      rethrow;
    }
  }

  Future<ProductAd> createAd(
    String title,
    String description,
    List<File> images,
    String category,
    double minQty,
    String unit,
    double price,
    int stock,
    String storeId,
    List<String> keywords,
    String? highlight,
  ) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      final docRef =
          _firestore.collection('stores').doc(storeId).collection('ads').doc();

      final String adId = docRef.id;
      final List<String> imageUrls = [];

      for (int i = 0; i < images.length; i++) {
        final imageRef = _storage.ref().child(
          'stores/$storeId/ads/$adId/image_$i.jpg',
        );
        final uploadTask = await imageRef.putFile(images[i]);
        final imageUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      await docRef.set({
        'createdAt': FieldValue.serverTimestamp(),
        'id': adId,
        'title': title,
        'description': description,
        'imageUrls': imageUrls,
        'category': category,
        'minQty': minQty,
        'unit': unit,
        'price': price,
        'stock': stock,
        'storeId': storeId,
        'visibility': true,
        'keywords': keywords,
        'highlightType': highlight ?? '',
      });
      final adSnap = await docRef.get();

      final productAd = ProductAd.fromJson(adSnap.data()!);
      return productAd;
    } catch (e) {
      print("Erro ao publicar anúncio: $e");
      rethrow;
    }
  }

  Future<void> changeOrderState(String orderId, OrderState state) async {
    print("Cheguei aqui");
    try {
      final docRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);

      await docRef.update({'status': state.toDisplayString()});
    } catch (e) {
      print("Erro ao mudar o estado");
    }
  }

  Future<void> addToCart(ProductAd productAd, double quantity) async {
    final user = AuthService().currentUser;
    if (user == null) return;

    final cartsRef = FirebaseFirestore.instance.collection('shoppingCarts');

    final query =
        await cartsRef.where('ownerId', isEqualTo: user.id).limit(1).get();

    DocumentReference? cartDocRef;
    Map<String, dynamic> cartData;

    if (query.docs.isEmpty) {
      cartDocRef = await cartsRef.add({
        'ownerId': user.id,
        'createdAt': FieldValue.serverTimestamp(),
        'productsQty': [
          {'productAdId': productAd.id, 'quantity': quantity},
        ],
      });
    } else {
      final doc = query.docs.first;
      cartDocRef = doc.reference;
      cartData = doc.data();

      final products = List<Map<String, dynamic>>.from(
        cartData['productsQty'] ?? [],
      );
      final index = products.indexWhere(
        (p) => p['productAdId'] == productAd.id,
      );

      if (index != -1) {
        products[index]['quantity'] += quantity;
      } else {
        products.add({'productAdId': productAd.id, 'quantity': quantity});
      }

      await cartDocRef.update({'productsQty': products});
    }
  }
}
