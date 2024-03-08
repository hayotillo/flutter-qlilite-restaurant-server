import 'sqlite.dart';
import '../models/filter.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/record_list.dart';
import '../models/table.dart';

class OrderProvider {
  final _sqliteProvider = SQLiteProvider();

  Future<Order> save(Order order) async {
    var result = Order();

    final db = await _sqliteProvider.initDB();
    if (order.exists) {
      final count = await db.update('orders', order.json);
      if (count > 0) {
        result = order;
      }
    } else {
      order.id = await db.insert('orders', order.json);
      result = order;
    }

    return result;
  }

  Future<RecordList<Order>> list(OrderListFilter filter) async {
    var result = RecordList<Order>(items: [], hasNextPage: false);
    String orderBy = '';
    String where = '';
    List<dynamic> whereArgs = [];
    for (final order in (filter.list.orders ?? {}).entries) {
      orderBy += '${order.key} ${order.value ? 'DESC' : 'ASC'}, ';
    }
    if (orderBy.isNotEmpty) {
      orderBy = orderBy.substring(0, orderBy.length-2);
    } else {
      orderBy = 'name ASC';
    }

    if (filter.order.tableId > 0) {
      where = '$where AND o.table_id=?';
      whereArgs.add(filter.order.tableId);
    }

    final db = await _sqliteProvider.initDB();
    var query = """SELECT
      o.id,
      o.table_id,
      t.name as table_name,
      o.status,
      sum(oi.sum) as price_sum
    FROM orders o
      JOIN tables t ON t.id=o.table_id
      JOIN order_items oi ON o.id=oi.order_id""";

    if (filter.list.search.isNotEmpty) {
      where = "$where AND LOWER(t.name) LIKE '%${filter.list.search.toLowerCase()}%'";
    }

    if (where.isNotEmpty) {
      query += ' WHERE ${where.replaceFirst(' AND ', '')}';
    }
    query += ' GROUP BY o.id, t.id, oi.order_id LIMIT ${filter.list.per} OFFSET ${filter.list.offset}';
    final List<Map<String, dynamic>> queryResult = await db.rawQuery(
      query,
      whereArgs,
    );
    result.items = queryResult.map((e)=>Order.fromJson(e)).toList();

    int count = 0;
    if (queryResult.isNotEmpty) {
      count = int.tryParse(queryResult.first['count'].toString()) ?? 0;
    }
    result.hasNextPage = (count / filter.list.per) > filter.list.page;

    return result;
  }

  Future<Order> current(int tableId) async {
    var result = Order();

    final db = await _sqliteProvider.initDB();
    var query = """SELECT
      o.id,
      o.table_id,
      t.name as table_name,
      o.status
    FROM orders o
    JOIN tables t ON t.id=o.table_id
    WHERE status='process' AND table_id=?""";

    List<Map<String, dynamic>> queryResult = await db.rawQuery(query, [tableId]);
    if (queryResult.isNotEmpty) {
      result = Order.fromJson(queryResult.first);
    } else {
      result = await save(Order(tableId: tableId, status: 'process'));
    }

    return result;
  }

  // order item
  Future<OrderItem> itemSave(OrderItem orderItem) async {
    var result = OrderItem();

    final db = await _sqliteProvider.initDB();
    if (orderItem.exists) {
      final count = await db.update('order_items', orderItem.json);
      if (count > 0) {
        result = orderItem;
      }
    } else {
      await db.insert('order_items', orderItem.json);
      result = orderItem;
    }

    return result;
  }

  Future<RecordList<OrderItem>> itemList(OrderItemListFilter filter) async {
    var result = RecordList<OrderItem>(items: [], hasNextPage: false);
    String orderBy = '';
    String where = '';
    List<dynamic> whereArgs = [];
    for (final order in (filter.list.orders ?? {}).entries) {
      orderBy += '${order.key} ${order.value ? 'DESC' : 'ASC'}, ';
    }
    if (orderBy.isNotEmpty) {
      orderBy = orderBy.substring(0, orderBy.length-2);
    } else {
      orderBy = 'oi.name ASC';
    }

    if (filter.order.tableId > 0) {
      where = '$where AND o.table_id=?';
      whereArgs.add(filter.order.tableId);
    }

    if (filter.order.orderId > 0) {
      where = '$where AND oi.order_id=?';
      whereArgs.add(filter.order.orderId);
    }

    if (filter.list.search.isNotEmpty) {
      final s = filter.list.search.toLowerCase();
      where = " AND LOWER(p.name) LIKE '%$s%'$where OR oi.sum LIKE '%$s%'$where";
    }

    final db = await _sqliteProvider.initDB();
    var query = """SELECT
      oi.order_id,
      oi.product_id,
      p.name as product_name,
      oi.sum,
      oi.count
    FROM order_items oi
      JOIN orders o ON o.id=oi.order_id
      JOIN products p ON p.id=oi.product_id""";

    if (where.isNotEmpty) {
      query += ' WHERE ${where.replaceFirst(' AND ', '')}';
    }

    query += ' LIMIT ${filter.list.per} OFFSET ${filter.list.offset}';
    final List<Map<String, dynamic>> queryResult = await db.rawQuery(
      query,
      whereArgs,
    );
    result.items = queryResult.map((e)=>OrderItem.fromJson(e)).toList();

    int count = 0;
    if (queryResult.isNotEmpty) {
      count = int.tryParse(queryResult.first['count'].toString()) ?? 0;
    }
    result.hasNextPage = (count / filter.list.per) > filter.list.page;

    return result;
  }

