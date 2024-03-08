import 'package:flutter/material.dart';
import 'package:panoma/domain/models/filter.dart';
import 'package:panoma/domain/states/order.dart';
import 'package:panoma/domain/states/search.dart';
import 'package:panoma/views/main_layout.dart';
import 'package:panoma/views/order_detail.dart';
import 'package:provider/provider.dart';
import '../domain/models/category.dart';
import '../domain/models/order.dart';
import '../domain/models/product.dart';
import '../domain/repositories/category.dart';
import '../domain/repositories/order.dart';

class _ViewModel extends ChangeNotifier {
  final _orderRepository = OrderRepository();
  final _listController = ScrollController();
  final List<Order> _items = [];
  final Map<String, String> _orders = {};
  var _page = 1;
  var _tableId = 0;
  var _search = '';
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

  List<Order> get items => _items;
  Map<String, String> get orders => _orders;
  ScrollController get listController => _listController;

  void search(String search) {
    _search = search;
    _page = 1;
    loadData();
  }

  void loadData() {
    final filter = OrderListFilter(
      list: ListFilter(page: _page, search: _search),
      order: OrderFilter(tableId: _tableId),
    );
    _orderRepository.list(filter).then((value){
      if (_page < 2) {
        _items.clear();
      }
      _items.addAll(value.items);
      _hasNextPage = value.hasNextPage;
      notifyListeners();
    });
  }
}

class OrderList extends StatelessWidget {
  const OrderList({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=>_ViewModel(),
      child: const _OrderList(),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = context.watch<_ViewModel>().items;
    final listController = context.watch<_ViewModel>().listController;
    final loadData = context.watch<_ViewModel>().loadData;
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<SearchState>().setCallback('orders', context.read<_ViewModel>().search);
    });
    return Container(
      height: 100,
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: RefreshIndicator(
        onRefresh: ()async=>loadData,
        child: ListView.builder(
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
              margin: const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 5),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: (){
                    context.read<OrderState>().orderId = item.id;
                    context.read<OrderState>().tableId = item.tableId;
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>const MainLayout(pageIndex: 3,)));
                  },
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('table: '),
                              Text(item.tableName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('price: '),
                              Text(item.priceSum.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
