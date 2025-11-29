import 'package:flutter/material.dart';
import 'package:union_shop/models/product.dart';
import 'package:union_shop/services/search_service.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/widgets/product_card.dart';
import 'package:union_shop/widgets/autocomplete_search_field.dart';

/// Search page for displaying search results.
///
/// Features:
/// - Search input field
/// - Results grid showing matching products
/// - No results message with suggestions
///
/// Requirements: 19.3, 19.4
class SearchPage extends StatefulWidget {
  /// Optional initial search query
  final String? query;

  const SearchPage({super.key, this.query});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  final SearchService _searchService = SearchService();
  List<Product> _searchResults = [];
  bool _hasSearched = false;

  static const Color primaryColor = Color(0xFF4d2963);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query ?? '');
    // Perform initial search if query is provided
    if (widget.query != null && widget.query!.isNotEmpty) {
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text;
    setState(() {
      _searchResults = _searchService.search(query);
      _hasSearched = query.trim().isNotEmpty;
    });
  }

  void _navigateToProduct(String productId) {
    Navigator.pushNamed(context, '/product/$productId');
  }

  /// Handles suggestion selection from autocomplete (Req 2.1)
  void _onSuggestionSelected(Product product) {
    _navigateToProduct(product.id);
  }

  void _handleFooterSearch(String query) {
    _searchController.text = query;
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const NavbarDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Navbar(),
            _buildSearchContent(context),
            Footer(onSearchSubmit: _handleFooterSearch),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final padding = isMobile ? 16.0 : 24.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              // Search input with autocomplete (Req 2.1, 4.3)
              AutocompleteSearchField(
                controller: _searchController,
                onSearch: (_) => _performSearch(),
                onSuggestionSelected: _onSuggestionSelected,
                hintText: 'Search for products...',
              ),
              const SizedBox(height: 16),
              // Search button
              SizedBox(
                width: isMobile ? double.infinity : 120,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ),
              const SizedBox(height: 40),
              // Results section
              _buildResultsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    if (!_hasSearched) {
      return _buildEmptyState();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return _buildResultsGrid(context);
  }

  Widget _buildResultsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _getGridCrossAxisCount(screenWidth);
    final isMobile = screenWidth < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'} for "${_searchController.text}"',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isMobile ? 12 : 24,
            mainAxisSpacing: isMobile ? 24 : 48,
            childAspectRatio: 0.75,
          ),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final product = _searchResults[index];
            return ProductCard(
              product: product,
              showSaleBadge: product.isOnSale,
              onTap: () => _navigateToProduct(product.id),
            );
          },
        ),
      ],
    );
  }

  int _getGridCrossAxisCount(double width) {
    if (width < 600) {
      return 1; // Mobile: single column
    } else if (width < 1024) {
      return 2; // Tablet: 2 columns
    } else {
      return 4; // Desktop: 4 columns
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Enter a search term to find products',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// No results message with suggestions (Req 19.4)
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "${_searchController.text}"',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try searching for something else or browse our collections.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Suggestions (Req 19.4)
          const Text(
            'Suggestions:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildSuggestionChip('Hoodie'),
              _buildSuggestionChip('T-Shirt'),
              _buildSuggestionChip('Mug'),
              _buildSuggestionChip('Backpack'),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/collections');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Browse Collections'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return ActionChip(
      label: Text(suggestion),
      onPressed: () {
        _searchController.text = suggestion;
        _performSearch();
      },
    );
  }
}
