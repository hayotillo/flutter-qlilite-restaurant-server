import 'package:panoma/domain/models/filter.dart';
import 'package:panoma/domain/providers/product.dart';
import '../models/product.dart';
import '../models/record_list.dart';

class ProductRepository {
  final _provider = ProductProvider();

  Future<Product> save(Product product) => _provider.save(product);

  Future<RecordList<Product>> list(ProductListFilter filter) => _provider.list(filter);

  Future<Product> one(int id) => _provider.one(id);

  Future<bool> delete(int id) => _provider.delete(id);
}