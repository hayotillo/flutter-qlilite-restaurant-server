import '../providers/table.dart';
import '../models/table.dart';
import '../models/record_list.dart';
import '../models/filter.dart';

class TableRepository {
  final _provider = TableProvider();

  Future<TableModel> save(TableModel table) => _provider.save(table);

  Future<RecordList<TableModel>> list(TableListFilter filter) => _provider.list(filter);

  Future<TableModel> one(int id) => _provider.one(id);

  Future<bool> delete(int id) => _provider.delete(id);
}