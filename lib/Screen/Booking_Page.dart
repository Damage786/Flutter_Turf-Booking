// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Booking extends StatefulWidget {
  const Booking({Key? key}) : super(key: key);

  @override
  _BookingState createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  // late String _email = '';
 
  // bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;

   
  }
  // Show booked turf receipts
  Widget _showBookedTurfReceipts() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: _user.uid) // Filter by user's ID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No receipts available');
        } else {
          return ListView(
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              final receiptId = document.id; // Get the ID of the receipt
              final turfName = data['turfName'] ?? 'Unknown Turf';
              final startDateTime = data['startDateTime'] ?? 'Unknown Start Time';
              final endDateTime = data['endDateTime'] ?? 'Unknown End Time';
              final totalPrice = data['totalPrice'] ?? 'Unknown Price';
              final username = data['userName'] ?? 'Unknown user';
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                child: ListTile(
                  title: Text(turfName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      Text('Start: $startDateTime'),
                      Text('End: $endDateTime'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total Price: $totalPrice'),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteReceipt(receiptId);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  // Delete receipt function
  Future<void> _deleteReceipt(String receiptId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(receiptId)
          .delete();
         ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted succesfully.'),
                    ),
                  );
    } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error deleting receipt: '),
                    ),
                  );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
           const SizedBox(height: 20),
          
            SizedBox(height: 20),
            const Center(
              child: Text(
                'Booked Turf Receipts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _showBookedTurfReceipts(),
            ),
          ],
        ),
      ),
    );
  }
}
