import 'sqlite.dart';
import '../models/filter.dart';
import '../models/record_list.dart';
import '../models/table.dart';

class TableProvider {
  final _provider = SQLiteProvider();

  Future<TableModel> save(TableModel table) async {
    var result = TableModel();

    final db = await _provider.initDB();
    if (table.exists) {
      final count = await db.update('tables', table.json);
      if (count > 0) {
        result = table;
      }
    } else {
      table.id = await db.insert('tables', table.json);
      result = table;
    }

    return result;
  }

  Future<RecordList<TableModel>> list(TableListFilter filter) async {
    var result = RecordList<TableModel>(items: [], hasNextPage: false);
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

    final db = await _provider.initDB();
    var query = """SELECT
      id,
      name,
      (select count(*) from tables) as count
    FROM tables""";

    if (where.isNotEmpty) {
      query += ' WHERE ${where.replaceFirst('AND ', '')}';
    }
    query += ' LIMIT ${filter.list.per} OFFSET ${filter.list.offset}';
    final List<Map<String, dynamic>> queryResult = await db.rawQuery(
      query,
      whereArgs,
    );
    result.items = queryResult.map((e)=>TableModel.fromJson(e)).toList();

    int count = 0;
    if (queryResult.isNotEmpty) {
      count = int.tryParse(queryResult.first['count'].toString()) ?? 0;
    }
    result.hasNextPage = (count / filter.list.per) > filter.list.page;

    return result;
  }

  Future<TableModel> one(int id) async {
    var result = TableModel();

    final db = await _provider.initDB();
    if (id > 0) {
      final List<Map<String, dynamic>> queryResult = await db.rawQuery(
          'SELECT id, name FROM tables WHERE id=?',
          [id]
      );
      result = TableModel.fromJson(queryResult.first);
    }

    return result;
  }

  Future<bool> delete(int id) async {
    var result = false;

    final db = await _provider.initDB();
    if (id > 0) {
      final count = await db.delete('tables', where: 'id=?', whereArgs: [id]);
      result = count > 0;
    }

    return result;
  }
}