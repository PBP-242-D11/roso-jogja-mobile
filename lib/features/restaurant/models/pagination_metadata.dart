class PaginationMetadata {
  final int currentPage;
  final bool hasNext;
  final bool hasPrevious;
  final int totalPages;

  PaginationMetadata({
    required this.currentPage,
    required this.hasNext,
    required this.hasPrevious,
    required this.totalPages,
  });
}
