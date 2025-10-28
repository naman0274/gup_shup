import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gup_shup/data/models/user_model.dart';
import 'package:gup_shup/data/services/base_repository.dart';

class AuthRepository extends BaseRepository {
  /// Stream to listen to authentication state changes (login/logout)
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Sign Up Method
  Future<UserModel> signUp({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final formattedPhoneNumber =
      phoneNumber.replaceAll(RegExp(r'\s+'), "").trim();

      // 🔍 Check if email or phone number already exists
      final emailExists = await checkEmailExists(email);
      if (emailExists) {
        throw "An account with this email already exists.";
      }

      final phoneExists = await checkPhoneExists(formattedPhoneNumber);
      if (phoneExists) {
        throw "An account with this phone number already exists.";
      }

      // ✅ Create user with Firebase Authentication
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw "Failed to create user.";
      }

      // 🧩 Create local user model
      final user = UserModel(
        uid: userCredential.user!.uid,
        username: username,
        fullName: fullName,
        email: email,
        phoneNumber: formattedPhoneNumber,
      );

      // 💾 Save user to Firestore
      await saveUserData(user);

      return user;
    } catch (e) {
      log("SignUp Error: $e");
      rethrow;
    }
  }

  /// ✅ Check if Email Already Exists
  Future<bool> checkEmailExists(String email) async {
    try {
      final querySnapshot = await firestore
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking email existence: $e");
      return false;
    }
  }


  /// ✅ Check if Phone Number Already Exists in Firestore
  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      final formattedPhoneNumber =
      phoneNumber.replaceAll(RegExp(r'\s+'), "").trim();

      final querySnapshot = await firestore
          .collection("users")
          .where("phoneNumber", isEqualTo: formattedPhoneNumber)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking phone number existence: $e");
      return false;
    }
  }

  /// ✅ Sign In Existing User
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw "User not found.";
      }

      final userData = await getUserData(userCredential.user!.uid);
      return userData;
    } catch (e) {
      log("SignIn Error: $e");
      rethrow;
    }
  }

  /// ✅ Save User Data to Firestore
  Future<void> saveUserData(UserModel user) async {
    try {
      await firestore.collection("users").doc(user.uid).set(user.toMap());
    } catch (e) {
      log("Error saving user data: $e");
      throw "Failed to save user data.";
    }
  }

  /// ✅ Sign Out Current User
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// ✅ Fetch User Data from Firestore
  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await firestore.collection("users").doc(uid).get();

      if (!doc.exists) {
        throw "User data not found.";
      }

      log("Fetched user: ${doc.id}");
      return UserModel.fromFirestore(doc);
    } catch (e) {
      log("Error fetching user data: $e");
      throw "Failed to fetch user data.";
    }
  }
}
