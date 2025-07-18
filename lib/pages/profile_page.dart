import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:harvestly/components/consumer/product_ad_detail_screen.dart';
import 'package:harvestly/components/producer/store_page.dart';
import 'package:harvestly/components/sendMessageButton.dart';
import 'package:harvestly/core/models/consumer_user.dart';
import 'package:harvestly/core/models/order.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/models/product.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/services/other/settings_notifier.dart';
import 'package:provider/provider.dart';
import '../components/country_state_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/models/app_user.dart';
import '../core/models/product_ad.dart';
import '../core/models/store.dart';
import '../core/services/auth/auth_service.dart';
import '../utils/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:collection/collection.dart';

class ProfilePage extends StatefulWidget {
  final AppUser? user;
  ProfilePage([this.user]);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  String? userName;

  String? firstName;
  String? lastName;
  String? countryValue;
  String? cityValue;
  String? municipalityValue;
  String? _phone;
  String? aboutMe;

  bool _isEditingName = false;
  bool _isEditingPassword = false;
  bool _isLoading = false;
  bool _isEditingBackgroundImage = false;
  bool _isEditingEmail = false;
  bool _dataChanged = false;

  String _countryCode = 'PT';

  File? _backgroundImage;
  File? _profileImage;

  final _formKey = GlobalKey<FormState>();

  late AppUser? user;
  late List<Order>? orders;

