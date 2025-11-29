import 'package:flutter/material.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';

/// About Us page displaying information about the organisation.
///
/// Requirements: 3.1, 3.2, 3.3, 3.4
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const Color primaryColor = Color(0xFF4d2963);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // End drawer for mobile navigation (Req 2.3)
      endDrawer: const NavbarDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Shared navbar component (Req 3.4)
            const Navbar(),

            // About content - distinct from homepage (Req 3.1)
            _buildHeroSection(),

            // Structured content with headings and text (Req 3.2)
            _buildMissionSection(),

            // Brand image/icon section (Req 3.3)
            _buildBrandSection(),

            // Values section with structured content (Req 3.2)
            _buildValuesSection(),

            // Shared footer component (Req 3.4)
            const Footer(),
          ],
        ),
      ),
    );
  }

  /// Hero section for the About page
  /// Requirements: 16.1, 16.2, 16.3, 16.4
  Widget _buildHeroSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final isTablet = screenWidth >= 600 && screenWidth < 1024;
        
        // Responsive sizing
        final titleSize = isMobile ? 28.0 : (isTablet ? 32.0 : 36.0);
        final descSize = isMobile ? 15.0 : (isTablet ? 16.0 : 18.0);
        final verticalPadding = isMobile ? 40.0 : 60.0;
        final horizontalPadding = isMobile ? 16.0 : 24.0;
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          color: primaryColor,
          child: Column(
            children: [
              Text(
                'About Us',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'Learn more about the University of Portsmouth Students\' Union Shop',
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


  /// Mission section with heading and descriptive text (Req 3.2)
  Widget _buildMissionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'Our Mission',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Text(
              'The Union Shop is the official retail outlet of the University of Portsmouth Students\' Union. '
              'We are dedicated to providing students, staff, and visitors with high-quality merchandise, '
              'souvenirs, and essential items that celebrate our university community.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Text(
              'From official university apparel to unique Portsmouth memorabilia, '
              'we offer a wide range of products that help you show your pride in being part of the UoP family.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Brand image/icon section (Req 3.3)
  Widget _buildBrandSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.grey[100],
      child: Column(
        children: [
          // Brand icon/image (Req 3.3)
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(75),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(75),
              child: Image.network(
                'https://shop.upsu.net/cdn/shop/files/upsu_300x300.png?v=1614735854',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: primaryColor,
                    child: const Icon(
                      Icons.store,
                      size: 80,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'University of Portsmouth Students\' Union',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Supporting students since 1992',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  /// Values section with structured content (Req 3.2)
  Widget _buildValuesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'Our Values',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              if (isWide) {
                return const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: _ValueCard(
                      icon: Icons.people,
                      title: 'Community',
                      description: 'We foster a sense of belonging and pride in our university community.',
                    )),
                    SizedBox(width: 24),
                    Expanded(child: _ValueCard(
                      icon: Icons.eco,
                      title: 'Sustainability',
                      description: 'We are committed to environmentally responsible practices.',
                    )),
                    SizedBox(width: 24),
                    Expanded(child: _ValueCard(
                      icon: Icons.star,
                      title: 'Quality',
                      description: 'We provide high-quality products that represent our university well.',
                    )),
                  ],
                );
              } else {
                return const Column(
                  children: [
                    _ValueCard(
                      icon: Icons.people,
                      title: 'Community',
                      description: 'We foster a sense of belonging and pride in our university community.',
                    ),
                    SizedBox(height: 24),
                    _ValueCard(
                      icon: Icons.eco,
                      title: 'Sustainability',
                      description: 'We are committed to environmentally responsible practices.',
                    ),
                    SizedBox(height: 24),
                    _ValueCard(
                      icon: Icons.star,
                      title: 'Quality',
                      description: 'We provide high-quality products that represent our university well.',
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Internal widget for value cards
class _ValueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ValueCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: AboutPage.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
