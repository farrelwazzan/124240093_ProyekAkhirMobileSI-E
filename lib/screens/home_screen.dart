
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../providers/restaurant_provider.dart';
import '../utils/distance_helper.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onSeeAll;

  const HomeScreen({
    super.key,
    required this.onSeeAll,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!hasLoaded) {
      hasLoaded = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadNearbyRestaurants();
      });
    }
  }

  Future<void> loadNearbyRestaurants() async {
    final locationProvider = context.read<LocationProvider>();
    final restaurantProvider = context.read<RestaurantProvider>();

    if (locationProvider.isLoading ||
        restaurantProvider.isLoading) {
      return;
    }

    await locationProvider.getCurrentLocation();

    final position = locationProvider.position;

    if (position != null) {
      await restaurantProvider.fetchNearbyRestaurants(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final restaurantProvider = context.watch<RestaurantProvider>();

    final position = locationProvider.position;

    // Homepage hanya menampilkan 5 restoran terdekat.
    final nearbyRestaurants =
        restaurantProvider.restaurants.take(5).toList();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadNearbyRestaurants,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location header
              Row(
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lokasi kamu',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          position == null
                              ? 'Mendeteksi lokasi...'
                              : '${position.latitude.toStringAsFixed(5)}, '
                                  '${position.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.person_outline),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Greeting
              const Text(
                'Lagi lapar? 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Temukan kuliner enak di sekitarmu.',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 28),

              // Nearby restaurants
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kuliner di sekitarmu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onSeeAll,
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (locationProvider.isLoading ||
                  restaurantProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (locationProvider.error != null)
                Text(
                  'Gagal mendapatkan lokasi: ${locationProvider.error}',
                )
              else if (restaurantProvider.error != null)
                Text(
                  'Gagal mengambil kuliner: ${restaurantProvider.error}',
                )
              else if (position == null)
                const Text('Lokasi belum tersedia.')
              else if (nearbyRestaurants.isEmpty)
                const Text('Belum ada kuliner di sekitarmu.')
              else
                ...nearbyRestaurants.map((restaurant) {
                  final distance = DistanceHelper.calculateDistance(
                    userLatitude: position.latitude,
                    userLongitude: position.longitude,
                    restaurantLatitude: restaurant.latitude,
                    restaurantLongitude: restaurant.longitude,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.restaurant),
                      ),
                      title: Text(restaurant.name),
                      subtitle: Text(
                        '${restaurant.category.name} • '
                        '${DistanceHelper.formatDistance(distance)}',
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
