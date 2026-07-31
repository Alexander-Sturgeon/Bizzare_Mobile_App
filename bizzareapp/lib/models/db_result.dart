class DBResult {
  final bool isSuccess;
  final String message;
  List<Map<String, dynamic>> listingList;

  DBResult({
    required this.isSuccess,
    required this.message,
    required this.listingList,
  });
}
