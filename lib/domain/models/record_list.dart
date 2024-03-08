class RecordList<T> {
  List<T> items;
  bool hasNextPage;

  RecordList({required this.items, required this.hasNextPage});
}