import 'package:gup_shup/data/models/user_model.dart';
import 'package:gup_shup/data/services/base_repository.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactRepository extends BaseRepository {
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<bool> get requestContactsPermission async {
    return await FlutterContacts.requestPermission();
  }

  Future<List<Map<String, dynamic>>> getRegisterContacts() async {
    try {
      // get device Contacts with phone number
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      //    extact phone numbers and normalize them
      final phoneNumbers = contacts.where((contact) =>
      contact.phones.isNotEmpty).map((contact) =>
      {
        'name': contact.displayName,
        'phoneNumber': contact.phones.first.number.replaceAll(
          RegExp(r'[^\d+]'),
          '',
        ),
        'photo': contact.photo, // Store contact photo if available
      },
      )
          .toList();

      //    get all users from firestore
      final userSnapshot = await firestore.collection("users").get();

      final registeredUsers = userSnapshot.docs.map((doc) =>
          UserModel.fromFirestore(doc)).toList();

      //    match contacts with registered users
      final matchedContacts = phoneNumbers.where((contact) {
        final phoneNumber = contact["phoneNumber"];
        return registeredUsers.any(
                (user) =>
            user.phoneNumber == phoneNumber && user.uid !=
                currentUserId);
      }).map((contact) {
        final registeredUser = registeredUsers.firstWhere((user) =>
        user.phoneNumber == contact["phonenumber"]);
        return{
          'id': registeredUser.uid,
          'name':contact['name'],
          'phoneNumber': contact['phoneNumber'],
        };
      }).toList();
return matchedContacts;
    } catch (e) {
      print("error getting registered users");
      return [];
    }
  }
}
