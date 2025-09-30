import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  Timer? _inactivityTimer;
  bool _sessionExpired = false;

  static const _maxInactivityMinutes = 1;

  AuthProvider() {
    _authService.user.listen((user) {
      _user = user;
      if (_user != null) {
        _startInactivityTimer();
      } else {
        _inactivityTimer?.cancel();
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get sessionExpired => _sessionExpired;

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: _maxInactivityMinutes), _handleInactivity);
  }

  void resetInactivityTimer() {
    if (_user != null) {
      _startInactivityTimer();
    }
  }

  void _handleInactivity() {
    if (isAuthenticated) {
      _sessionExpired = true;
      notifyListeners();
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _authService.signInWithEmailAndPassword(email, password);
    if (userCredential != null) {
      _startInactivityTimer();
    }
    return userCredential;
  }

  Future<UserCredential?> createUserWithEmailAndPassword(String email, String password) async {
    final userCredential = await _authService.createUserWithEmailAndPassword(email, password);
    if (userCredential != null) {
      _startInactivityTimer();
    }
    return userCredential;
  }

  Future<void> signOut() async {
    _inactivityTimer?.cancel();
    _sessionExpired = false;
    await _authService.signOut();
    notifyListeners();
  }
}
