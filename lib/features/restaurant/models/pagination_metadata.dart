class PaginationMetadata {
  final int currentPage;
  final bool hasNext;
  final bool hasPrevious;
  final int totalPages;
  final int nextPage;
  final int prevPage;

  PaginationMetadata({
    required this.currentPage,
    required this.hasNext,
    required this.hasPrevious,
    required this.totalPages,
    required this.nextPage,
    required this.prevPage,
  });
}
