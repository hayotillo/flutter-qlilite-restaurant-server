import 'package:flutter/material.dart';
import 'package:panoma/domain/models/filter.dart';
import 'package:provider/provider.dart';
import '../domain/models/category.dart';
import '../domain/models/product.dart';
import '../domain/repositories/category.dart';

class _ViewModel extends ChangeNotifier {
  final _categoryRepository = CategoryRepository();
  final _listController = ScrollController();
  final List<Category> _items = [];
  final Map<String, String> _orders = {};
  var _page = 1;
  var _hasNextPage = false;

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

  List<Category> get items => _items;
  Map<String, String> get orders => _orders;
  ScrollController get listController => _listController;

  void loadData() {
    final filter = CategoryListFilter(
      list: ListFilter(page: _page,),
    );
    _categoryRepository.list(filter).then((value){
      if (_page < 2) {
        _items.clear();
      }
      _items.addAll(value.items);
      _hasNextPage = value.hasNextPage;
      notifyListeners();
    });
  }
}

class CategoryList extends StatelessWidget {
  final Function(int categoryId)? callback;
  const CategoryList({Key? key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=>_ViewModel(),
      child: _CategoryList(callback: callback,),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final Function(int categoryId)? callback;
  const _CategoryList({Key? key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = context.watch<_ViewModel>().items;
    final listController = context.watch<_ViewModel>().listController;
    return Container(
      height: 100,
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: ListView.builder(
        itemCount: items.length,
        controller: listController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index){
          final item = items.elementAt(index);
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 2)
            ),
            width: (MediaQuery.of(context).size.width / 2) -10,
            margin: const EdgeInsets.only(left: 5, right: 5),
            child: TextButton(
              onPressed: callback == null ? null : ()=>callback!(item.id),
              child: Center(child: Text(item.name))
            ),
          );
        },
      ),
    );
  }
}
