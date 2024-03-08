class OrderItem {
  int orderId;
  int productId;
  String productName;
  int count;
  int sum;

  OrderItem({
    this.orderId=0,
    this.productId=0,
    this.productName='',
    this.count=0,
    this.sum=0,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderId: json['order_id'],
      productId: json['product_id'],
      productName: json['product_name'] ?? '',
      count: json['count'],
      sum: json['sum'],
    );
  }

  Map<String, dynamic> get json {
    final result = {
      'order_id': orderId,
      'product_id': productId,
      'count': count,
      'sum': sum,
    };

    return result;
  }

  bool get exists => orderId > 0 && productId > 0 && count > 0;
  int get price => sum > 0 && count > 0 ? (sum / count).round() : 0;

  void increment() {
    sum = price;
    count++;
    sum = sum * count;
  }

  void decrement() {
    sum = price;
    count--;
    sum = sum * count;
  }
}