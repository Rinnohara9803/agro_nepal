import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../services/shared_service.dart';

class ProfileProvider with ChangeNotifier {
  String _userName = '';
  String _imageUrl = '';
  String _email = '';
  String get userName {
    return _userName;
  }

  String get email {
    return _email;
  }

  String get imageUrl {
    return _imageUrl;
  }

  Future<void> fetchProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then(
        (data) {
          SharedService.email = data['email'];
          SharedService.userName = data['userName'];
          SharedService.userImageUrl = data['imageUrl'];

          _userName = SharedService.userName;
          notifyListeners();
          _imageUrl = SharedService.userImageUrl;
          notifyListeners();
          _email = SharedService.email;
          notifyListeners();

          var tag = data['tag'];
          if (tag == 'admin') {
            SharedService.isUserAdmin = true;
          } else {
            SharedService.isUserAdmin = false;
          }
        },
      );
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }

  Future<void> updateProfile(String newUserName, String newUserImageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'userName': newUserName, 'imageUrl': newUserImageUrl}).then((value) {
        SharedService.userName = newUserName;
        SharedService.userImageUrl = newUserImageUrl;
        _userName = newUserName;
        notifyListeners();
        _imageUrl = newUserImageUrl;
        notifyListeners();
      });
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }

  Future<void> deleteProfile() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
    } catch (e) {
      return Future.error(
        e.toString(),
      );
    }
  }
}
