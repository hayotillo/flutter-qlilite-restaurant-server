import 'package:panoma/domain/models/category.dart';

class Product {
  int id;
  Category category;
  String name;
  int price;

  Product({
    this.id=0,
    this.name='',
    this.price=0,
    Category? category
  }) : category=category ?? Category();

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    price: json['price'],
    category: Category.fromJson({'id': json['category_id'], 'name': json['category_name']}),
  );

  Map<String, dynamic> get json => {'id': id, 'name': name, 'price': price, 'category': category.json};

  bool get exists => id > 0;
}