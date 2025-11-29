import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/providers/cart_provider.dart';
import 'package:union_shop/services/product_service.dart';

/// Print Shack page for text personalisation feature.
///
/// Requirements: 15.1, 15.2, 15.3
class PrintShackPage extends StatefulWidget {
  const PrintShackPage({super.key});

  @override
  State<PrintShackPage> createState() => PrintShackPageState();
}

class PrintShackPageState extends State<PrintShackPage> {
  static const Color primaryColor = Color(0xFF4d2963);

  // Product type options
  static const List<String> productTypes = [
    'T-Shirt',
    'Hoodie',
    'Mug',
    'Tote Bag',
    'Cap',
  ];

  // Font options per product type (dynamic options based on selection)
  static const Map<String, List<String>> fontsByProduct = {
    'T-Shirt': ['Arial', 'Helvetica', 'Impact', 'Comic Sans'],
    'Hoodie': ['Arial', 'Helvetica', 'Impact'],
    'Mug': ['Arial', 'Times New Roman', 'Georgia'],
    'Tote Bag': ['Arial', 'Helvetica', 'Brush Script'],
    'Cap': ['Arial', 'Impact'],
  };

  // Text colour options per product type
  static const Map<String, List<String>> coloursByProduct = {
    'T-Shirt': ['White', 'Black', 'Red', 'Blue', 'Gold'],
    'Hoodie': ['White', 'Black', 'Gold'],
    'Mug': ['Black', 'Blue', 'Red', 'Green'],
    'Tote Bag': ['Black', 'Navy', 'Brown'],
    'Cap': ['White', 'Black'],
  };

  // Position options per product type
  static const Map<String, List<String>> positionsByProduct = {
    'T-Shirt': ['Front Center', 'Back Center', 'Left Chest'],
    'Hoodie': ['Front Center', 'Back Center'],
    'Mug': ['Front', 'Wrap Around'],
    'Tote Bag': ['Center', 'Bottom'],
    'Cap': ['Front', 'Back'],
  };

  // Form state
  String _selectedProductType = productTypes.first;
  String? _selectedFont;
  String? _selectedColour;
  String? _selectedPosition;
  String _customText = '';

