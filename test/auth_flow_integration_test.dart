import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:union_shop/pages/login_page.dart';
import 'package:union_shop/pages/signup_page.dart';
import 'package:union_shop/pages/account_page.dart';
import 'package:union_shop/providers/auth_provider.dart';
import 'package:union_shop/providers/cart_provider.dart';

/// Auth flow integration tests
///
/// Requirements: 17.1, 17.2, 17.3
void main() {
  setUp(() async {
    // Clear shared preferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  group('Auth Flow Integration Tests', () {
    // Helper to create a test app with auth provider
    Widget createTestApp({
      required Widget home,
      AuthProvider? authProvider,
      double height = 1200,
    }) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => authProvider ?? AuthProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => CartProvider(),
          ),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(800, height)),
            child: home,
          ),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Home')),
                );
              case '/login':
                return MaterialPageRoute(builder: (_) => const LoginPage());
              case '/signup':
                return MaterialPageRoute(builder: (_) => const SignupPage());
              case '/account':
                return MaterialPageRoute(builder: (_) => const AccountPage());
              case '/collections':
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Collections')),
                );
              case '/about':
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('About')),
                );
              case '/cart':
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Cart')),
                );
              default:
                return null;
            }
          },
        ),
      );
    }

    group('Registration Flow (Req 17.1)', () {
      testWidgets('should register a new user with valid credentials',
          (tester) async {
        await tester.pumpWidget(createTestApp(home: const SignupPage()));
        await tester.pumpAndSettle();

        // Enter registration details
        await tester.enterText(
          find.byKey(const Key('signup_email_field')),
          'newuser@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('signup_password_field')),
          'password123',
        );
        await tester.enterText(
          find.byKey(const Key('signup_confirm_password_field')),
          'password123',
        );

        // Scroll to make button visible and tap
        await tester.ensureVisible(find.byKey(const Key('signup_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('signup_submit_button')));
        await tester.pumpAndSettle();

        // Should navigate to account page on success
        expect(find.text('My Account'), findsOneWidget);
      });

      testWidgets('should show error for duplicate email registration',
          (tester) async {
        // First, register a user
        final authProvider = AuthProvider();
        await authProvider.register(
          email: 'existing@example.com',
          password: 'password123',
        );
        await authProvider.logout();

        await tester.pumpWidget(createTestApp(
          home: const SignupPage(),
          authProvider: authProvider,
        ));
        await tester.pumpAndSettle();

        // Try to register with same email
        await tester.enterText(
          find.byKey(const Key('signup_email_field')),
          'existing@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('signup_password_field')),
          'password456',
        );
        await tester.enterText(
          find.byKey(const Key('signup_confirm_password_field')),
          'password456',
        );

        await tester.ensureVisible(find.byKey(const Key('signup_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('signup_submit_button')));
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.text('Email already registered'), findsOneWidget);
      });

      testWidgets('should validate password confirmation matches',
          (tester) async {
        await tester.pumpWidget(createTestApp(home: const SignupPage()));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('signup_email_field')),
          'test@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('signup_password_field')),
          'password123',
        );
        await tester.enterText(
          find.byKey(const Key('signup_confirm_password_field')),
          'differentpassword',
        );

        await tester.ensureVisible(find.byKey(const Key('signup_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('signup_submit_button')));
        await tester.pump();

        expect(find.text('Passwords do not match'), findsOneWidget);
      });
    });

    group('Login Flow (Req 17.2)', () {
      testWidgets('should login with valid credentials', (tester) async {
        // First register a user
        final authProvider = AuthProvider();
        await authProvider.register(
          email: 'testuser@example.com',
          password: 'password123',
        );
        await authProvider.logout();

        await tester.pumpWidget(createTestApp(
          home: const LoginPage(),
          authProvider: authProvider,
        ));
        await tester.pumpAndSettle();

        // Enter login credentials
        await tester.enterText(
          find.byKey(const Key('login_email_field')),
          'testuser@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('login_password_field')),
          'password123',
        );

        // Scroll to make button visible and tap
        await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('login_submit_button')));
        await tester.pumpAndSettle();

        // Should navigate to account page on success
        expect(find.text('My Account'), findsOneWidget);
      });

      testWidgets('should show error for incorrect password', (tester) async {
        // First register a user
        final authProvider = AuthProvider();
        await authProvider.register(
          email: 'testuser@example.com',
          password: 'correctpassword',
        );
        await authProvider.logout();

        await tester.pumpWidget(createTestApp(
          home: const LoginPage(),
          authProvider: authProvider,
        ));
        await tester.pumpAndSettle();

        // Enter wrong password
        await tester.enterText(
          find.byKey(const Key('login_email_field')),
          'testuser@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('login_password_field')),
          'wrongpassword',
        );

        await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('login_submit_button')));
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.text('Incorrect password'), findsOneWidget);
      });

      testWidgets('should show error for non-existent email', (tester) async {
        await tester.pumpWidget(createTestApp(home: const LoginPage()));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('login_email_field')),
          'nonexistent@example.com',
        );
        await tester.enterText(
          find.byKey(const Key('login_password_field')),
          'password123',
        );

        await tester.ensureVisible(find.byKey(const Key('login_submit_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('login_submit_button')));
        await tester.pumpAndSettle();

        expect(find.text('Email not found'), findsOneWidget);
      });
    });

    group('Logout Flow (Req 17.3)', () {
      testWidgets('should logout and redirect to home', (tester) async {
        // Create a logged-in user
        final authProvider = AuthProvider();
        await authProvider.register(
          email: 'loggeduser@example.com',
          password: 'password123',
        );

        await tester.pumpWidget(createTestApp(
          home: const AccountPage(),
          authProvider: authProvider,
        ));
        await tester.pumpAndSettle();

        // Verify we're on account page
        expect(find.text('My Account'), findsOneWidget);
        expect(find.text('loggeduser@example.com'), findsOneWidget);

        // Scroll to logout button and tap
        await tester.ensureVisible(find.byKey(const Key('logout_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('logout_button')));
        await tester.pumpAndSettle();

        // Should redirect to home
        expect(find.text('Home'), findsOneWidget);
      });

      testWidgets('should show login prompt on account page when logged out',
          (tester) async {
        await tester.pumpWidget(createTestApp(home: const AccountPage()));
        await tester.pumpAndSettle();

        // Should show login prompt
        expect(find.text('Please log in to view your account.'), findsOneWidget);
        expect(find.text('Login'), findsWidgets);
      });
    });

    group('Account Page Display (Req 17.4)', () {
      testWidgets('should display user email on account page', (tester) async {
        final authProvider = AuthProvider();
        await authProvider.register(
          email: 'display@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        await tester.pumpWidget(createTestApp(
          home: const AccountPage(),
          authProvider: authProvider,
        ));
        await tester.pumpAndSettle();

        expect(find.text('display@example.com'), findsOneWidget);
        expect(find.text('Test User'), findsOneWidget);
      });

      testWidgets('should display order history placeholder', (tester) async {
        final authProvider = AuthProvider();
        await authProvider.register(
          email: 'orders@example.com',
          password: 'password123',
        );

        await tester.pumpWidget(createTestApp(
          home: const AccountPage(),
          authProvider: authProvider,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Order History'), findsOneWidget);
        expect(find.text('No orders yet'), findsOneWidget);
      });
    });
  });
}
