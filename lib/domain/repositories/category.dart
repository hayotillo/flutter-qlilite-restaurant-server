import 'package:panoma/domain/models/filter.dart';
import '../models/category.dart';
import '../models/record_list.dart';
import '../providers/category.dart';

class CategoryRepository {
  final _provider = CategoryProvider();

  Future<Category> save(Category category) => _provider.save(category);

  Future<RecordList<Category>> list(CategoryListFilter filter) => _provider.list(filter);

  Future<Category> one(int id) => _provider.one(id);

  Future<bool> delete(int id) => _provider.delete(id);
}