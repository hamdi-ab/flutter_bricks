/// Generic container for a page of data
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.totalItems,
    this.nextPageKey,
  });

  /// The list of items in this page
  final List<T> items;

  /// Total number of items available on the backend
  final int totalItems;

  /// Key/Index for the next page (null if last page)
  /// Can be an integer offset, page number, or cursor string
  final int? nextPageKey;

  /// Helper to check if this is likely the last page based on list size
  bool get isLastPage => nextPageKey == null;
}
