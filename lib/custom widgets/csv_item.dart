class CsvItem {
  final Map<String, dynamic> data;

  CsvItem(this.data);

  String get id => data['id']?.toString() ?? '';
  String get name => data['name']?.toString() ?? '';
  String get category => data['category']?.toString() ?? '';
  String get subcategory => data['subcategory']?.toString() ?? '';

  // Get any field value
  dynamic getValue(String key) => data[key];

  // Get all keys
  List<String> get keys => data.keys.toList();

  // Search in all text fields
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    return data.values.any(
      (value) => value.toString().toLowerCase().contains(lowerQuery),
    );
  }

  @override
  String toString() => data.toString();
}
