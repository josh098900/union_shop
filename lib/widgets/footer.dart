import 'package:flutter/material.dart';

/// A reusable footer widget displayed on all pages.
///
/// Contains:
/// - Contact information section (Req 4.1)
/// - Social media links section (Req 4.2)
/// - Policy links (Privacy, Terms, Returns) (Req 4.3)
/// - Search input field
///
/// Requirements: 4.1, 4.2, 4.3, 4.4, 16.1, 16.2, 16.3, 16.4
class Footer extends StatelessWidget {
  /// Optional callback when search is submitted
  final ValueChanged<String>? onSearchSubmit;

  const Footer({
    super.key,
    this.onSearchSubmit,
  });

  static const Color primaryColor = Color(0xFF4d2963);
  
  /// Mobile breakpoint (Req 16.1)
  static const double mobileBreakpoint = 600.0;
  
  /// Tablet breakpoint (Req 16.2)
  static const double tabletBreakpoint = 1024.0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < mobileBreakpoint;
    final isTablet = screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;
    
    // Responsive padding (Req 16.1, 16.2, 16.3)
    final padding = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);

    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(padding),
            child: isMobile
                ? _buildMobileLayout(context)
                : isTablet
                    ? _buildTabletLayout(context)
                    : _buildDesktopLayout(context),
          ),
          // Bottom copyright bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 12 : 16,
              horizontal: padding,
            ),
            color: primaryColor,
            child: Text(
              '© 2025 Union Shop. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 11 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactSection(),
        const SizedBox(height: 24),
        _buildSocialLinksSection(),
        const SizedBox(height: 24),
        _buildPolicyLinksSection(),
        const SizedBox(height: 24),
        _buildSearchSection(),
      ],
    );
  }

  /// Tablet layout - 2x2 grid (Req 16.2)
  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildContactSection()),
            const SizedBox(width: 20),
            Expanded(child: _buildSocialLinksSection()),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPolicyLinksSection()),
            const SizedBox(width: 20),
            Expanded(child: _buildSearchSection()),
          ],
        ),
      ],
    );
  }

  /// Desktop layout - 4 columns (Req 16.3)
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildContactSection()),
        const SizedBox(width: 24),
        Expanded(child: _buildSocialLinksSection()),
        const SizedBox(width: 24),
        Expanded(child: _buildPolicyLinksSection()),
        const SizedBox(width: 24),
        Expanded(child: _buildSearchSection()),
      ],
    );
  }

  /// Contact information section (Req 4.1)
  Widget _buildContactSection() {
    return const _FooterSection(
      title: 'Contact Us',
      children: [
        _ContactItem(
          icon: Icons.location_on,
          text: 'Student Union Building\nUniversity of Portsmouth\nPortsmouth, PO1 2UP',
        ),
        SizedBox(height: 8),
        _ContactItem(
          icon: Icons.email,
          text: 'shop@upsu.net',
        ),
        SizedBox(height: 8),
        _ContactItem(
          icon: Icons.phone,
          text: '+44 (0)23 9284 3000',
        ),
      ],
    );
  }

  /// Social media links section (Req 4.2)
  Widget _buildSocialLinksSection() {
    return const _FooterSection(
      title: 'Follow Us',
      children: [
        Row(
          children: [
            _SocialIcon(icon: Icons.facebook, label: 'Facebook'),
            SizedBox(width: 16),
            _SocialIcon(icon: Icons.camera_alt, label: 'Instagram'),
            SizedBox(width: 16),
            _SocialIcon(icon: Icons.alternate_email, label: 'Twitter'),
          ],
        ),
      ],
    );
  }

  /// Policy links section (Req 4.3)
  Widget _buildPolicyLinksSection() {
    return const _FooterSection(
      title: 'Policies',
      children: [
        _PolicyLink(text: 'Privacy Policy'),
        SizedBox(height: 8),
        _PolicyLink(text: 'Terms of Service'),
        SizedBox(height: 8),
        _PolicyLink(text: 'Returns Policy'),
      ],
    );
  }

  /// Search input section
  Widget _buildSearchSection() {
    return _FooterSection(
      title: 'Search',
      children: [
        _SearchInput(onSubmit: onSearchSubmit),
      ],
    );
  }
}


/// Internal widget for footer section with title
class _FooterSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FooterSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

/// Internal widget for contact information items
class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Footer.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Internal widget for social media icons
class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SocialIcon({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () {
          // Placeholder for social link navigation
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Footer.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Internal widget for policy links
class _PolicyLink extends StatelessWidget {
  final String text;

  const _PolicyLink({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Placeholder for policy link navigation
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// Internal widget for search input
class _SearchInput extends StatefulWidget {
  final ValueChanged<String>? onSubmit;

  const _SearchInput({
    this.onSubmit,
  });

  @override
  State<_SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<_SearchInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      if (widget.onSubmit != null) {
        widget.onSubmit!(query);
      } else {
        // Navigate to search page with query (Req 19.2)
        Navigator.pushNamed(context, '/search?q=${Uri.encodeComponent(query)}');
      }
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Footer.primaryColor),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (_) => _handleSubmit(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _handleSubmit,
          icon: const Icon(Icons.search),
          color: Footer.primaryColor,
          tooltip: 'Search',
        ),
      ],
    );
  }
}
