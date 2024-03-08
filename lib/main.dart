import 'package:flutter/material.dart';
import 'package:panoma/domain/states/order.dart';
import 'package:panoma/views/home.dart';
import 'package:panoma/views/main_layout.dart';
import 'package:panoma/views/sale.dart';
import 'package:panoma/views/orders.dart';
import 'package:provider/provider.dart';

import 'domain/states/search.dart';
import 'domain/states/title.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>OrderState()),
        ChangeNotifierProvider(create: (_)=>SearchState()),
        ChangeNotifierProvider(create: (_)=>TitleState()),
      ],
      child: MaterialApp(
        title: 'Panoma',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainLayout(),
      ),
    );
  }
}

