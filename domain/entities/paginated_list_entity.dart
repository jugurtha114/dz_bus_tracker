/// lib/domain/entities/paginated_list_entity.dart

import 'package:equatable/equatable.dart';

/// Represents a generic paginated list of items within the application domain.
///
/// This entity holds the list of items for the current page, the total count
/// of items available across all pages, and a flag indicating if more pages exist.
/// It abstracts away the specific pagination mechanism (like next/previous URLs)
/// used by the data layer.
///
/// Type [T] represents the type of the domain entity contained in the list.
class PaginatedListEntity<T> extends Equatable {
  /// The list of items for the current page.
  final List<T> items;

  /// The total number of items available across all pages.
  /// Corresponds to the 'count' field in the API's paginated response.
  final int totalCount;

  /// Indicates whether there are more pages available to fetch after this one.
  /// Typically derived from the presence of a 'next' URL in the API response.
  final bool hasMore;

  /// Creates a [PaginatedListEntity] instance.
  const PaginatedListEntity({
    required this.items,
    required this.totalCount,
    required this.hasMore,
  });

  /// Returns the number of items on the current page.
  int get currentPageItemCount => items.length;

  /// Checks if this is the first page (assuming standard pagination).
  /// This is a simplification; true first-page detection might need offset info.
  bool get isFirstPage => items.isNotEmpty && !hasMore; // Approximate check

  /// Checks if the list of items is empty.
  bool get isEmpty => items.isEmpty;

  /// Checks if the list of items is not empty.
  bool get isNotEmpty => items.isNotEmpty;

  @override
  List<Object?> get props => [
        items, // List equality works correctly with Equatable items
        totalCount,
        hasMore,
      ];

  /// Creates an empty PaginatedListEntity, useful for initial states.
  static PaginatedListEntity<T> empty<T>() => const PaginatedListEntity(
        items: [],
        totalCount: 0,
        hasMore: false,
      );

  /// Creates a copy of this entity but with different items or properties.
  /// Useful for state management updates (e.g., appending items).
  PaginatedListEntity<T> copyWith({
    List<T>? items,
    int? totalCount,
    bool? hasMore,
  }) {
    return PaginatedListEntity<T>(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
