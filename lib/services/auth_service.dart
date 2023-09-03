import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {

  static Future<bool> signInWithGoogle() async {
    bool out;
    print('---> firebase service > signInWithGoogle()');

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      print('---> google user: $googleUser');
      print('---> google user email: ${googleUser?.email}');

      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;

        print('---> google auth access token: ${googleAuth.accessToken}');
        print('---> google auth id token: ${googleAuth.idToken}');
        out = true;
      } else {
        out = false;
      }
    } catch (err) {
      print('---> google auth > catch error > $err');
      out = false;
    }
    return Future.value(out);
  }

  static Future<String?> signInWithApple() async {
    String? out;
    try {
      final res0 = await SignInWithApple.isAvailable();
      print('---> sign in with apple > available: $res0');
      if (res0) {
        final res1 = await SignInWithApple.getAppleIDCredential(scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ]);

        print('---> getAppleIDCredential > result: $res1');

        out = res1.email;
      }
    } catch (error) {
      // Handle any errors that occurred during the sign-in process
      print('---> Error signing in with Apple: $error');
    }
    return out;
  }
}
