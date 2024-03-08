class Category {
  int id;
  String name;

  Category({this.id=0, this.name=''});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: int.tryParse(json['id'].toString()) ?? 0,
    name: json['name'],
  );

  Map<String, dynamic> get json => {'id': id, 'name': name};

  bool get exists => id > 0;
}