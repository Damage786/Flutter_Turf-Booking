import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reactive_theme/reactive_theme.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late String _email = '';
  late String _profileImageUrl = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _email = _user.email ?? '';
    // Fetch profile image URL if available
    _fetchProfileImageUrl();
  }

  // Fetch profile image URL
  Future<void> _fetchProfileImageUrl() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Fetch profile image URL from Firebase Storage
      String imageUrl = await FirebaseStorage.instance
          .ref('profile_images/${_user.uid}.jpg')
          .getDownloadURL();
      setState(() {
        _profileImageUrl = imageUrl;
      });
    } catch (e) {
      // Handle error if profile image does not exist
      print('Profile image not found: $e');
      // Set a default profile image URL if the user doesn't have one
      _profileImageUrl = 'https://i.stack.imgur.com/l60Hf.png';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Upload profile image
  Future<void> _uploadImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isLoading = true;
      });

      // Upload image to Firebase Storage
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/${_user.uid}.jpg');
      UploadTask uploadTask = storageReference.putFile(File(image.path));
      await uploadTask.whenComplete(() {
        // Refresh profile image URL after upload is complete
        _fetchProfileImageUrl();
        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      // Handle error when picking image or uploading
      print('Error picking/uploading image: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show booked turf receipts

  // Delete receipt function
  Future<void> _deleteReceipt(String receiptId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(receiptId)
          .delete();
      print('Receipt deleted successfully');
    } catch (e) {
      print('Error deleting receipt: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImageUrl.isNotEmpty
                        ? NetworkImage(_profileImageUrl)
                        : const AssetImage(
                                'https://i.stack.imgur.com/l60Hf.png')
                            as ImageProvider<Object>?,
                    child: _profileImageUrl.isEmpty
                        ? Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  if (_isLoading)
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black26,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _uploadImage,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Email: $_email',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                // color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              width: 250, // Adjust the width as per your requirement
              child: const ListTile(
                title: Text('Choose Theme'),
                trailing: ReactiveSwitch(),
              ),
            ),
            

            //  const SizedBox(height: 20), const Center(child: ReactiveThemeBtn()),
          ],
        ),
      ),
    );
  }
}
