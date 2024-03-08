import 'package:panoma/domain/models/filter.dart';
import 'package:panoma/domain/models/order_item.dart';
import 'package:panoma/domain/providers/order.dart';
import '../models/order.dart';
import '../models/record_list.dart';

class OrderRepository {
  final _provider = OrderProvider();

  Future<Order> save(Order order) => _provider.save(order);

  Future<Order> current(tableId) => _provider.current(tableId);

  Future<RecordList<Order>> list(OrderListFilter filter) => _provider.list(filter);

  Future<RecordList<OrderItem>> itemList(OrderItemListFilter filter) => _provider.itemList(filter);

  Future<int> itemsPriceSum({int tableId=0, int orderId=0}) => _provider.itemsPriceSum(tableId, orderId);

  Future<OrderItem> addItem(OrderItem orderItem) => _provider.addItem(orderItem);

  Future<bool> deleteItem(int orderId, int productId) => _provider.deleteItem(orderId, productId);

  Future<OrderItem> removeItem(int orderId, int productId) => _provider.removeItem(orderId, productId);
}