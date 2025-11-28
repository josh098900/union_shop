import 'package:flutter/material.dart';

/// A reusable navigation bar widget with responsive behaviour.
/// 
/// On mobile viewport (< 600px): Shows burger menu that opens a drawer
/// On desktop viewport (>= 600px): Shows inline navigation links
/// 
/// Requirements: 2.1, 2.2, 2.3, 2.5
class Navbar extends StatelessWidget {
  /// Optional callback for search icon tap
  final VoidCallback? onSearchTap;
  
  /// Optional callback for account icon tap
  final VoidCallback? onAccountTap;
  
  /// Optional callback for cart icon tap
  final VoidCallback? onCartTap;

  const Navbar({
    super.key,
    this.onSearchTap,
    this.onAccountTap,
    this.onCartTap,
  });

  static const String logoUrl =
      'https://shop.upsu.net/cdn/shop/files/upsu_300x300.png?v=1614735854';
  
  static const Color primaryColor = Color(0xFF4d2963);
  
  static const double mobileBreakpoint = 600.0;

  void _navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.white,
      child: Column(
        children: [
          // Top banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: primaryColor,
            child: const Text(
              'PLACEHOLDER HEADER TEXT',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          // Main header
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  // Logo - navigates to home when tapped (Req 2.1)
                  GestureDetector(
                    onTap: () => _navigateToHome(context),
                    child: Image.network(
                      logoUrl,
                      height: 18,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          width: 18,
                          height: 18,
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  // Navigation icons and links
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isDesktop = screenWidth >= mobileBreakpoint;
                      
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Desktop inline navigation (Req 2.5)
                            if (isDesktop) ...[
                              _NavLink(
                                label: 'Home',
                                onTap: () => _navigateToHome(context),
                              ),
                              _NavLink(
                                label: 'Collections',
                                onTap: () => Navigator.pushNamed(context, '/collections'),
                              ),
                              _NavLink(
                                label: 'About',
                                onTap: () => Navigator.pushNamed(context, '/about'),
                              ),
                              const SizedBox(width: 8),
                            ],
                            // Icons (Req 2.2)
                            _NavIconButton(
                              icon: Icons.search,
                              onPressed: onSearchTap,
                              tooltip: 'Search',
                            ),
                            _NavIconButton(
                              icon: Icons.person_outline,
                              onPressed: onAccountTap,
                              tooltip: 'Account',
                            ),
                            _NavIconButton(
                              icon: Icons.shopping_bag_outlined,
                              onPressed: onCartTap,
                              tooltip: 'Cart',
                            ),
                            // Menu icon - only on mobile (Req 2.3)
                            if (!isDesktop)
                              _NavIconButton(
                                icon: Icons.menu,
                                onPressed: () => _openDrawer(context),
                                tooltip: 'Menu',
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Internal widget for navigation icon buttons
class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  const _NavIconButton({
    required this.icon,
    this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: 18,
        color: Colors.grey,
      ),
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
      onPressed: onPressed ?? () {},
      tooltip: tooltip,
    );
  }
}

/// Internal widget for desktop navigation links
class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// A drawer widget for mobile navigation menu.
/// 
/// Should be used with Scaffold's endDrawer property.
/// Menu items close the drawer when tapped (Req 2.4).
/// 
/// Requirements: 2.3, 2.4
class NavbarDrawer extends StatelessWidget {
  const NavbarDrawer({super.key});

  void _navigateAndClose(BuildContext context, String route) {
    Navigator.pop(context); // Close drawer first (Req 2.4)
    if (route == '/') {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Navbar.primaryColor,
              child: const Text(
                'Union Shop',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Menu items (Req 2.3)
            _DrawerMenuItem(
              icon: Icons.home,
              label: 'Home',
              onTap: () => _navigateAndClose(context, '/'),
            ),
            _DrawerMenuItem(
              icon: Icons.collections,
              label: 'Collections',
              onTap: () => _navigateAndClose(context, '/collections'),
            ),
            _DrawerMenuItem(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () => _navigateAndClose(context, '/about'),
            ),
            _DrawerMenuItem(
              icon: Icons.shopping_cart,
              label: 'Cart',
              onTap: () => _navigateAndClose(context, '/cart'),
            ),
            _DrawerMenuItem(
              icon: Icons.person,
              label: 'Account',
              onTap: () => _navigateAndClose(context, '/account'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal widget for drawer menu items
class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Navbar.primaryColor),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