  void _initStatus() async {
    setState(() {
      if (user!.isProducer) {
        final producer = user as ProducerUser;
        orders =
            producer.stores.isNotEmpty
                ? (producer.stores.first.orders ?? [])
                    .where((o) => o.state == OrderState.Delivered)
                    .toList()
                : [];
      } else {
        final consumer = user as ConsumerUser;
        orders =
            (consumer.orders ?? [])
                .where((o) => o.state == OrderState.Delivered)
                .toList();
      }
      firstName = user!.firstName;
      lastName = user!.lastName;
      aboutMe = user!.aboutMe;
      userName = "${firstName} ${lastName}";
      countryValue = user!.country;
      cityValue = user!.city;
      municipalityValue = user!.municipality;
      _phone = user!.phone;
      final phoneParts = user?.phone.trim().split(" ");
      user?.phone = phoneParts!.isNotEmpty ? phoneParts.last : "";
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      final loadedUser =
          widget.user ??
          Provider.of<AuthNotifier>(context, listen: false).currentUser;
      if (loadedUser == null) return;
      user = loadedUser;
    });
    _initStatus();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      setState(() {
        _dataChanged = true;
        _isEditingBackgroundImage
            ? _backgroundImage = File(pickedImage.path)
            : _profileImage = File(pickedImage.path);
      });
    }
    _isEditingBackgroundImage = false;
  }

  Widget _buildTextField(
    String label,
    String value,
    void Function(String)? onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.secondary,
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
          onChanged: onChanged,
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _customButton(
    String label,
    GestureTapCallback onTap, {
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                isPrimary
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.secondary,
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    isPrimary
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.secondaryFixed,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {});
      return;
    }
    setState(() => _isLoading = true);
    String? imageUrl;
    String? backgrounUrl;
    if (!_isEditingPassword &&
        !_isEditingName &&
        !_isEditingEmail &&
        (_profileImage != null || _backgroundImage != null)) {
      try {
        if (_profileImage != null)
          imageUrl = await AuthService().updateProfileImage(_profileImage);
        if (_backgroundImage != null)
          backgrounUrl = await AuthService().updateBackgroundImage(
            _backgroundImage,
          );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagem atualizado com sucesso!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: $error')),
        );
      }
    }
    try {
      await AuthService().updateSingleUserField(
        firstName: firstName,
        lastName: lastName,
        aboutMe: aboutMe,
        country: countryValue,
        city: cityValue,
        municipality: municipalityValue,
        phone: _phone,
      );
      Provider.of<AuthNotifier>(
        context,
        listen: false,
      ).changePersonalDetailsCurrentUser(
        firstName: firstName,
        lastName: lastName,
        country: countryValue,
        city: cityValue,
        municipality: municipalityValue,
        phone: _phone,
        imageUrl: imageUrl,
        backgroundImageUrl: backgrounUrl,
      );
      setState(() {
        userName = "${firstName} ${lastName}";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar informações pessoais: $e')),
      );
    }

    setState(() {
      _isLoading = false;
      _isEditingName = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: widget.user != null,
      appBar:
          widget.user == null
              ? AppBar(
                centerTitle: false,
                title: Text(userName!, style: TextStyle(fontSize: 20)),
                actions: [
                  Stack(
                    children: [
                      TextButton(
                        onPressed:
                            () => setState(() => _isEditing = !_isEditing),
                        child: Text(
                          _isEditing ? "Voltar" : "Editar Perfil",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
              : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image:
                              _backgroundImage != null && user != null
                                  ? DecorationImage(
                                    image: FileImage(_backgroundImage!),
                                    fit: BoxFit.cover,
                                  )
                                  : (user!.backgroundUrl?.isNotEmpty ?? false)
                                  ? DecorationImage(
                                    image: NetworkImage(user!.backgroundUrl!),
                                    fit: BoxFit.cover,
                                  )
                                  : const DecorationImage(
                                    image: AssetImage(
                                      'assets/images/background_logo.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: TextButton(
                            onPressed: () {
                              _isEditingBackgroundImage = true;
                              _pickImage();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(
                              _backgroundImage == null
                                  ? "Definir imagem"
                                  : "Mudar imagem",
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.tertiaryFixed,
                              ),
                            ),
                          ),
                        ),
                      Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.18,
                            ),
                            child: Center(
                              child: CircleAvatar(
                                radius: 80,
                                backgroundImage:
                                    _profileImage != null
                                        ? FileImage(_profileImage!)
                                        : (user!.imageUrl.isNotEmpty)
                                        ? NetworkImage(user!.imageUrl)
                                            as ImageProvider
                                        : const AssetImage(
                                          'assets/images/default_user.png',
                                        ),
                              ),
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 5,
                              left: MediaQuery.of(context).size.width * 0.30,
                              child: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                child: IconButton(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.photo_camera),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _isEditing
                      ? getEditingProfile()
                      : getOnlyViewingProfile(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding getEditingProfile() {
    final phone = user!.phone.split(" ").last;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 25),
      child: Column(
        children: [
          _buildTextField(
            "Primeiro Nome",
            user!.firstName,
            (val) => setState(() {
              firstName = val;
              _dataChanged = true;
            }),
          ),
          _buildTextField(
            "Último Nome",
            user!.lastName,
            (val) => setState(() {
              lastName = val;
              _dataChanged = true;
            }),
          ),

          _buildTextField(
            "Sobre mim",
            user!.aboutMe ?? "",
            (val) => setState(() {
              aboutMe = val;
              _dataChanged = true;
            }),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Localidade",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Container(
            color: Theme.of(context).colorScheme.secondary,
            child: SelectState(
              dropdownColor: Theme.of(context).colorScheme.secondary,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.tertiaryFixed,
              ),

              onCountryChanged: (value) {
                setState(() {
                  _dataChanged = true;
                  countryValue = value.split(" ").last;
                });
              },
              onStateChanged: (value) {
                setState(() {
                  _dataChanged = true;
                  municipalityValue = value;
                });
              },
              onCityChanged: (value) {
                setState(() {
                  _dataChanged = true;
                  cityValue = value;
                });
              },
            ),
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Número de telefone",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          IntlPhoneField(
            initialCountryCode: _countryCode,
            initialValue: phone,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.secondary,
            ),
            onChanged: (phone) {
              _dataChanged = true;
              _countryCode = phone.countryCode;
              _phone = _countryCode + " " + phone.number;
            },
          ),

          if (_dataChanged)
            (_isLoading)
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: () async {
                    await _submit();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Alterações guardadas com sucesso!'),
                      ),
                    );
                    setState(() {
                      _dataChanged = false;
                    });
                  },
                  child: const Text('Guardar Alterações'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),

          SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _customButton("Alterar E-mail", () {
                  navigateToSettings(5);
                }),
              ),
              Expanded(
                child: _customButton("Gerir dados\n de pagamento", () {
                  navigateToSettings(2);
                }, isPrimary: true),
              ),
              Expanded(
                child: _customButton("Alterar Senha", () {
                  navigateToSettings(5);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void navigateToSettings(int index) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(AppRoutes.SETTINGS_PAGE);
    Provider.of<SettingsNotifier>(context, listen: false).setIndex(index);
  }

  Column getOnlyViewingProfile(BuildContext context) {
    final currentUser = AuthService().currentUser!;
    final otherUser = user!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${user!.firstName} ${user!.lastName} ${user!.isProducer ? "🧑‍🌾" : ""}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            if (!user!.isProducer) Icon(FontAwesomeIcons.person),
          ],
        ),
        Text(
          '📍${user!.city}',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondaryFixed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user!.phone.startsWith('+351')
              ? '+351 ' +
                  user!.phone
                      .substring(5)
                      .replaceAllMapped(
                        RegExp(r'.{1,3}'),
                        (match) => '${match.group(0)} ',
                      )
                      .trim()
              : user!.phone
                  .replaceAllMapped(
                    RegExp(r'.{1,3}'),
                    (match) => '${match.group(0)} ',
                  )
                  .trim(),
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.secondaryFixed,
            fontStyle: FontStyle.italic,
          ),
        ),
        if (user!.isProducer &&
            (user as ProducerUser).stores.isNotEmpty &&
            widget.user != null) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Banca${(user as ProducerUser).stores.length > 1 ? "s" : ""}:",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 5),
          ...(user as ProducerUser).stores
              .map(
                (store) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => StorePage(store: store),
                              ),
                            ),
                        leading: Container(
                          width: 75,
                          height: 75,
                          child: Image(
                            image: NetworkImage(store.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),

                        title: AutoSizeText(
                          store.name!,
                          style: TextStyle(fontSize: 18),
                        ),
                        subtitle: AutoSizeText(
                          "📍 ${store.city!}",
                          style: TextStyle(fontSize: 18),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right_outlined),
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              )
              .toList(),
        ],
        const SizedBox(height: 10),

        if (otherUser.id != currentUser.id)
          SendMessageButton(otherUser: otherUser, isIconButton: false),
        const SizedBox(width: 16),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sobre mim',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user!.aboutMe == null || user!.aboutMe!.isEmpty
                          ? 'Ainda sem descrição...'
                          : user!.aboutMe!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondaryFixed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (user != null && user!.isProducer) ...[
                Text(
                  "Produtos em destaque",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children:
                      (user as ProducerUser).stores
                          .expand(
                            (store) =>
                                store.productsAds?.map(
                                  (ad) => {'ad': ad, 'store': store},
                                ) ??
                                [],
                          )
                          .where(
                            (map) =>
                                map != null &&
                                (map as Map)['ad']?.highlightType != null,
                          )
                          .map((map) {
                            final ad = (map as Map)['ad'] as ProductAd;
                            final producer = Provider.of<AuthNotifier>(
                              context,
                              listen: false,
                            ).producerUsers.firstWhereOrNull(
                              (producer) => producer.stores.any(
                                (store) =>
                                    store.productsAds?.any(
                                      (a) => a.id == ad.id,
                                    ) ??
                                    false,
                              ),
                            );
                            final store = map['store'] as Store;
                            return InkWell(
                              onTap:
                                  () =>
                                      (widget.user != null)
                                          ? Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (ctx) =>
                                                      ProductAdDetailScreen(
                                                        ad: ad,
                                                        producer: producer!,
                                                      ),
                                            ),
                                          )
                                          : null,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border:
                                                ad.highlightType != null
                                                    ? Border.all(
                                                      color:
                                                          Colors.amber.shade700,
                                                      width: 5,
                                                    )
                                                    : null,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.network(
                                              ad.product.imageUrls.first,
                                              height: 100,
                                              width: 120,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) => Container(
                                                    height: 100,
                                                    width: 120,
                                                    color: Colors.grey.shade300,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        if (ad.highlightType != null)
                                          Positioned(
                                            top: -5,
                                            left: 0,
                                            child: Chip(
                                              backgroundColor:
                                                  Colors.amber.shade700,
                                              label: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    widget.user != null
                                                        ? "Destacado"
                                                        : ad.highlightType! ==
                                                            HighlightType.HOME
                                                        ? "Pagina Principal"
                                                        : "Pesquisa",
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 0,
                                                    vertical: 0,
                                                  ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ad.product.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  ad.description,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (store.imageUrl != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 6.0,
                                                      ),
                                                  child: CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage:
                                                        NetworkImage(
                                                          store.imageUrl!,
                                                        ),
                                                    backgroundColor:
                                                        Colors.grey.shade200,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          Text(
                                            '${ad.product.price}€/${ad.product.unit.toDisplayString()}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                          .toList(),
                ),
              ] else if (orders != null && orders!.isNotEmpty) ...[
                Text(
                  'Últimas compras',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children:
                      orders!.map((order) {
                        final String? firstProductAdId =
                            order.ordersItems.isNotEmpty
                                ? order.ordersItems.first.productAdId
                                : null;

                        ProductAd? matchedProductAd;

                        if (firstProductAdId != null) {
                          for (final user in AuthService().users) {
                            if (user is ProducerUser) {
                              for (final store in user.stores) {
                                try {
                                  final productAd = store.productsAds!
                                      .firstWhere(
                                        (ad) => ad.id == firstProductAdId,
                                      );
                                  matchedProductAd = productAd;
                                  break;
                                } catch (e) {}
                              }
                            }

                            if (matchedProductAd != null) break;
                          }
                        }

                        final AppUser? producerUser = Provider.of<AuthNotifier>(
                          context,
                          listen: false,
                        ).producerUsers.firstWhere(
                          (u) => u.stores.any(
                            (store) => store.id == order.storeId,
                          ),
                        );

                        final producerName =
                            '${producerUser!.firstName} ${producerUser.lastName}';
                        final producerImage = producerUser.imageUrl;
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 8,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (matchedProductAd != null) ...[
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              matchedProductAd
                                                  .product
                                                  .imageUrls
                                                  .first,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${(order.ordersItems.length > 1) ? "${matchedProductAd.product.name} e +${order.ordersItems.length - 1} items" : "${matchedProductAd.product.name}"}",
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'Quantidade: ${matchedProductAd.product.unit == "kg" ? order.ordersItems.first.qty.toStringAsFixed(2) : order.ordersItems.first.qty.toStringAsFixed(0)} ${matchedProductAd.product.unit.toDisplayString()}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .tertiaryFixed,
                                                  ),
                                                ),
                                                Text(
                                                  '${order.totalPrice.toStringAsFixed(2)}€',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .tertiaryFixed,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  if (user != null && !user!.isProducer)
                                    Flexible(
                                      flex: 3,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ProfilePage(producerUser),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Produtor:",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            ClipOval(
                                              child: Image.network(
                                                producerImage,
                                                width: 35,
                                                height: 35,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (_, __, ___) => const Icon(
                                                      Icons.person,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              producerName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.tertiaryFixed,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
