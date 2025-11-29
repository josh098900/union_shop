import 'package:flutter/material.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';

/// Print Shack About page with information about the personalisation service.
///
/// Requirements: 15.4
class PrintShackAboutPage extends StatelessWidget {
  const PrintShackAboutPage({super.key});

  static const Color primaryColor = Color(0xFF4d2963);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const NavbarDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Navbar(),
            _buildAboutContent(context),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isMobile ? 24 : 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              _buildHeader(),
              const SizedBox(height: 48),
              // What is Print Shack section
              _buildSection(
                title: 'What is Print Shack?',
                content:
                    'Print Shack is our custom text personalisation service that allows you to add your own text to selected products. Whether you want your name, a special message, or a custom design, Print Shack makes it possible.\n\n'
                    'We use high-quality printing techniques to ensure your personalised items look great and last long. From t-shirts to mugs, we\'ve got you covered!',
              ),
              const SizedBox(height: 32),
              // How it works section
              _buildHowItWorksSection(),
              const SizedBox(height: 32),
              // Available products section
              _buildAvailableProductsSection(),
              const SizedBox(height: 32),
              // Pricing section
              _buildPricingSection(),
              const SizedBox(height: 32),
              // FAQ section
              _buildFAQSection(),
              const SizedBox(height: 48),
              // CTA button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/print-shack');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Start Personalising Now',
                    style: TextStyle(
                      fontSize: 18,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Icon(
            Icons.print,
            size: 64,
            color: primaryColor,
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            'About Print Shack',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            'Your one-stop shop for personalised merchandise',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
            height: 1.7,
          ),
        ),
      ],
    );
  }


  Widget _buildHowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How It Works',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        _buildStep(
          number: '1',
          title: 'Choose Your Product',
          description:
              'Select from our range of personalisable products including t-shirts, hoodies, mugs, tote bags, and caps.',
        ),
        _buildStep(
          number: '2',
          title: 'Select Your Options',
          description:
              'Pick your preferred font, text colour, and position. Options vary by product type.',
        ),
        _buildStep(
          number: '3',
          title: 'Enter Your Text',
          description:
              'Type in your custom message, name, or design. See it update in real-time on the preview.',
        ),
        _buildStep(
          number: '4',
          title: 'Preview & Order',
          description:
              'Review your design in the live preview, then add to cart and checkout.',
        ),
      ],
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Products',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildProductChip(Icons.checkroom, 'T-Shirts'),
            _buildProductChip(Icons.dry_cleaning, 'Hoodies'),
            _buildProductChip(Icons.coffee, 'Mugs'),
            _buildProductChip(Icons.shopping_bag, 'Tote Bags'),
            _buildProductChip(Icons.sports_baseball, 'Caps'),
          ],
        ),
      ],
    );
  }

  Widget _buildProductChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
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

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Personalisation is available at an additional cost on top of the base product price:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Text personalisation (up to 15 characters)', '£3.00'),
          _buildPriceRow('Text personalisation (16-30 characters)', '£5.00'),
          _buildPriceRow('Premium fonts', '£1.50 extra'),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String item, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
        _buildFAQItem(
          question: 'How long does personalisation take?',
          answer:
              'Personalised items typically take 3-5 business days to produce before shipping.',
        ),
        _buildFAQItem(
          question: 'Can I return personalised items?',
          answer:
              'Due to the custom nature of personalised products, we can only accept returns if there is a manufacturing defect.',
        ),
        _buildFAQItem(
          question: 'What characters can I use?',
          answer:
              'You can use letters (A-Z), numbers (0-9), and basic punctuation. Special characters and emojis are not supported.',
        ),
        _buildFAQItem(
          question: 'Can I see a proof before ordering?',
          answer:
              'Yes! Our real-time preview shows you exactly how your text will appear on the product.',
        ),
      ],
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
