import 'package:flutter/material.dart';
import 'package:union_shop/models/collection.dart';
import 'package:union_shop/services/collection_service.dart';
import 'package:union_shop/services/filter_service.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/widgets/collection_card.dart';
import 'package:union_shop/widgets/sort_dropdown.dart';

/// Collections listing page displaying all available collections.
///
/// Uses CollectionService for data and FilterService for sorting/filtering.
/// Displays CollectionCard widgets in a responsive grid layout.
///
/// Requirements: 11.1, 11.2, 11.3, 11.4
class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final CollectionService _collectionService = CollectionService();
  final FilterService _filterService = FilterService();

  // Sort and filter state
  SortOption _selectedSort = SortOption.nameAsc;
  bool? _showSaleOnly;

  // Pagination state
  static const int _itemsPerPage = 8;
  int _currentPage = 0;

  /// Gets filtered and sorted collections from service (Req 11.1)
  List<Collection> get _collections {
    final allCollections = _collectionService.getAll();
    final filter = CollectionFilter(isSaleCollection: _showSaleOnly);
    return _filterService.filterAndSortCollections(
      allCollections,
      filter,
      _selectedSort,
    );
  }

  /// Gets paginated collections (Req 11.4)
  List<Collection> get _paginatedCollections {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, _collections.length);
    if (start >= _collections.length) return [];
    return _collections.sublist(start, end);
  }

  /// Total number of pages
  int get _totalPages => (_collections.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const NavbarDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Navbar(),
            _buildHeader(),
            _buildFilterSection(context),
            _buildCollectionsGrid(context),
            if (_totalPages > 1) _buildPagination(),
            const Footer(),
          ],
        ),
      ),
    );
  }


  /// Builds the page header section
  /// Requirements: 16.1, 16.2, 16.3, 16.4
  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        
        // Responsive sizing
        final titleSize = isMobile ? 26.0 : 32.0;
        final descSize = isMobile ? 14.0 : 16.0;
        final verticalPadding = isMobile ? 30.0 : 40.0;
        final horizontalPadding = isMobile ? 16.0 : 24.0;
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          color: const Color(0xFF4d2963),
          child: Column(
            children: [
              Text(
                'Collections',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                'Browse our curated collections of university merchandise',
                style: TextStyle(
                  fontSize: descSize,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the filter and sort section (Req 11.2, 11.3)
  Widget _buildFilterSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: isMobile ? _buildMobileFilters() : _buildDesktopFilters(),
    );
  }

  /// Mobile layout for filters - stacked vertically
  Widget _buildMobileFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sort dropdown (Req 11.2)
        SortDropdown(
          selectedOption: _selectedSort,
          onChanged: (value) {
            setState(() {
              _selectedSort = value;
              _currentPage = 0; // Reset to first page on sort change
            });
          },
        ),
        const SizedBox(height: 12),
        // Sale filter (Req 11.3)
        _buildSaleFilter(),
      ],
    );
  }

  /// Desktop layout for filters - horizontal row
  Widget _buildDesktopFilters() {
    return Row(
      children: [
        // Sort dropdown (Req 11.2)
        Expanded(
          child: SortDropdown(
            selectedOption: _selectedSort,
            onChanged: (value) {
              setState(() {
                _selectedSort = value;
                _currentPage = 0;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        // Sale filter (Req 11.3)
        Expanded(child: _buildSaleFilter()),
        const Spacer(flex: 2),
      ],
    );
  }

  /// Builds the sale filter dropdown (Req 11.3)
  Widget _buildSaleFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: _showSaleOnly,
          isExpanded: true,
          hint: const Text('Filter by type'),
          items: const [
            DropdownMenuItem(value: null, child: Text('All Collections')),
            DropdownMenuItem(value: true, child: Text('Sale Collections')),
            DropdownMenuItem(value: false, child: Text('Regular Collections')),
          ],
          onChanged: (value) {
            setState(() {
              _showSaleOnly = value;
              _currentPage = 0;
            });
          },
        ),
      ),
    );
  }

  /// Builds the responsive collections grid (Req 11.1, 11.4)
  Widget _buildCollectionsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);
    final displayCollections = _paginatedCollections;

    if (displayCollections.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        color: Colors.white,
        child: const Center(
          child: Text(
            'No collections found matching your criteria.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: displayCollections.length,
        itemBuilder: (context, index) {
          return CollectionCard(collection: displayCollections[index]);
        },
      ),
    );
  }

  /// Builds pagination controls (Req 11.4)
  Widget _buildPagination() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          const SizedBox(width: 16),
          Text(
            'Page ${_currentPage + 1} of $_totalPages',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _currentPage < _totalPages - 1
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  /// Determines the number of columns based on screen width
  int _getCrossAxisCount(double width) {
    if (width < 600) {
      return 1; // Mobile: single column
    } else if (width < 900) {
      return 2; // Tablet: 2 columns
    } else {
      return 3; // Desktop: 3 columns
    }
  }
}
