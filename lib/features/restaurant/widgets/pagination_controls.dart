import 'package:flutter/material.dart';
import '../models/pagination_metadata.dart';

class PaginationControls extends StatelessWidget {
  final PaginationMetadata? metadata;
  final int currentPage;
  final ValueChanged<int> onPageChange;
  final bool isLoading;

  const PaginationControls({
    super.key,
    required this.metadata,
    required this.currentPage,
    required this.isLoading,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    if (metadata == null) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: metadata!.hasPrevious && !isLoading
              ? () => onPageChange(1)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: metadata!.hasPrevious && !isLoading && currentPage > 1
              ? () => onPageChange(currentPage - 1)
              : null,
        ),
        Text('Page ${metadata!.currentPage} of ${metadata!.totalPages}'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: metadata!.hasNext &&
                  !isLoading &&
                  currentPage < metadata!.totalPages
              ? () => onPageChange(currentPage + 1)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: metadata!.hasNext && !isLoading
              ? () => onPageChange(metadata!.totalPages)
              : null,
        ),
      ],
    );
  }
}
