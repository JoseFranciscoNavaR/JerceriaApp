import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../generated/app_localizations.dart';
import 'home_screen.dart';

class UserSignupScreen extends StatefulWidget {
  const UserSignupScreen({super.key});

  @override
  UserSignupScreenState createState() => UserSignupScreenState();
}

class UserSignupScreenState extends State<UserSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String? _errorMessage;

  Future<void> _trySignUp() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    _formKey.currentState?.save();
    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .createUserWithEmailAndPassword(_email, _password);
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false);
      }
    } catch (error) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.signupFailed;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(l10n.signup, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.signup,
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
                          if (value == null || !value.contains('@')) {
                            return l10n.invalidEmail;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value ?? '';
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
                          if (value == null || value.length < 7) {
                            return l10n.passwordTooShort;
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value ?? '';
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
                          onPressed: _trySignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            l10n.signup,
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
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
