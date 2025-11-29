import 'package:flutter/material.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/services/product_service.dart';
import 'package:union_shop/services/collection_service.dart';
import 'package:union_shop/services/filter_service.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/widgets/product_card.dart';
import 'package:union_shop/widgets/filter_dropdown.dart';
import 'package:union_shop/widgets/sort_dropdown.dart';

/// Single collection page displaying products within a specific collection.
///
/// Uses ProductService for data and FilterService for sorting/filtering.
/// Shows the collection title, filter/sort dropdowns, and a responsive grid
/// of ProductCard widgets.
///
/// Requirements: 12.1, 12.2, 12.3, 12.4
class CollectionPage extends StatefulWidget {
  /// The collection ID to display
  final String collectionId;

  const CollectionPage({
    super.key,
    required this.collectionId,
  });

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final ProductService _productService = ProductService();
  final CollectionService _collectionService = CollectionService();
  final FilterService _filterService = FilterService();

  // Filter state (Req 12.3)
  String? _selectedSize;
  String? _selectedColour;
  SortOption _selectedSort = SortOption.newest;

  // Pagination state (Req 12.4)
  static const int _itemsPerPage = 12;
  int _currentPage = 0;

  /// Gets the collection title from service
  String get _collectionTitle {
    final collection = _collectionService.getById(widget.collectionId);
    return collection?.title ?? 'Collection';
  }

  /// Gets all products for this collection from service (Req 12.1)
  List<Product> get _allProducts {
    return _productService.getByCollection(widget.collectionId);
  }


  /// Gets filtered and sorted products (Req 12.2, 12.3)
  List<Product> get _filteredProducts {
    final filter = ProductFilter(
      size: _selectedSize,
      colour: _selectedColour,
      collectionId: widget.collectionId,
    );
    return _filterService.filterAndSortProducts(
      _allProducts,
      filter,
      _selectedSort,
    );
  }

  /// Gets paginated products (Req 12.4)
  List<Product> get _paginatedProducts {
    final start = _currentPage * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, _filteredProducts.length);
    if (start >= _filteredProducts.length) return [];
    return _filteredProducts.sublist(start, end);
  }

  /// Total number of pages
  int get _totalPages => (_filteredProducts.length / _itemsPerPage).ceil();

  /// Available sizes from products in this collection
  List<String> get _availableSizes {
    return _filterService.getAvailableSizes(_allProducts).toList()..sort();
  }

  /// Available colours from products in this collection
  List<String> get _availableColours {
    return _filterService.getAvailableColours(_allProducts).toList()..sort();
  }

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
            _buildProductsGrid(context),
            if (_totalPages > 1) _buildPagination(),
            const Footer(),
          ],
        ),
      ),
    );
  }

  /// Builds the collection title header (Req 12.1)
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
                _collectionTitle,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Text(
                'Browse our ${_collectionTitle.toLowerCase()} collection',
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

  /// Builds the filter and sort section (Req 12.2, 12.3)
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
        // Sort dropdown (Req 12.2)
        SortDropdown(
          selectedOption: _selectedSort,
          onChanged: (value) {
            setState(() {
              _selectedSort = value;
              _currentPage = 0;
            });
          },
        ),
        const SizedBox(height: 12),
        // Size filter (Req 12.3)
        if (_availableSizes.isNotEmpty) ...[
          FilterDropdown(
            label: 'Size',
            options: _availableSizes,
            selectedValue: _selectedSize,
            onChanged: (value) {
              setState(() {
                _selectedSize = value;
                _currentPage = 0;
              });
            },
          ),
          const SizedBox(height: 12),
        ],
        // Colour filter (Req 12.3)
        if (_availableColours.isNotEmpty)
          FilterDropdown(
            label: 'Colour',
            options: _availableColours,
            selectedValue: _selectedColour,
            onChanged: (value) {
              setState(() {
                _selectedColour = value;
                _currentPage = 0;
              });
            },
          ),
      ],
    );
  }

  /// Desktop layout for filters - horizontal row
  Widget _buildDesktopFilters() {
    return Row(
      children: [
        // Sort dropdown (Req 12.2)
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
        // Size filter (Req 12.3)
        if (_availableSizes.isNotEmpty) ...[
          Expanded(
            child: FilterDropdown(
              label: 'Size',
              options: _availableSizes,
              selectedValue: _selectedSize,
              onChanged: (value) {
                setState(() {
                  _selectedSize = value;
                  _currentPage = 0;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
        ],
        // Colour filter (Req 12.3)
        if (_availableColours.isNotEmpty) ...[
          Expanded(
            child: FilterDropdown(
              label: 'Colour',
              options: _availableColours,
              selectedValue: _selectedColour,
              onChanged: (value) {
                setState(() {
                  _selectedColour = value;
                  _currentPage = 0;
                });
              },
            ),
          ),
        ],
        const Spacer(),
      ],
    );
  }


  /// Builds the responsive products grid (Req 12.1, 12.4)
  Widget _buildProductsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getCrossAxisCount(screenWidth);
    final displayProducts = _paginatedProducts;

    if (displayProducts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        color: Colors.white,
        child: const Center(
          child: Text(
            'No products found matching your criteria.',
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
          childAspectRatio: 0.7,
        ),
        itemCount: displayProducts.length,
        itemBuilder: (context, index) {
          final product = displayProducts[index];
          return ProductCard(
            product: product,
            showSaleBadge: true,
            onTap: () {
              Navigator.pushNamed(context, '/product/${product.id}');
            },
          );
        },
      ),
    );
  }

  /// Builds pagination controls (Req 12.4)
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
    } else if (width < 1200) {
      return 3; // Desktop: 3 columns
    } else {
      return 4; // Large desktop: 4 columns
    }
  }
}
