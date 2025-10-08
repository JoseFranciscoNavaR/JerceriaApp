import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../providers/auth_provider.dart';
import 'user_signup_screen.dart';
import 'home_screen.dart';
import 'admin/admin_panel_screen.dart';
import '../generated/app_localizations.dart';

class UserLoginScreen extends HookWidget {
  const UserLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final email = useState('');
    final password = useState('');
    final errorMessage = useState<String?>(null);
    final authProvider = Provider.of<AuthProvider>(context);

    Future<void> tryLogin() async {
      final isValid = formKey.currentState?.validate() ?? false;
      if (!isValid) {
        return;
      }
      formKey.currentState?.save();

      if (email.value == 'admin' && password.value == 'admin') {
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
            (Route<dynamic> route) => false);
        return;
      }

      try {
        await authProvider.signInWithEmailAndPassword(email.value, password.value);
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false);
      } catch (error) {
        if (!context.mounted) return;
        errorMessage.value = AppLocalizations.of(context)!.loginFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage.value!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Acceso de Usuario', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.person_outline,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.login,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        key: const ValueKey('email'),
                        validator: (value) {
                          if (value != 'admin' && (value == null || !value.contains('@'))) {
                            return l10n.invalidEmail;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          email.value = value?.trim() ?? '';
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: l10n.email,
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        key: const ValueKey('password'),
                        validator: (value) {
                           if (value != 'admin' && (value == null || value.length < 7)) {
                            return l10n.passwordTooShort;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          password.value = value?.trim() ?? '';
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: l10n.password,
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: tryLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            l10n.login,
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        child: Text(l10n.createNewAccount),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const UserSignupScreen(),
                          ));
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: Text(l10n.continueAsGuest),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
