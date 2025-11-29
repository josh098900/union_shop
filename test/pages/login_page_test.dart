import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/pages/login_page.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/providers/auth_provider.dart';
import 'package:union_shop/providers/cart_provider.dart';

void main() {
  group('LoginPage Widget Tests', () {
    // Helper to create a test widget with proper context
    Widget createTestWidget({double width = 800, double height = 1200}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(width, height)),
            child: const LoginPage(),
          ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Home')));
            case '/signup':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Signup')));
            case '/collections':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Collections')));
            case '/about':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('About')));
            case '/cart':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Cart')));
            case '/account':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Account')));
            default:
              return null;
          }
        },
        ),
      );
    }

    group('Page Structure', () {
      testWidgets('should include Navbar component', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(Navbar), findsOneWidget);
      });

      testWidgets('should include Footer component', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byType(Footer), findsOneWidget);
      });

      testWidgets('should display Login title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Login'), findsWidgets);
      });
    });

    group('Form Fields (Req 9.1)', () {
      testWidgets('should display email input field with label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check for email label
        expect(find.text('Email'), findsOneWidget);
        
        // Check for email text field
        expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      });

      testWidgets('should display password input field with label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check for password label
        expect(find.text('Password'), findsOneWidget);
        
        // Check for password text field
        expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      });
    });

    group('Submit Button (Req 9.3)', () {
      testWidgets('should display login submit button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      });

      testWidgets('submit button should be an ElevatedButton', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final button = tester.widget<ElevatedButton>(
          find.byKey(const Key('login_submit_button')),
        );
        expect(button, isNotNull);
      });
    });

    group('Validation Messages (Req 9.4)', () {
      testWidgets('should show email error when submitting empty email', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Scroll to make button visible and tap
        await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('login_submit_button')));
        await tester.pump();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('should show password error when submitting empty password', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Enter email but not password
        await tester.enterText(find.byKey(const Key('login_email_field')), 'test@example.com');
        await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('login_submit_button')));
        await tester.pump();

        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('should show invalid email error for malformed email', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Enter invalid email
        await tester.enterText(find.byKey(const Key('login_email_field')), 'invalid-email');
        await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('login_submit_button')));
        await tester.pump();

        expect(find.text('Please enter a valid email'), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('should have link to signup page', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text("Don't have an account? "), findsOneWidget);
        expect(find.text('Sign up'), findsOneWidget);
      });
    });
  });
}
