import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  final _auth = FirebaseAuth.instance;

  @override
  Future<User?> build() async {
    return _auth.currentUser;
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '1041280523312-vkd005q8envoj7b6t829pj5li90sqcnt.apps.googleusercontent.com',
      );
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      state = AsyncData(result.user);
    } catch (e) {
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        state = const AsyncData(null);
        return;
      }
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null && !result.user!.emailVerified) {
        await _auth.signOut();
        throw Exception(
          'Email not verified. Please check your inbox and click the verification link.',
        );
      }
      state = AsyncData(result.user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncLoading();
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.sendEmailVerification();
      await _auth.signOut();
      state = AsyncError(
        'Verification email sent! Please check your inbox and verify before signing in.',
        StackTrace.empty,
      );
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
    state = const AsyncData(null);
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      state = AsyncValue.error(
        Exception('Password reset link sent to $email'),
        StackTrace.current,
      );
    } catch (e) {
      state = AsyncValue.error(Exception(e.toString()), StackTrace.current);
    }
  }
}
