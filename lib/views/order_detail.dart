import 'package:flutter/material.dart';
import 'package:panoma/widgets/order_item_list.dart';
import '../widgets/search_input.dart';

class OrderDetail extends StatelessWidget {
  const OrderDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _OrderDetail();
  }
}

class _OrderDetail extends StatelessWidget {
  const _OrderDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: SearchInput(name: 'order-items',),
        ),
        Expanded(child: OrderItemList())
      ],
    );
  }
}
