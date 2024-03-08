import 'package:flutter/material.dart';
import 'package:panoma/domain/models/filter.dart';
import 'package:panoma/domain/states/title.dart';
import 'package:provider/provider.dart';
import '../domain/models/order_item.dart';
import '../domain/repositories/order.dart';
import '../domain/states/order.dart';
import '../domain/states/search.dart';

class _ViewModel extends ChangeNotifier {
  final _orderRepository = OrderRepository();
  final _listController = ScrollController();
  final List<OrderItem> _items = [];
  final Map<String, String> _orders = {};
  var _page = 1;
  var _tableId = 0;
  var _orderId = 0;
  var _hasNextPage = false;
  var _search = '';
  var _priceSum = 0;

  _ViewModel({int tableId=0, int orderId=0}) {
    _orderId = orderId;
    _tableId = tableId;

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

  List<OrderItem> get items => _items;
  Map<String, String> get orders => _orders;
  ScrollController get listController => _listController;
  int get priceSum => _priceSum;

  void search(String search) {
    print('search $search');
    _search = search;
    _page = 1;
    loadData();
  }

  void addItem(OrderItem orderItem) {
    if (orderItem.count == 0) {
      try {
        final match = _items.firstWhere((e) => e.productId == orderItem.productId);
        orderItem.count = match.count;
      } catch(e){ e.toString(); }
    }
    if (orderItem.orderId > 0) {
      var index = _items.indexWhere((e) => e.productId == orderItem.productId);
      _orderRepository.addItem(orderItem).then((value){
        if (value.exists) {
          if (index != -1) {
            _items.removeAt(index);
          } else {
            index = 0;
          }
          _items.insert(index, value);
          notifyListeners();
          loadPriceSum();
        }
      });
    }
  }

  void deleteItem(int orderId, int productId) {
    if (orderId > 0 && productId > 0) {
      _orderRepository.deleteItem(orderId, productId).then((value){
        if (value) {
          _items.removeWhere((e) => e.productId == productId);
          notifyListeners();
          loadPriceSum();
        }
      });
    }
  }

  void removeItem(int orderId, int productId) {
    if (orderId > 0 && productId > 0) {
      _orderRepository.removeItem(orderId, productId).then((value){
        if (value.exists) {
          final index = _items.indexWhere((e) => e.productId == productId);
          _items[index] = value;
          notifyListeners();
          loadPriceSum();
        }
      });
    }
  }

  void loadData() {
    final filter = OrderItemListFilter(
      list: ListFilter(page: _page, search: _search),
      order: OrderItemFilter(tableId: _tableId, orderId: _orderId),
    );
    _orderRepository.itemList(filter).then((value){
      if (_page < 2) {
        _items.clear();
      }
      _items.addAll(value.items);
      _hasNextPage = value.hasNextPage;
      loadPriceSum();
      notifyListeners();
    });
  }

  void loadPriceSum() {
    _orderRepository.itemsPriceSum(tableId: _tableId, orderId: _orderId).then((value){
      _priceSum = value;
      notifyListeners();
    });
  }
}

class OrderItemList extends StatelessWidget {
  const OrderItemList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tableId = context.watch<OrderState>().tableId;
    final orderId = context.watch<OrderState>().orderId;
    return ChangeNotifierProvider(
      create: (_)=>_ViewModel(tableId: tableId, orderId: orderId),
      child: const _PriceSumState(priceSum: 0, children: _ProxyPriceSum(),),
    );
  }
}

class _ProxyPriceSum extends StatelessWidget {
  const _ProxyPriceSum({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priceSum = context.watch<_ViewModel>().priceSum;
    return _PriceSumState(priceSum: priceSum, children: const _OrderItemList(),);
  }
}

class _PriceSumState extends InheritedWidget {
  final Widget children;
  final int priceSum;
  const _PriceSumState({Key? key, required this.children, this.priceSum=0}) : super(key: key, child: children);

  static _PriceSumState? of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<_PriceSumState>());
  }

  @override
  bool updateShouldNotify(_PriceSumState oldWidget) {
    return priceSum != oldWidget.priceSum;
  }
}

class _OrderItemList extends StatelessWidget {
  const _OrderItemList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<OrderState>().setAddItemCallback((value) => context.read<_ViewModel>().addItem(value));
    final items = context.watch<_ViewModel>().items;
    final listController = context.watch<_ViewModel>().listController;
    final addItem = context.read<_ViewModel>().addItem;
    final removeItem = context.read<_ViewModel>().removeItem;
    final deleteItem = context.read<_ViewModel>().deleteItem;
    final loadData = context.watch<_ViewModel>().loadData;
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<SearchState>().setCallback('order-items', context.read<_ViewModel>().search);
      context.read<TitleState>().add(
          'Sum: ${context.read<_ViewModel>().priceSum.toString()}',
          index: 2
      );
    });
    return RefreshIndicator(
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
            height: 70,
            margin: const EdgeInsets.only(left: 5, right: 5, bottom: 3, top: 3),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('name: '),
                            Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('price: '),
                            Text(
                              '${item.price} x ${item.count} = ${item.sum}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('count: '),
                            Text(item.count.toString(), style: const TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: ()=>deleteItem(item.orderId, item.productId),
                          icon: const Icon(Icons.delete_forever_outlined)
                      )
                    ],
                  ),
                  const SizedBox(width: 20,),
                  Row(
                    children: [
                      IconButton(
                          onPressed: ()=>removeItem(item.orderId, item.productId),
                          icon: const Icon(Icons.remove_circle_outline_outlined)
                      )
                    ],
                  ),
                  const SizedBox(width: 20,),
                  Row(
                    children: [
                      IconButton(
                          onPressed: ()=>addItem(item),
                          icon: const Icon(Icons.add_circle_outline_outlined)
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
