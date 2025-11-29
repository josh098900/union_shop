import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../services/autocomplete_service.dart';
import 'suggestion_dropdown.dart';

/// A search field widget with autocomplete functionality.
///
/// Wraps a TextField with autocomplete suggestions that appear as the user types.
/// Implements debouncing, dropdown visibility control, and keyboard/tap handling.
///
/// Requirements: 1.1, 1.2, 1.5, 2.1, 2.2, 2.3, 3.1, 4.1, 4.2, 4.3
class AutocompleteSearchField extends StatefulWidget {
  /// Controller for the text field
  final TextEditingController controller;

  /// Callback when the search form is submitted
  final Function(String) onSearch;

  /// Callback when a suggestion is selected
  final Function(Product) onSuggestionSelected;

  /// Minimum characters required to show suggestions (default: 2)
  final int minCharacters;

  /// Maximum number of suggestions to display (default: 5)
  final int maxSuggestions;

  /// Debounce delay for input changes (default: 300ms)
  final Duration debounceDelay;

  /// Hint text for the search field
  final String? hintText;

  /// Optional autocomplete service (for testing)
  final AutocompleteService? autocompleteService;

  const AutocompleteSearchField({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onSuggestionSelected,
    this.minCharacters = 2,
    this.maxSuggestions = 5,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.hintText,
    this.autocompleteService,
  });

  @override
  State<AutocompleteSearchField> createState() => AutocompleteSearchFieldState();
}


/// State class exposed for testing purposes
class AutocompleteSearchFieldState extends State<AutocompleteSearchField> {
  late AutocompleteService _autocompleteService;
  Timer? _debounceTimer;
  List<Product> _suggestions = [];
  bool _isDropdownVisible = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  /// Exposes dropdown visibility for testing
  bool get isDropdownVisible => _isDropdownVisible;

  /// Exposes current suggestions for testing
  List<Product> get suggestions => _suggestions;

  @override
  void initState() {
    super.initState();
    _autocompleteService = widget.autocompleteService ?? AutocompleteService();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Delay hiding to allow tap on suggestion to register
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus && mounted) {
          _hideDropdown();
        }
      });
    } else {
      // Show dropdown if input meets threshold when focused
      _updateDropdownVisibility();
    }
  }

  /// Handles text changes with debouncing (Req 3.1)
  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDelay, () {
      if (mounted) {
        _updateSuggestions();
      }
    });
  }

  /// Updates suggestions based on current input
  void _updateSuggestions() {
    final query = widget.controller.text;
    
    if (query.length >= widget.minCharacters) {
      final newSuggestions = _autocompleteService.getSuggestions(
        query,
        maxResults: widget.maxSuggestions,
      );
      setState(() {
        _suggestions = newSuggestions;
      });
      _showDropdown();
    } else {
      _hideDropdown();
    }
  }

  /// Updates dropdown visibility based on input length (Req 1.1, 1.2)
  void _updateDropdownVisibility() {
    final query = widget.controller.text;
    if (query.length >= widget.minCharacters) {
      _updateSuggestions();
    } else {
      _hideDropdown();
    }
  }

  /// Shows the suggestion dropdown
  void _showDropdown() {
    if (!_isDropdownVisible) {
      setState(() {
        _isDropdownVisible = true;
      });
      _createOverlay();
    } else {
      // Update existing overlay
      _overlayEntry?.markNeedsBuild();
    }
  }

  /// Hides the suggestion dropdown (Req 1.2, 1.5, 2.2, 4.1, 4.2)
  void _hideDropdown() {
    if (_isDropdownVisible) {
      setState(() {
        _isDropdownVisible = false;
        _suggestions = [];
      });
      _removeOverlay();
    }
  }

  void _createOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlay(),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildOverlay() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;

    return Positioned(
      width: size.width,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(0, size.height + 4),
        child: Material(
          elevation: 0,
          color: Colors.transparent,
          child: SuggestionDropdown(
            suggestions: _suggestions,
            isVisible: _isDropdownVisible,
            onSelect: onSuggestionSelected,
          ),
        ),
      ),
    );
  }

  /// Handles suggestion selection (Req 2.1, 2.2, 2.3)
  /// Made public for testing purposes
  void onSuggestionSelected(Product product) {
    // Populate input with selected product name (Req 2.3)
    widget.controller.text = product.title;
    // Move cursor to end
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
    // Close dropdown (Req 2.2)
    _hideDropdown();
    // Navigate to product (Req 2.1)
    widget.onSuggestionSelected(product);
  }

  /// Handles form submission (Req 4.3)
  void _onSubmitted(String value) {
    _hideDropdown();
    widget.onSearch(value);
  }

  /// Handles keyboard events (Req 4.2)
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _hideDropdown();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        onKeyEvent: _handleKeyEvent,
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Search for products...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.controller.clear();
                      _hideDropdown();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onSubmitted: _onSubmitted,
          onChanged: (value) {
            // Trigger rebuild to update clear button visibility
            setState(() {});
          },
        ),
      ),
    );
  }
}
