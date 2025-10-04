import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart' as app_auth_provider;
import 'generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => app_auth_provider.AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => NavigationProvider()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(
            secondary: Colors.amber,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  AuthWrapperState createState() => AuthWrapperState();
}

class AuthWrapperState extends State<AuthWrapper> {
  bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<app_auth_provider.AuthProvider>(
      builder: (context, auth, child) {
        if (auth.sessionExpired && !_isDialogShowing) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isDialogShowing = true;
              });
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext ctx) {
                  final l10n = AppLocalizations.of(context)!;
                  return AlertDialog(
                    title: Text(l10n.sessionExpiredTitle),
                    content: Text(l10n.sessionExpiredContent),
                    actions: <Widget>[
                      TextButton(
                        child: Text(l10n.ok),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          auth.signOut();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (Route<dynamic> route) => false,
                          );
                          setState(() {
                            _isDialogShowing = false;
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            }
          });
        }

        return GestureDetector(
          onTap: () {
            auth.resetInactivityTimer();
          },
          behavior: HitTestBehavior.translucent,
          child: const HomeScreen(),
        );
      },
    );
  }
}
