import 'package:flutter/material.dart';
import 'package:panoma/widgets/order_list.dart';
import 'package:panoma/widgets/search_input.dart';
import 'package:provider/provider.dart';

class _ViewModel extends ChangeNotifier {

}

class Orders extends StatelessWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=>_ViewModel(),
      child: const _Orders(),
    );
  }
}

class _Orders extends StatelessWidget {
  const _Orders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: SearchInput(name: 'orders',),
        ),
        Expanded(child: OrderList())
      ],
    );
  }
}
