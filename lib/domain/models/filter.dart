class ListFilter {
  int page;
  int per;
  String search;
  Map<String, bool>? orders;

  ListFilter({this.page=1, this.per=10, this.search='', this.orders});

  int get offset => (page -1) * per;
}

class ProductFilter {
  int categoryId;
  int orderId;

  ProductFilter({this.orderId=0, this.categoryId=0});
}

class OrderFilter {
  int tableId;

  OrderFilter({this.tableId=0});
}

class ProductListFilter {
  ListFilter list;
  ProductFilter product;

  ProductListFilter({required this.list, required this.product});

}

class CategoryListFilter {
  ListFilter list;

  CategoryListFilter({required this.list});
}

class OrderListFilter {
  ListFilter list;
  OrderFilter order;

  OrderListFilter({required this.list, required this.order});
}

class OrderItemFilter {
  int tableId;
  int orderId;

  OrderItemFilter({this.tableId=0, this.orderId=0});
}

class OrderItemListFilter {
  ListFilter list;
  OrderItemFilter order;

  OrderItemListFilter({required this.list, required this.order});
}

class TableListFilter {
  ListFilter list;

  TableListFilter({required this.list});
}