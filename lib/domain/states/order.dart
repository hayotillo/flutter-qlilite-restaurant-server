import 'package:flutter/material.dart';
import 'package:panoma/domain/models/order.dart';
import 'package:panoma/domain/models/order_item.dart';
import 'package:panoma/domain/repositories/order.dart';

import '../models/product.dart';

class OrderState extends ChangeNotifier {
  final _orderRepository = OrderRepository();
  Function(OrderItem) _addItemCallback = (OrderItem value){};
  static var _tableId = 0;
  static var _orderId = 0;

  void setAddItemCallback(Function(OrderItem) callback) {
    _addItemCallback = callback;
  }

  void addProduct(Product product){
    if (_tableId > 0) {
      final orderItem = OrderItem();
      // save order
      _orderRepository.current(_tableId).then((value){
        orderItem.orderId = value.id;
        orderItem.productId = product.id;
        orderItem.productName = product.name;
        orderItem.sum = product.price;

        _addItemCallback(orderItem);
      });
    }
  }

  set tableId(int value) {
    _tableId = value;
    notifyListeners();
  }
  set orderId(int value) {
    _orderId = value;
    notifyListeners();
  }

  int get tableId => _tableId;
  int get orderId => _orderId;
}