  // Text controller for the custom text input
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateOptionsForProduct(_selectedProductType);
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _customText = _textController.text;
    });
  }

  /// Updates available options when product type changes (Req 15.2)
  void _updateOptionsForProduct(String productType) {
    final fonts = fontsByProduct[productType] ?? [];
    final colours = coloursByProduct[productType] ?? [];
    final positions = positionsByProduct[productType] ?? [];

    setState(() {
      _selectedProductType = productType;
      _selectedFont = fonts.isNotEmpty ? fonts.first : null;
      _selectedColour = colours.isNotEmpty ? colours.first : null;
      _selectedPosition = positions.isNotEmpty ? positions.first : null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const NavbarDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Navbar(),
            _buildPrintShackContent(context),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintShackContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 32),
              // Main content - form and preview
              isDesktop
                  ? _buildDesktopLayout()
                  : _buildMobileLayout(),
              const SizedBox(height: 32),
              // Link to about page
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/print-shack/about');
                  },
                  child: Text(
                    'Learn more about Print Shack',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.print, size: 40, color: primaryColor),
            SizedBox(width: 12),
            Text(
              'Print Shack',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Personalise your products with custom text!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form section
        Expanded(
          flex: 1,
          child: _buildPersonalisationForm(),
        ),
        const SizedBox(width: 40),
        // Preview section
        Expanded(
          flex: 1,
          child: _buildPreviewSection(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildPersonalisationForm(),
        const SizedBox(height: 32),
        _buildPreviewSection(),
      ],
    );
  }

  /// Personalisation form with dropdowns and text input (Req 15.1)
  Widget _buildPersonalisationForm() {
    final fonts = fontsByProduct[_selectedProductType] ?? [];
    final colours = coloursByProduct[_selectedProductType] ?? [];
    final positions = positionsByProduct[_selectedProductType] ?? [];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customise Your Product',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          // Product type dropdown (Req 15.2 - changes available options)
          _buildDropdown(
            label: 'Product Type',
            value: _selectedProductType,
            items: productTypes,
            onChanged: (value) {
              if (value != null) {
                _updateOptionsForProduct(value);
              }
            },
          ),
          const SizedBox(height: 16),
          // Font dropdown (dynamic based on product)
          _buildDropdown(
            label: 'Font',
            value: _selectedFont,
            items: fonts,
            onChanged: (value) {
              setState(() {
                _selectedFont = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Colour dropdown (dynamic based on product)
          _buildDropdown(
            label: 'Text Colour',
            value: _selectedColour,
            items: colours,
            onChanged: (value) {
              setState(() {
                _selectedColour = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Position dropdown (dynamic based on product)
          _buildDropdown(
            label: 'Position',
            value: _selectedPosition,
            items: positions,
            onChanged: (value) {
              setState(() {
                _selectedPosition = value;
              });
            },
          ),
          const SizedBox(height: 24),
          // Custom text input (Req 15.1, 15.3)
          _buildTextInput(),
          const SizedBox(height: 24),
          // Add to cart button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _customText.isNotEmpty ? _handleAddToCart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[300],
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
      ),
    );
  }


  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryColor),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Custom Text',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('custom_text_input'),
          controller: _textController,
          maxLength: 30,
          decoration: InputDecoration(
            hintText: 'Enter your text here...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  /// Preview section showing real-time preview of customisation (Req 15.3)
  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          // Product preview area
          _buildProductPreview(),
          const SizedBox(height: 24),
          // Summary of selections
          _buildSelectionSummary(),
        ],
      ),
    );
  }

  Widget _buildProductPreview() {
    return Container(
      key: const Key('preview_container'),
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Product icon/placeholder
          Icon(
            _getProductIcon(),
            size: 150,
            color: Colors.grey[300],
          ),
          // Custom text overlay (Req 15.3 - real-time preview)
          if (_customText.isNotEmpty)
            Positioned(
              top: _getTextPosition(),
              child: Container(
                key: const Key('preview_text'),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  _customText,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _getPreviewTextColor(),
                    fontFamily: _getFontFamily(),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          // Empty state message
          if (_customText.isEmpty)
            Positioned(
              bottom: 40,
              child: Text(
                'Enter text to see preview',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getProductIcon() {
    switch (_selectedProductType) {
      case 'T-Shirt':
        return Icons.checkroom;
      case 'Hoodie':
        return Icons.dry_cleaning;
      case 'Mug':
        return Icons.coffee;
      case 'Tote Bag':
        return Icons.shopping_bag;
      case 'Cap':
        return Icons.sports_baseball;
      default:
        return Icons.checkroom;
    }
  }

  double _getTextPosition() {
    switch (_selectedPosition) {
      case 'Front Center':
      case 'Back Center':
      case 'Center':
      case 'Front':
      case 'Back':
        return 130;
      case 'Left Chest':
        return 80;
      case 'Bottom':
        return 200;
      case 'Wrap Around':
        return 130;
      default:
        return 130;
    }
  }

  Color _getPreviewTextColor() {
    switch (_selectedColour) {
      case 'White':
        return Colors.white;
      case 'Black':
        return Colors.black;
      case 'Red':
        return Colors.red;
      case 'Blue':
        return Colors.blue;
      case 'Gold':
        return const Color(0xFFFFD700);
      case 'Green':
        return Colors.green;
      case 'Navy':
        return const Color(0xFF000080);
      case 'Brown':
        return Colors.brown;
      default:
        return Colors.black;
    }
  }

  String? _getFontFamily() {
    // Return null to use default font, as custom fonts would need to be loaded
    // In a real app, you'd load these fonts in pubspec.yaml
    return null;
  }

  Widget _buildSelectionSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Selection',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _buildSummaryRow('Product', _selectedProductType),
        _buildSummaryRow('Font', _selectedFont ?? '-'),
        _buildSummaryRow('Colour', _selectedColour ?? '-'),
        _buildSummaryRow('Position', _selectedPosition ?? '-'),
        _buildSummaryRow(
          'Text',
          _customText.isNotEmpty ? _customText : '-',
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart() {
    // Get the product ID based on selected product type
    final productId = _getProductIdForType(_selectedProductType);
    final productService = ProductService();
    final product = productService.getById(productId);

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product not found'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Add to cart using CartProvider
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(
      product,
      quantity: 1,
      selectedColour: _selectedColour,
      customText: '$_customText (Font: $_selectedFont, Position: $_selectedPosition)',
    );

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added $_selectedProductType with "$_customText" to cart!',
        ),
        backgroundColor: primaryColor,
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

  String _getProductIdForType(String productType) {
    switch (productType) {
      case 'T-Shirt':
        return 'print-shack-tshirt';
      case 'Hoodie':
        return 'print-shack-hoodie';
      case 'Mug':
        return 'print-shack-mug';
      case 'Tote Bag':
        return 'print-shack-totebag';
      case 'Cap':
        return 'print-shack-cap';
      default:
        return 'print-shack-tshirt';
    }
  }
}
