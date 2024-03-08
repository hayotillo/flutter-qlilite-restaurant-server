class TableModel {
  int id;
  String name;

 TableModel({this.id=0, this.name=''});

  factory TableModel.fromJson(Map<String, dynamic> json) => TableModel(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> get json => {'id': id, 'name': name};

  bool get exists => id > 0;
}