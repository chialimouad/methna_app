class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final int userCount;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.userCount = 0,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      userCount: json['userCount'] ?? 0,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'color': color,
        'userCount': userCount,
        'sortOrder': sortOrder,
      };
}
