import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:harvestly/components/producer/store_page.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class StoreLocation {
  final LatLng position;
  final String description;
  late AuthNotifier authProvider;

  StoreLocation({required this.position, required this.description});
}

class MapPage extends StatefulWidget {
  final dynamic initialStore;
  const MapPage({super.key, this.initialStore});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentPosition;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? _shopIcon;

  dynamic _selectedStore;

  void _goToStore(LatLng coords) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(coords));
  }

  void _loadMarkers(List producers) {
    final newMarkers = <Marker>{};
    int markerId = 0;

    for (final producer in producers) {
      for (final store in producer.stores) {
        final coords = store.coordinates;
        if (coords != null) {
          newMarkers.add(
            Marker(
              markerId: MarkerId('store_$markerId'),
              position: coords,
              onTap: () {
                setState(() {
                  _selectedStore = store;
                });
                _goToStore(coords);
              },
              icon:
                  _shopIcon ??
                  BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
            ),
          );
          markerId++;
        }
      }
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    _loadMarkers(authNotifier.producerUsers);
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _loadCustomMarker();
  }

  Future<void> _loadCustomMarker() async {
    final BitmapDescriptor bitmap = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/shop.png',
    );
    if (mounted) {
      setState(() {
        _shopIcon = bitmap;
      });
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
      _loadMarkers(authNotifier.producerUsers);
    }
  }

  Future<void> _determinePosition() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));

        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao obter localização: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            _mapController = controller;

            if (widget.initialStore != null &&
                widget.initialStore.coordinates != null) {
              _goToStore(widget.initialStore.coordinates);
              setState(() {
                _selectedStore = widget.initialStore;
              });
            } else {
              _goToStore(_currentPosition!);
            }
          },
          initialCameraPosition: CameraPosition(
            target: _currentPosition!,
            zoom: 14,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _markers,
          onTap: (LatLng position) {
            setState(() {
              _selectedStore = null;
            });
          },
        ),
        if (Navigator.canPop(context))
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: FloatingActionButton.small(
              heroTag: 'backButton',
              onPressed: () => Navigator.pop(context),
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
            ),
          ),

        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                _selectedStore != null
                    ? Card(
                      key: ValueKey(_selectedStore),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Theme.of(context).colorScheme.secondary,
                      shadowColor: Theme.of(
                        context,
                      ).shadowColor.withValues(alpha: 0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundImage:
                                      _selectedStore.imageUrl != null &&
                                              _selectedStore.imageUrl.isNotEmpty
                                          ? NetworkImage(
                                            _selectedStore.imageUrl,
                                          )
                                          : const AssetImage(
                                                'assets/images/simpleLogo.png',
                                              )
                                              as ImageProvider,
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                                  onBackgroundImageError: (_, __) {},
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _selectedStore.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.tertiaryFixed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedStore.description != null &&
                                _selectedStore.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  _selectedStore.description,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryFixed
                                        .withValues(alpha: 0.7),
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: Icon(
                                  Icons.storefront_outlined,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                label: const Text('Ver Banca'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                ),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              StorePage(store: _selectedStore),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
