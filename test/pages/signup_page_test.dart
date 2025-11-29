import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:union_shop/pages/signup_page.dart';
import 'package:union_shop/widgets/navbar.dart';
import 'package:union_shop/widgets/footer.dart';
import 'package:union_shop/providers/auth_provider.dart';
import 'package:union_shop/providers/cart_provider.dart';

void main() {
  group('SignupPage Widget Tests', () {
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
            child: const SignupPage(),
          ),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Home')));
            case '/login':
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Login')));
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

      testWidgets('should display Create Account title', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Create Account'), findsOneWidget);
      });
    });

    group('Registration Fields (Req 9.2)', () {
      testWidgets('should display email input field with label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check for email label
        expect(find.text('Email'), findsOneWidget);
        
        // Check for email text field
        expect(find.byKey(const Key('signup_email_field')), findsOneWidget);
      });

      testWidgets('should display password input field with label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check for password label
        expect(find.text('Password'), findsOneWidget);
        
        // Check for password text field
        expect(find.byKey(const Key('signup_password_field')), findsOneWidget);
      });

      testWidgets('should display confirm password input field with label', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Check for confirm password label
        expect(find.text('Confirm Password'), findsOneWidget);
        
        // Check for confirm password text field
        expect(find.byKey(const Key('signup_confirm_password_field')), findsOneWidget);
      });
    });

    group('Submit Button (Req 9.3)', () {
      testWidgets('should display signup submit button', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.byKey(const Key('signup_submit_button')), findsOneWidget);
      });

      testWidgets('submit button should be an ElevatedButton', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        final button = tester.widget<ElevatedButton>(
          find.byKey(const Key('signup_submit_button')),
        );
        expect(button, isNotNull);
      });
    });

    group('Validation Messages (Req 9.4)', () {
      testWidgets('should show email error when submitting empty email', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Scroll to make button visible and tap
        await tester.ensureVisible(find.byKey(const Key('signup_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('signup_submit_button')));
        await tester.pump();

        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('should show password error when submitting empty password', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Enter email but not password
        await tester.enterText(find.byKey(const Key('signup_email_field')), 'test@example.com');
        await tester.ensureVisible(find.byKey(const Key('signup_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('signup_submit_button')));
        await tester.pump();

        expect(find.text('Password is required'), findsOneWidget);
      });

      testWidgets('should show confirm password error when passwords do not match', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Enter email and different passwords
        await tester.enterText(find.byKey(const Key('signup_email_field')), 'test@example.com');
        await tester.enterText(find.byKey(const Key('signup_password_field')), 'password123');
        await tester.enterText(find.byKey(const Key('signup_confirm_password_field')), 'different');
        await tester.ensureVisible(find.byKey(const Key('signup_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('signup_submit_button')));
        await tester.pump();

        expect(find.text('Passwords do not match'), findsOneWidget);
      });

      testWidgets('should show invalid email error for malformed email', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // Enter invalid email
        await tester.enterText(find.byKey(const Key('signup_email_field')), 'invalid-email');
        await tester.ensureVisible(find.byKey(const Key('signup_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('signup_submit_button')));
        await tester.pump();

        expect(find.text('Please enter a valid email'), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('should have link to login page', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        expect(find.text('Already have an account? '), findsOneWidget);
        expect(find.text('Login'), findsOneWidget);
      });
    });
  });
}
