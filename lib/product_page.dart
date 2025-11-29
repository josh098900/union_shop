import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/product.dart';
import 'services/product_service.dart';
import 'providers/cart_provider.dart';
import 'widgets/navbar.dart';
import 'widgets/footer.dart';
import 'widgets/quantity_selector.dart';

/// Product detail page displaying product information with options to select
/// size, colour, quantity, and add to cart.
///
/// Loads product data from ProductService by ID.
///
/// Requirements: 13.1, 13.2, 13.3
class ProductPage extends StatefulWidget {
  /// Optional product ID to load from service
  final String? productId;
  
  /// Optional product to display directly (for backwards compatibility)
  final Product? product;

  const ProductPage({super.key, this.productId, this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductService _productService = ProductService();
  
  // Selected options state (Req 13.2)
  String? _selectedSize;
  String? _selectedColour;
  int _quantity = 1;

  // Placeholder product for when no product is found
  static final Product _placeholderProduct = Product(
    id: 'placeholder-1',
    title: 'Product Not Found',
    description: 'The requested product could not be found.',
    price: 0.00,
    imageUrls: [],
    sizes: [],
    colours: [],
    collectionId: '',
    createdAt: DateTime.now(),
  );

  /// Gets the product from service or uses provided product (Req 13.1)
  Product get _product {
    // If product is directly provided, use it
    if (widget.product != null) {
      return widget.product!;
    }
    // Otherwise load from service by ID
    if (widget.productId != null) {
      return _productService.getById(widget.productId!) ?? _placeholderProduct;
    }
    return _placeholderProduct;
  }


  static const Color primaryColor = Color(0xFF4d2963);

  /// Checks if all required options are selected before adding to cart
  bool get _canAddToCart {
    // If product has sizes, one must be selected
    if (_product.sizes.isNotEmpty && _selectedSize == null) {
      return false;
    }
    // If product has colours, one must be selected
    if (_product.colours.isNotEmpty && _selectedColour == null) {
      return false;
    }
    // Don't allow adding placeholder product
    if (_product.id == 'placeholder-1') {
      return false;
    }
    return true;
  }

  /// Gets a message describing what options need to be selected
  String? get _selectionRequiredMessage {
    final missing = <String>[];
    if (_product.sizes.isNotEmpty && _selectedSize == null) {
      missing.add('size');
    }
    if (_product.colours.isNotEmpty && _selectedColour == null) {
      missing.add('colour');
    }
    if (missing.isEmpty) return null;
    return 'Please select a ${missing.join(' and ')}';
  }

  /// Handles adding the product to cart with selected options.
  /// 
  /// Connects to CartProvider to add the item and shows visual feedback.
  /// Requirements: 13.4, 14.1
  void _handleAddToCart() async {
    // Validate required options are selected
    if (!_canAddToCart) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_selectionRequiredMessage ?? 'Please select all options'),
                ),
              ],
            ),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final cartProvider = context.read<CartProvider>();
    
    // Add item to cart with selected options and quantity (Req 14.1)
    await cartProvider.addToCart(
      _product,
      quantity: _quantity,
      selectedSize: _selectedSize,
      selectedColour: _selectedColour,
    );

    // Show visual feedback (Req 13.4)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Added ${_product.title} to cart (Qty: $_quantity)',
                ),
              ),
            ],
          ),
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const NavbarDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Navbar(),
            _buildProductDetails(),
            const Footer(),
          ],
        ),
      ),
    );
  }

  /// Builds product details with responsive layout
  /// Requirements: 16.1, 16.2, 16.3, 16.4
  Widget _buildProductDetails() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          // Mobile (<600px): stacked layout (Req 16.1)
          // Tablet/Desktop (>=600px): side-by-side layout (Req 16.2, 16.3)
          final isWideScreen = screenWidth >= 600;

          if (isWideScreen) {
            return _buildWideLayout();
          } else {
            return _buildNarrowLayout();
          }
        },
      ),
    );
  }

  /// Wide layout for tablet/desktop - image on left, details on right
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildProductImage(),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 1,
          child: _buildProductInfo(),
        ),
      ],
    );
  }

  /// Narrow layout for mobile - stacked vertically
  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImage(),
        const SizedBox(height: 24),
        _buildProductInfo(),
      ],
    );
  }

  /// Product image with error handling (Req 13.1)
  Widget _buildProductImage() {
    final imageUrl =
        _product.imageUrls.isNotEmpty ? _product.imageUrls.first : '';

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Image unavailable',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }


  /// Product information section with title, price, description, options
  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product title (Req 13.1)
        Text(
          _product.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 12),

        // Product price (Req 13.1)
        _buildPriceDisplay(),

        const SizedBox(height: 24),

        // Product description (Req 13.1)
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _product.description,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 24),

        // Size dropdown (Req 13.2)
        if (_product.sizes.isNotEmpty) ...[
          _buildOptionDropdown(
            label: 'Size',
            options: _product.sizes,
            selectedValue: _selectedSize,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedSize = value;
              });
            },
          ),
          const SizedBox(height: 16),
        ],

        // Colour dropdown (Req 13.2)
        if (_product.colours.isNotEmpty) ...[
          _buildOptionDropdown(
            label: 'Colour',
            options: _product.colours,
            selectedValue: _selectedColour,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedColour = value;
              });
            },
          ),
          const SizedBox(height: 16),
        ],

        // Quantity selector (Req 13.3)
        const Text(
          'Quantity',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        QuantitySelector(
          quantity: _quantity,
          onChanged: (value) {
            setState(() {
              _quantity = value;
            });
          },
        ),

        const SizedBox(height: 24),

        // Selection required message
        if (_selectionRequiredMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectionRequiredMessage!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Add to Cart button (Req 13.4)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canAddToCart ? _handleAddToCart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[500],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Add to Cart',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a dropdown for selecting product options (size, colour)
  /// Unlike FilterDropdown, this doesn't have an "All" option and requires selection
  Widget _buildOptionDropdown({
    required String label,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    final hasError = isRequired && selectedValue == null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: hasError ? Colors.red : Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasError ? Colors.orange[300]! : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: Text(
                'Select $label',
                style: TextStyle(color: Colors.grey[500]),
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// Price display with sale price support
  Widget _buildPriceDisplay() {
    if (_product.isOnSale) {
      return Row(
        children: [
          Text(
            '£${_product.salePrice!.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '£${_product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      );
    }

    return Text(
      '£${_product.price.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
    );
  }
}
