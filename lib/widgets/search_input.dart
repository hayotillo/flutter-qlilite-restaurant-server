import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/states/search.dart';

class SearchInput extends StatelessWidget {
  final String name;
  const SearchInput({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      // padding: const EdgeInsets.only(top: 8),
      child: TextField(
        onChanged: context.watch<SearchState>().getCallback(name),
        decoration: InputDecoration(
          label: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: const Text('Search'),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            gapPadding: 0
          ),
          focusColor: Colors.white
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
