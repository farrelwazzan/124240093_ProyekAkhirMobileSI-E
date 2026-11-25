import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/location_provider.dart';
import '../providers/restaurant_provider.dart';
import '../utils/distance_helper.dart';
import 'restaurant_detail_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() =>
      _RestaurantListScreenState();
}

class _RestaurantListScreenState
    extends State<RestaurantListScreen> {
  Category selectedCategory = Category.all;

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final restaurantProvider = context.watch<RestaurantProvider>();

    final position = locationProvider.position;

    final restaurants = restaurantProvider.restaurants
        .where((restaurant) {
      return selectedCategory.id == 'all' ||
          restaurant.category.id == selectedCategory.id;
    }).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Daftar Kuliner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Filter kategori
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: Category.available.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = Category.available[index];

                return ChoiceChip(
                  label: Text(category.name),
                  selected:
                      selectedCategory.id == category.id,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Daftar restoran
          Expanded(
            child: Builder(
              builder: (context) {
                if (locationProvider.isLoading ||
                    restaurantProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (locationProvider.error != null) {
                  return Center(
                    child: Text(
                      'Gagal mendapatkan lokasi: '
                      '${locationProvider.error}',
                    ),
                  );
                }

                if (restaurantProvider.error != null) {
                  return Center(
                    child: Text(
                      'Gagal mengambil kuliner: '
                      '${restaurantProvider.error}',
                    ),
                  );
                }

                if (restaurants.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada kuliner ditemukan.',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = restaurants[index];

                    final distance = position == null
                        ? null
                        : DistanceHelper.calculateDistance(
                            userLatitude: position.latitude,
                            userLongitude: position.longitude,
                            restaurantLatitude:
                                restaurant.latitude,
                            restaurantLongitude:
                                restaurant.longitude,
                          );

                    return Card(
                      key: ValueKey(restaurant.id),
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.restaurant),
                        ),
                        title: Text(restaurant.name),
                        subtitle: Text(
                          '${restaurant.category.name}'
                          '${distance == null ? '' : ' • ${DistanceHelper.formatDistance(distance)}'}',
                        ),

                        // Detail akan kita tambahkan pada tahap berikutnya.
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RestaurantDetailScreen(
                                restaurant: restaurant,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
