import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/table_list.dart';

class _ViewModel extends ChangeNotifier {

}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_)=>_ViewModel(),
      child: const _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: const [
          Expanded(
              child: TableList()
          )
        ],
      ),
    );
  }
}

