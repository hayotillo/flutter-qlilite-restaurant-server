import 'package:flutter/material.dart';
import 'package:panoma/domain/states/order.dart';
import 'package:panoma/widgets/order_item_list.dart';
import 'package:panoma/widgets/product_list.dart';
import 'package:panoma/widgets/search_input.dart';
import 'package:provider/provider.dart';

class _ViewModel extends ChangeNotifier {
}

class Sale extends StatelessWidget {
  const Sale({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=>_ViewModel(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)=>OrderState()),
        ],
        child: const _Sale(),
      ),
    );
  }
}

class _Sale extends StatelessWidget {
  const _Sale({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // order list
          SizedBox(
            height: (MediaQuery.of(context).size.height / 2) -55,
              child: Column(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SearchInput(name: 'order-items'),
                  ),
                  Expanded(child: OrderItemList()),
                ],
              )
          ),
          const Divider(height: 5, color: Colors.grey, thickness: 1, indent: 10, endIndent: 10,),
          SizedBox(
            height: (MediaQuery.of(context).size.height / 2) -40,
            child: Column(
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SearchInput(name: 'products'),
                ),
                Expanded(child: ProductList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

