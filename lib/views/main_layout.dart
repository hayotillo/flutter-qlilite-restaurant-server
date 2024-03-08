import 'package:flutter/material.dart';
import 'package:panoma/domain/states/title.dart';
import 'package:panoma/views/order_detail.dart';
import 'package:panoma/views/sale.dart';
import 'package:provider/provider.dart';
import '../domain/states/order.dart';
import '../domain/states/search.dart';
import 'home.dart';
import 'orders.dart';

class MainLayout extends StatelessWidget {
  final int pageIndex;
  const MainLayout({Key? key, this.pageIndex=0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _MainLayout(pageIndex: pageIndex,);
  }
}


class _MainLayout extends StatefulWidget {
  final int pageIndex;
  const _MainLayout({Key? key, required this.pageIndex}) : super(key: key);

  @override
  State<_MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<_MainLayout> {
  int _pageIndex = 0;
  Widget _page = const Home();


  @override
  void initState() {
    super.initState();
    pageIndex = widget.pageIndex;
  }

  set pageIndex(int value) {
    _pageIndex = value;
    _loadPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<TitleState>().title),
      ),
      body: _page,
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Panoma', style: TextStyle(color: Colors.white),),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              selected: _pageIndex == 0,
              onTap: () {
                pageIndex = 0;
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Orders'),
              selected: _pageIndex == 2,
              onTap: () {
                pageIndex = 2;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _loadPage() {
    var title = 'Home';
    switch(_pageIndex) {
      case 1:
        _page = const Sale();
        title = 'Sale';
        break;
      case 2:
        _page = const Orders();
        title = 'Orders';
        break;
      case 3:
        _page = const OrderDetail();
        title = 'Order detail';
        break;
      default:
        _page = const Home();
    }
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<TitleState>().add(title, index: 0);
    });
    setState(() {});
  }
}