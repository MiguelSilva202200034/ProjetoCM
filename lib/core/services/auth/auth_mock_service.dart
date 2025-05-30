import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:harvestly/core/models/app_user.dart';
import 'package:harvestly/core/models/consumer_user.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/store.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';

class AuthMockService implements AuthService {
  static var _defaultUser = ConsumerUser(
    id: '456',
    firstName: 'Ana',
    lastName: 'Santos',
    email: 'ana@gmail.com',
    gender: 'Feminino',
    phone: '974389293',
    recoveryEmail: 'paiAna@gmail.com',
    imageUrl: 'assets/images/avatar.png',
    dateOfBirth: '08/11/2003',
    isProducer: false,
  );

  static final Map<String, AppUser> _users = {_defaultUser.email: _defaultUser};
  static AppUser? _currentUser;
  static MultiStreamController<AppUser?>? _controller;
  static final _userStream = Stream<AppUser?>.multi((controller) {
    _controller = controller;
    _updateUser(_defaultUser);
  });

  @override
  AppUser? get currentUser {
    return _currentUser;
  }

  @override
  Stream<AppUser?> get userChanges {
    return _userStream;
  }

  @override
  Future<void> signup(
    String firstName,
    String lastName,
    String email,
    String password,
    File? image,
    String gender,
    String phone,
    String recoverEmail,
    String dateOfBirth,
  ) async {
    final newUser = ConsumerUser(
      id: Random().nextDouble().toString(),
      firstName: firstName,
      lastName: lastName,
      email: email,
      imageUrl: image?.path ?? 'assets/images/avatar.png',
      gender: gender,
      phone: phone,
      recoveryEmail: recoverEmail,
      dateOfBirth: dateOfBirth,
      isProducer: currentUser!.isProducer,
    );

    _users.putIfAbsent(email, () => newUser);
    _updateUser(newUser);
  }

  @override
  Future<void> login(String email, String password, String typeOfLogin) async {
    _updateUser(_users[email]);
  }

  @override
  Future<void> logout() async {
    _updateUser(null);
  }

  static void _updateUser(AppUser? user) {
    _currentUser = user;
    _controller?.add(_currentUser);
  }

  @override
  // TODO: implement users
  List<AppUser> get users => throw UnimplementedError();

  @override
  Future<void> recoverPassword(String email) {
    // TODO: implement recoverPassword
    throw UnimplementedError();
  }

  @override
  Future<void> updateBackgroundImage(File? backgroundImage) {
    // TODO: implement updateBackgroundImage
    throw UnimplementedError();
  }

  @override
  Future<void> updateProfileImage(File? profileImage) {
    // TODO: implement updateProfileImage
    throw UnimplementedError();
  }

  @override
  Future<void> updateSingleUserField({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? nickname,
    String? status,
    String? iconStatus,
    String? aboutMe,
    String? dateOfBirth,
    String? customStatus,
    String? customIconStatus,
    String? gender,
    String? recoveryEmail,
  }) {
    // TODO: implement updateSingleUserField
    throw UnimplementedError();
  }

  @override
  Future<void> syncEmailWithFirestore() {
    // TODO: implement syncEmailWithFirestore
    throw UnimplementedError();
  }

  @override
  Future<void> addFriend(String userId) {
    // TODO: implement addFriend
    throw UnimplementedError();
  }

  @override
  Future<void> removeFriend(String userId) {
    // TODO: implement removeFriend
    throw UnimplementedError();
  }

  @override
  // TODO: implement isLoggingIn
  bool get isLoggingIn => throw UnimplementedError();

  @override
  void setLoggingInState(bool state) {
    // TODO: implement setLoggingInState
  }

  @override
  void setProducerState(bool state) {
    // TODO: implement setProducerState
  }

  @override
  Store getMyStore() {
    // TODO: implement getMyStore
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }
}
