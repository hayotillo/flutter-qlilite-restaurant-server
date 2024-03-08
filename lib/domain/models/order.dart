import 'order_item.dart';
import 'table.dart';

class Order {
  int id;
  int tableId;
  String tableName;
  String status;
  int priceSum;

  Order({
    this.id=0,
    this.tableId=0,
    this.tableName='',
    this.status='',
    this.priceSum=0
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'],
    tableId: json['table_id'],
    tableName: json['table_name'],
    status: json['status'],
    priceSum: int.tryParse(json['price_sum'].toString()) ?? 0,
  );

  Map<String, dynamic> get json {
    final result = {
      'table_id': tableId,
      'status': status,
    };
    if (id > 0) {
      result.addAll({'id': id});
    }

    return result;
  }

  bool get exists => id > 0;

}