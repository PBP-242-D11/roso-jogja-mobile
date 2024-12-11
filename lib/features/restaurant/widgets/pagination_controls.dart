import 'package:flutter/material.dart';
import '../models/pagination_metadata.dart';

class PaginationControls extends StatelessWidget {
  final PaginationMetadata? metadata;
  final int currentPage;
  final ValueChanged<int> onPageChange;

  const PaginationControls({
    super.key,
    required this.metadata,
    required this.currentPage,
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
          onPressed: metadata!.hasPrevious ? () => onPageChange(1) : null,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: metadata!.hasPrevious
              ? () => onPageChange(metadata!.prevPage)
              : null,
        ),
        Text('Page ${metadata!.currentPage} of ${metadata!.totalPages}'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed:
              metadata!.hasNext ? () => onPageChange(metadata!.nextPage) : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: metadata!.hasNext
              ? () => onPageChange(metadata!.totalPages)
              : null,
        ),
      ],
    );
  }
}
