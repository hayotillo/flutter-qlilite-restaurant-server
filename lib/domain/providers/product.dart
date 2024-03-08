import 'package:panoma/domain/providers/sqlite.dart';
import '../models/filter.dart';
import '../models/product.dart';
import '../models/record_list.dart';

class ProductProvider {
  final _sqliteProvider = SQLiteProvider();
  
  Future<Product> save(Product product) async {
    var result = Product();

    final db = await _sqliteProvider.initDB();
    if (product.exists) {
      final count = await db.update('products', product.json);
      if (count > 0) {
        result = product;
      }
    } else {
      product.id = await db.insert('products', product.json);
      result = product;
    }

    return result;
  }

  Future<RecordList<Product>> list(ProductListFilter filter) async {
    var result = RecordList<Product>(items: [], hasNextPage: false);
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
    if (filter.product.categoryId > 0) {
      where = 'AND category_id=?';
      whereArgs.add(filter.product.categoryId);
    }
    if (filter.product.orderId > 0) {
      where = 'AND order.id=?';
      whereArgs.add(filter.product.orderId);
    }
    if (filter.list.search.isNotEmpty) {
      final s = filter.list.search.toLowerCase();
      where = " AND LOWER(p.name) LIKE '%$s%'$where OR p.price LIKE '%$s%'$where";
    }

    final db = await _sqliteProvider.initDB();
    var query = """SELECT
      p.id,
      p.name,
      p.price,
      c.id as category_id,
      c.name as category_name,
      (select count(*) from products) as count
    FROM products p
    JOIN categories c ON c.id = p.category_id""";

    if (where.isNotEmpty) {
      query += ' WHERE ${where.replaceFirst('AND ', '')}';
    }
    query += ' GROUP BY p.id, c.id';
    query += ' LIMIT ${filter.list.per} OFFSET ${filter.list.offset}';
    final List<Map<String, dynamic>> queryResult = await db.rawQuery(
      query,
      whereArgs,
    );
    result.items = queryResult.map((e)=>Product.fromJson(e)).toList();

    int count = 0;
    if (queryResult.isNotEmpty) {
      count = int.tryParse(queryResult.first['count'].toString()) ?? 0;
    }
    result.hasNextPage = (count / filter.list.per) > filter.list.page;

    return result;
  }

  Future<Product> one(int id) async {
    var result = Product();

    final db = await _sqliteProvider.initDB();
    if (id > 0) {
      final List<Map<String, dynamic>> queryResult = await db.rawQuery(
          'SELECT id, category_id, name, price FROM products WHERE id=?',
          [id]
      );
      result = Product.fromJson(queryResult.first);
    }

    return result;
  }

  Future<bool> delete(int id) async {
    var result = false;

    final db = await _sqliteProvider.initDB();
    if (id > 0) {
      final count = await db.delete('products', where: 'id=?', whereArgs: [id]);
      result = count > 0;
    }

    return result;
  }
}