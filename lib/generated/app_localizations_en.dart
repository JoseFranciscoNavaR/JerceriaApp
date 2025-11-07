// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Jarceria App';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters long.';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get userNotFound => 'No user found with that email.';

  @override
  String get wrongPassword => 'The password provided is incorrect.';

  @override
  String get createNewAccount => 'Create a new account';

  @override
  String get continueAsGuest => 'Continue as guest';

  @override
  String get signup => 'Sign Up';

  @override
  String get signupFailed => 'Sign up failed. Please try again later.';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get products => 'Products';

  @override
  String get myCart => 'My Cart';

  @override
  String get orderHistory => 'Order History';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortZA => 'Z-A';

  @override
  String get priceAsc => 'Price Ascending';

  @override
  String get priceDesc => 'Price Descending';

  @override
  String get twoPerRow => '2 per row';

  @override
  String get threePerRow => '3 per row';

  @override
  String get fourPerRow => '4 per row';

  @override
  String get all => 'All';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get tryAnotherSearch => 'Try another search';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get sessionExpiredTitle => 'Session Expired';

  @override
  String get sessionExpiredContent =>
      'Your session has expired due to inactivity. Please log in again.';

  @override
  String get ok => 'OK';
}
