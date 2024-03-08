import 'package:flutter/material.dart';
import 'package:panoma/domain/models/filter.dart';
import 'package:panoma/domain/models/table.dart';
import 'package:panoma/domain/states/order.dart';
import 'package:panoma/views/main_layout.dart';
import 'package:panoma/views/sale.dart';
import 'package:provider/provider.dart';
import '../domain/repositories/table.dart';

class _ViewModel extends ChangeNotifier {
  final _tableRepository = TableRepository();
  final _listController = ScrollController();
  final List<TableModel> _items = [];
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

  List<TableModel> get items => _items;
  Map<String, String> get orders => _orders;
  ScrollController get listController => _listController;

  void loadData() {
    final filter = TableListFilter(
      list: ListFilter(page: _page,),
    );
    _tableRepository.list(filter).then((value){
      if (_page < 2) {
        _items.clear();
      }
      _items.addAll(value.items);
      _hasNextPage = value.hasNextPage;
      notifyListeners();
    });
  }
}

class TableList extends StatelessWidget {
  const TableList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=>_ViewModel(),
      child: const _TableList(),
    );
  }
}

class _TableList extends StatelessWidget {
  const _TableList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = context.watch<_ViewModel>().items;
    final listController = context.watch<_ViewModel>().listController;
    return ListView.builder(
      itemCount: items.length,
      controller: listController,
      itemBuilder: (_, index){
        final item = items.elementAt(index);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue, width: 2)
          ),
          width: (MediaQuery.of(context).size.width / 2) -10,
          margin: const EdgeInsets.only(top: 5, bottom: 5),
          child: TextButton(
            onPressed: (){
              context.read<OrderState>().tableId = item.id;
              Navigator.push(context, MaterialPageRoute(builder: (_)=>const MainLayout(pageIndex: 1,)));
            },
            child: Center(child: Text(item.name))
          ),
        );
      },
    );
  }
}
