// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Jarcería App';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get invalidEmail =>
      'Por favor, introduce una dirección de correo electrónico válida.';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get loginFailed =>
      'No se pudo iniciar sesión. Por favor, comprueba tus credenciales.';

  @override
  String get userNotFound =>
      'No se encontró ningún usuario con ese correo electrónico.';

  @override
  String get wrongPassword => 'La contraseña proporcionada es incorrecta.';

  @override
  String get createNewAccount => 'Crear una nueva cuenta';

  @override
  String get continueAsGuest => 'Continuar como invitado';

  @override
  String get signup => 'Registrarse';

  @override
  String get signupFailed =>
      'No se pudo registrar. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirmation =>
      '¿Estás seguro de que quieres cerrar la sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get products => 'Productos';

  @override
  String get myCart => 'Mi Carrito';

  @override
  String get orderHistory => 'Historial de Órdenes';

  @override
  String get searchProducts => 'Buscar productos...';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortZA => 'Z-A';

  @override
  String get priceAsc => 'Precio Ascendente';

  @override
  String get priceDesc => 'Precio Descendente';

  @override
  String get twoPerRow => '2 por fila';

  @override
  String get threePerRow => '3 por fila';

  @override
  String get fourPerRow => '4 por fila';

  @override
  String get all => 'Todos';

  @override
  String get noProductsFound => 'No se encontraron productos';

  @override
  String get tryAnotherSearch => 'Intenta con otra búsqueda';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get sessionExpiredTitle => 'Sesión Expirada';

  @override
  String get sessionExpiredContent =>
      'Tu sesión ha expirado por inactividad. Por favor, inicia sesión de nuevo.';

  @override
  String get ok => 'OK';
}
