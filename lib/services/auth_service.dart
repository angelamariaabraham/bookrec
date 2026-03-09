import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  success,
  userNotFound,
  wrongPassword,
  emailAlreadyExists,
  failure,
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AuthStatus> login(String email, String password) async {
    try {
      await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .timeout(const Duration(seconds: 10));
      return AuthStatus.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return AuthStatus.userNotFound;
      } else if (e.code == 'wrong-password') {
        return AuthStatus.wrongPassword;
      }
      return AuthStatus.failure;
    } catch (_) {
      return AuthStatus.failure;
    }
  }

  Future<AuthStatus> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .timeout(const Duration(seconds: 10));

      // Set the display name
      await result.user?.updateDisplayName(name.trim());

      return AuthStatus.success;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return AuthStatus.emailAlreadyExists;
      }
      return AuthStatus.failure;
    } catch (_) {
      return AuthStatus.failure;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  Future<String?> getUserName() async {
    return _auth.currentUser?.displayName;
  }

  String? getUserId() {
    return _auth.currentUser?.uid;
  }
}
