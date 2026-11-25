class Category {
  final String id;
  final String name;

  const Category({
    required this.id,
    required this.name,
  });

  static const all = Category(
    id: 'all',
    name: 'Semua',
  );

  static const restaurant = Category(
    id: 'restaurant',
    name: 'Restoran',
  );

  static const fastFood = Category(
    id: 'fast_food',
    name: 'Fast Food',
  );

  static const cafe = Category(
    id: 'cafe',
    name: 'Cafe',
  );

  static const foodCourt = Category(
    id: 'food_court',
    name: 'Food Court',
  );

  static const other = Category(
    id: 'other',
    name: 'Lainnya',
  );

  static const List<Category> available = [
    all,
    restaurant,
    fastFood,
    cafe,
    foodCourt,
    other,
  ];

  factory Category.fromOverpassTags(Map<String, dynamic> tags) {
    final amenity = tags['amenity'];

    switch (amenity) {
      case 'restaurant':
        return restaurant;
      case 'fast_food':
        return fastFood;
      case 'cafe':
        return cafe;
      case 'food_court':
        return foodCourt;
      default:
        return other;
    }
  }
}