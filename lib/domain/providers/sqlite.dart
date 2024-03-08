import 'package:panoma/domain/models/filter.dart';
import 'package:panoma/domain/models/record_list.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../models/table.dart';

class SQLiteProvider {

  Future<Database> initDB() async {
    String path = await getDatabasesPath();
    // print('db path $path');
    return openDatabase(
      join(path, 'database.db'),
      onCreate: (database, version) async {
        // categories
        await database.execute("""create table categories(
            id integer primary key autoincrement,
            name text not null
          )""",);
        await database.execute("""insert into categories (name) values
            ('1 bluda'),
            ('2 bluda')
          """);
        // products
        await database.execute("""create table products(
            id integer primary key autoincrement,
            category_id integer not null,
            name text not null,
            price integer not null
          )""",);
        await database.execute("""insert into products (category_id, name, price)
            values
              (1, 'Tovar 1.1', 120),
              (1, 'Tovar 1.2', 110),
              (1, 'Tovar 1.1', 10),
              (1, 'Tovar 1.2', 11),
              (1, 'Tovar 1.3', 12),
              (1, 'Tovar 1.4', 13),
              (1, 'Tovar 1.5', 14),
              (1, 'Tovar 1.6', 15),
              (1, 'Tovar 1.7', 16),
              (1, 'Tovar 1.8', 17),
              (1, 'Tovar 1.9', 18),
              (1, 'Tovar 1.10', 19),
              (1, 'Tovar 1.11', 20),
              (1, 'Tovar 1.12', 21),
              (2, 'Tovar 2.1', 90),
              (2, 'Tovar 2.2', 75),
              (2, 'Tovar 2.3', 50)
            """,);
        // tables
        await database.execute("""create table tables(
            id integer primary key autoincrement,
            name text not null
          )""");
        await database.execute("""insert into tables (name)
          values
            ('1 stolik'),
            ('2 stolik')""");
        // orders
        await database.execute("""create table orders(
            id integer primary key autoincrement,
            table_id integer not null,
            status text default 'process'
          )""",);
        // order items
        await database.execute("""create table order_items(
            order_id integer not null,
            product_id integer not null,
            sum integer not null,
            count integer not null
          )""",);
      },
      version: 1,
    );
  }
}