  Future<int> itemsPriceSum(int tableId, int orderId) async{
    var result = 0;
    final db = await _sqliteProvider.initDB();

    final List<int> args = [];
    var query = """SELECT sum(oi.sum) as sum FROM orders o JOIN order_items oi ON o.id=oi.order_id
        WHERE o.status='process'""";
    if (orderId > 0) {
      args.add(orderId);
      query = '$query AND o.id=?';
    }
    if (tableId > 0) {
      args.add(tableId);
      query = '$query AND o.table_id=?';
    }
    final List<Map<String, dynamic>> queryResult = await db.rawQuery(query, args);

    if (queryResult.isNotEmpty) {
      result = int.tryParse(queryResult.first['sum'].toString()) ?? 0;
    }

    return result;
  }

  Future<bool> itemDelete(int id) async {
    var result = false;

    final db = await _sqliteProvider.initDB();
    if (id > 0) {
      final count = await db.delete('order_items', where: 'id=?', whereArgs: [id]);
      result = count > 0;
    }

    return result;
  }

  Future<OrderItem> addItem(OrderItem orderItem) async{
    var result = OrderItem();

    if (orderItem.orderId > 0 && orderItem.productId > 0) {
      final db = await _sqliteProvider.initDB();
      // get item by product
      List<Map<String, dynamic>> queryResult = await db.rawQuery(
        """SELECT order_id, product_id, sum, count FROM order_items
        WHERE order_id=? AND product_id=?""",
        [orderItem.orderId, orderItem.productId]
      );
      // update order item if exists
      if (queryResult.isNotEmpty) {
        final update = OrderItem.fromJson(queryResult.first);
        update.increment();
        await db.update(
          'order_items',
          update.json,
          where: 'order_id=? AND product_id=?',
          whereArgs: [update.orderId, update.productId],
        );
      } else {
        orderItem.count = 1;
        await db.insert('order_items', orderItem.json);
      }
      // select updated or insert item
      queryResult = await db.rawQuery("""SELECT
        oi.order_id,
        oi.product_id,
        p.name as product_name,
        oi.sum,
        oi.count
        FROM order_items oi
          JOIN products p ON p.id=oi.product_id
        WHERE order_id=? AND product_id=?""",
        [orderItem.orderId, orderItem.productId],
      );
      if (queryResult.isNotEmpty) {
        result = OrderItem.fromJson(queryResult.first);
      }
    }

    return result;
  }

  Future<bool> deleteItem(int orderId, int productId) async{
    if (orderId > 0 && productId > 0) {
      final db = await _sqliteProvider.initDB();
      final count = await db.delete(
        'order_items',
        where: 'order_id=? AND product_id=?',
        whereArgs: [orderId, productId],
      );
      return count > 0;
    }

    return false;
  }

  Future<OrderItem> removeItem(int orderId, int productId) async{
    if (orderId > 0 && productId > 0) {
      final db = await _sqliteProvider.initDB();
      // get item by product
      List<Map<String, dynamic>> queryResult = await db.rawQuery(
        """SELECT
          oi.order_id,
          oi.product_id,
          p.name as product_name,
          oi.sum,
          oi.count
        FROM order_items oi
          JOIN products p ON p.id=oi.product_id
        WHERE order_id=? AND product_id=?""",
        [orderId, productId]
      );
      // update order item if exists
      if (queryResult.isNotEmpty) {
        final update = OrderItem.fromJson(queryResult.first);
        update.decrement();
        final count = await db.update(
          'order_items',
          update.json,
          where: 'order_id=? AND product_id=?',
          whereArgs: [update.orderId, update.productId],
        );
        return count > 0 ? update : OrderItem();
      }
    }

    return OrderItem();
  }
}