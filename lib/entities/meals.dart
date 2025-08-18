class Meals {
  final String name;
  final double carbs;
  final double protein;
  final double fat;

  Meals({
    required this.name,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'carbs': carbs, 'protein': protein, 'fat': fat};
  }

  factory Meals.fromMap(Map<String, dynamic> map) {
    return Meals(
      name: map['name'],
      carbs: (map['carbs'] ?? 0).toDouble(),
      protein: (map['protein'] ?? 0).toDouble(),
      fat: (map['fat'] ?? 0).toDouble(),
    );
  }
}
