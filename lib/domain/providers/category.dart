import 'sqlite.dart';
import '../models/category.dart';
import '../models/filter.dart';
import '../models/record_list.dart';

class CategoryProvider {
  final _sqliteProvider = SQLiteProvider();
  
  Future<Category> save(Category category) async {
    var result = Category();

    final db = await _sqliteProvider.initDB();
    if (category.exists) {
      final count = await db.update('categories', category.json);
      if (count > 0) {
        result = category;
      }
    } else {
      category.id = await db.insert('categories', category.json);
      result = category;
    }

    return result;
  }

  Future<RecordList<Category>> list(CategoryListFilter filter) async {
    var result = RecordList<Category>(items: [], hasNextPage: false);
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

    final db = await _sqliteProvider.initDB();
    var query = """SELECT id, name FROM categories""";

    if (where.isNotEmpty) {
      query += ' WHERE ${where.replaceFirst('AND ', '')}';
    }
    query += ' LIMIT ${filter.list.per} OFFSET ${filter.list.offset}';
    final List<Map<String, dynamic>> queryResult = await db.rawQuery(
      query,
      whereArgs,
    );
    result.items = queryResult.map((e)=>Category.fromJson(e)).toList();

    int count = 0;
    if (queryResult.isNotEmpty) {
      count = int.tryParse(queryResult.first['count'].toString()) ?? 0;
    }
    result.hasNextPage = (count / filter.list.per) > filter.list.page;

    return result;
  }

  Future<Category> one(int id) async {
    var result = Category();

    final db = await _sqliteProvider.initDB();
    if (id > 0) {
      final List<Map<String, dynamic>> queryResult = await db.rawQuery(
          'SELECT id, name FROM categories WHERE id=?',
          [id]
      );
      result = Category.fromJson(queryResult.first);
    }

    return result;
  }

  Future<bool> delete(int id) async {
    var result = false;

    final db = await _sqliteProvider.initDB();
    if (id > 0) {
      final count = await db.delete('categories', where: 'id=?', whereArgs: [id]);
      result = count > 0;
    }

    return result;
  }
}