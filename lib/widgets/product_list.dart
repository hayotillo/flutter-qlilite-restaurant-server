import 'package:flutter/material.dart';
import 'package:panoma/domain/models/filter.dart';
import 'package:panoma/domain/repositories/order.dart';
import 'package:panoma/domain/states/order.dart';
import 'package:panoma/widgets/category_list.dart';
import 'package:panoma/widgets/order_list.dart';
import 'package:provider/provider.dart';

import '../domain/models/order_item.dart';
import '../domain/models/product.dart';
import '../domain/repositories/product.dart';
import '../domain/states/search.dart';

class _ViewModel extends ChangeNotifier {
  final _productRepository = ProductRepository();
  final _listController = ScrollController();
  final List<Product> _items = [];
  final Map<String, String> _orders = {};
  var _page = 1;
  var _categoryId = 0;
  var _orderId = 0;
  var _hasNextPage = false;
  var _search = '';

  _ViewModel() {
    _listController.addListener(() {
      final position = _listController.position;
      if (position.maxScrollExtent <= position.pixels) {
        if (_hasNextPage) {
          _hasNextPage = false;
          _page++;
        }
      }
    });

    loadData();
  }

  List<Product> get items => _items;
  Map<String, String> get orders => _orders;
  ScrollController get listController => _listController;

  void search(String search) {
    _search = search;
    _page = 1;
    loadData();
  }

  void loadData() {
    final filter = ProductListFilter(
      list: ListFilter(page: _page, search: _search),
      product: ProductFilter(categoryId: _categoryId, orderId: _orderId)
    );
    _productRepository.list(filter).then((value){
      if (_page < 2) {
        _items.clear();
      }
      _items.addAll(value.items);
      _hasNextPage = value.hasNextPage;
      notifyListeners();
    });
  }

  void changeCategory(int categoryId) {
    _categoryId = categoryId;
    loadData();
  }
}

class ProductList extends StatelessWidget {
  const ProductList({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=>_ViewModel(),
      child: const _ProductList(),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = context.watch<_ViewModel>().items;
    final listController = context.read<_ViewModel>().listController;
    final changeCategory = context.read<_ViewModel>().changeCategory;
    final loadData = context.watch<_ViewModel>().loadData;
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<SearchState>().setCallback('products', context.read<_ViewModel>().search);
    });
    return Column(
      children: [
        // category list
        CategoryList(callback: changeCategory,),
        const Divider(height: 15, color: Colors.grey, thickness: 1, indent: 10, endIndent: 10,),
        Expanded(
          child: RefreshIndicator(
            onRefresh: ()async=>loadData,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 0, crossAxisSpacing: 0
              ),
              itemCount: items.length,
              controller: listController,
              itemBuilder: (_, index){
                final item = items.elementAt(index);
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue, width: 2)
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(5),
                  child: TextButton(
                    onPressed: ()=>context.read<OrderState>().addProduct(item),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.price.toString()),
                        Text(item.name),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
