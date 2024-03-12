  import 'package:flutter/material.dart';
  import 'dart:async';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:carousel_slider/carousel_slider.dart';
  import 'package:provider/provider.dart';
  import 'package:uiproject/Screen/Home_page.dart';
  import 'package:collection/collection.dart';
  import 'package:timezone/data/latest.dart' as tz;
  import 'package:timezone/timezone.dart' as tz;

  class TurfSlot {
    final DateTime startTime;
    final DateTime endTime;
    bool isAvailable;
    bool isBooked;

    TurfSlot({
      required this.startTime,
      required this.endTime,
      this.isAvailable = true,
      this.isBooked = false,
    });
  }

  class BookingSlotsProvider extends ChangeNotifier {
    late List<TurfSlot> bookingSlots;

    BookingSlotsProvider(List<TurfSlot> slots) {
      bookingSlots = slots;
    }

    void updateSlotAvailability(int index, bool isAvailable) {
      bookingSlots[index].isAvailable = isAvailable;
      notifyListeners(); // Notify listeners about the change
    }
  }

  class TurfDetailPage extends StatefulWidget {
    final Turf turf;
    final List<String> carouselImages;

    const TurfDetailPage({
      Key? key,
      required this.turf,
      required this.carouselImages,
    }) : super(key: key);

    @override
    _TurfDetailPageState createState() => _TurfDetailPageState();
  }

  class _TurfDetailPageState extends State<TurfDetailPage> {
    late List<TurfSlot> bookingSlots;
    late StreamSubscription<QuerySnapshot> subscription;
    late Timer timer;

    @override
    void initState() {
      super.initState();
      tz.initializeTimeZones();
      bookingSlots = _generateBookingSlotsForTurf(widget.turf);
      _setupSlotAvailabilityListener();
       _startAvailabilityTimer();
       _startTimer(); // Start the timer to check slot availability periodically
    }

    @override
    void dispose() {
      subscription.cancel();
      timer.cancel(); // Dispose the timer to prevent memory leaks
      super.dispose();
    }

    void _startTimer() {
      timer = Timer.periodic(Duration(minutes: 1), (Timer t) {
        _updateAvailability();
      });
    }

    void _setupSlotAvailabilityListener() {
      subscription = FirebaseFirestore.instance
          .collection('booked_slots')
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        setState(() {
          for (var slot in bookingSlots) {
            var doc = snapshot.docs.firstWhereOrNull(
              (doc) =>
                  doc['startTime'] == slot.startTime &&
                  doc['endTime'] == slot.endTime,
            );

            if (doc != null) {
              slot.isAvailable = false;
              slot.isBooked = true;
            } else {
              slot.isAvailable = true;
              slot.isBooked = false;
            }
          }
        });
      });
    }

void _startAvailabilityTimer() {
  // Set up a timer to refresh availability every 5 seconds
  Timer.periodic(Duration(seconds: 5), (Timer timer) {
    _updateAvailability();
  });
}

void _updateAvailability() {
  // Convert current time to Indian timezone
  DateTime currentTime = tz.TZDateTime.now(tz.getLocation('Asia/Kolkata'));

  // Fetch the booked slots from Firestore
  FirebaseFirestore.instance
      .collection('booked_slots')
      .get()
      .then((QuerySnapshot querySnapshot) {
    if (querySnapshot.docs.isNotEmpty) {
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        DateTime endTime = documentSnapshot['endTime'].toDate(); // Convert Firestore timestamp to DateTime
        // Convert endTime to Indian timezone
        endTime = tz.TZDateTime.from(endTime, tz.getLocation('Asia/Kolkata'));
        if (currentTime.isAfter(endTime)) {
          // Update Firestore document to mark slot as available
          documentSnapshot.reference.update({
            'isAvailable': true,
            'isBooked': false,
          });

          // Update the slot object to mark it as available
          for (var slot in bookingSlots) {
            if (slot.startTime == documentSnapshot['startTime'].toDate() && slot.endTime == endTime) {
              slot.isAvailable = true;
              slot.isBooked = false;
              break;
            }
          }
        }
      }

      // Update the UI to reflect changes
      setState(() {});
    }
  }).catchError((error) {
    print('Error getting booked slots: $error');
  });
}






List<TurfSlot> _generateBookingSlotsForTurf(Turf turf) {
  List<TurfSlot> slots = [];
  DateTime startTime = _getStartTimeOfDay();
  DateTime endTime = _getEndTimeOfDay();

  while (startTime.isBefore(endTime)) {
    TurfSlot slot = TurfSlot(
      startTime: startTime,
      endTime: startTime.add(Duration(hours: 3)),
    );

    // Fetch booking information from Firestore to determine availability
    FirebaseFirestore.instance
        .collection('booked_slots')
        .where('turfId', isEqualTo: turf.id) // Filter by turf ID
        .where('startTime', isEqualTo: _convertToIndianTime(startTime)) // Convert to Indian time
        .where('endTime', isEqualTo: _convertToIndianTime(slot.endTime)) // Convert to Indian time
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          var doc = querySnapshot.docs.first;
          bool isAvailable = doc['isAvailable'];
          bool isBooked = doc['isBooked'];
          slot.isAvailable = isAvailable;
          slot.isBooked = isBooked;
        });
      }
    }).catchError((error) {
      print("Error getting documents: $error");
    });

    slots.add(slot);
    startTime = startTime.add(const Duration(hours: 3));
  }

  return slots;
}


    DateTime _convertToIndianTime(DateTime time) {
  return tz.TZDateTime.from(time, tz.getLocation('Asia/Kolkata'));
}
    DateTime _getStartTimeOfDay() {
  DateTime currentTime = _convertToIndianTime(DateTime.now());
  return DateTime(currentTime.year, currentTime.month, currentTime.day, 5, 0);
}

   DateTime _getEndTimeOfDay() {
  DateTime currentTime = _convertToIndianTime(DateTime.now());
  return DateTime(currentTime.year, currentTime.month, currentTime.day, 22, 0);
}
    String _formatTime(DateTime time) {
  String period = time.hour < 12 ? 'AM' : 'PM';
  int hour = time.hour > 12 ? time.hour - 12 : time.hour;
  return '$hour:${time.minute.toString().padLeft(2, '0')} $period IST'; // Add 'IST' for Indian timezone
}

    @override
    Widget build(BuildContext context) {
      final provider = Provider.of<BookingSlotsProvider>(context);

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.turf.name),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 250.0,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  enableInfiniteScroll: true,
                  autoPlay: true,
                ),
                items: widget.carouselImages.map((image) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Image.asset(
                          'assets/$image',
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location: ${widget.turf.location}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Make payment on Turf',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    const Text(
                      'Turf Specifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 20),
                    const Text(
                      'Rules',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRuleItem('NO SMOKING'),
                        _buildRuleItem('NO ALCOHOL CONSUMPTION'),
                        _buildRuleItem('NO SPITTING'),
                        _buildRuleItem('Open 5Am To 9Pm'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showBookingForm(context);
                        },
                        child: const Text('Book'),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: bookingSlots.map((slot) {
                  if (slot.startTime.hour >= 5 && slot.startTime.hour < 22) {
                    String startTime = _formatTime(slot.startTime);
                    String endTime = _formatTime(slot.endTime);
                    String slotStatus = slot.isAvailable ? 'Available' : 'Booked';

                    return ListTile(
                      title: Text('Slot: $startTime - $endTime'),
                      subtitle: Text(slotStatus),
                      onTap: () {
                        if (slot.isAvailable) {
                          _showBookingForm(context, slot);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('This slot is already booked.'),
                            ),
                          );
                        }
                      },
                    );
                  } else {
                    return const SizedBox();
                  }
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }

    void _showBookingForm(BuildContext context, [TurfSlot? slot]) {
      if (slot != null && !slot.isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This slot is already booked.'),
          ),
        );
        return;
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String userName = '';
          String address = '';
          String email = '';
          String mobileNumber = '';
          DateTime? startDateTime = slot?.startTime;
          DateTime? endDateTime = slot?.endTime;
          double totalPrice = 0.0;

          final emailController = TextEditingController();
          final mobileController = TextEditingController();

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Book Turf'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(labelText: 'Name'),
                        onChanged: (value) {
                          userName = value;
                        },
                      ),
                      TextField(
                        decoration: InputDecoration(labelText: 'Address'),
                        onChanged: (value) {
                          address = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Mobile Number'),
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 10 ||
                              int.tryParse(value) == null) {
                            return 'Enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: () {
                          if (slot == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select a slot.'),
                              ),
                            );
                            return;
                          }
                          totalPrice =
                              _calculatePrice(startDateTime!, endDateTime!);
                          setState(() {});
                        },
                        child: Text('Calculate Price'),
                      ),
                      if (startDateTime != null && endDateTime != null)
                        Text(
                          'Total Price: ₹${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (emailController.text.isEmpty ||
                          mobileController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Please fill all the fields',
                              style: TextStyle(color: Colors.red),
                            ),
                            backgroundColor: Colors.grey[900],
                          ),
                        );
                      } else if (startDateTime == null || endDateTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please select a date and time range')),
                        );
                      } else {
                        _bookTurf(
                            userName,
                            address,
                            emailController.text,
                            mobileController.text,
                            startDateTime!,
                            endDateTime!,
                            totalPrice);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Book'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    double _calculatePrice(DateTime startDateTime, DateTime endDateTime) {
      int durationInHours = endDateTime.difference(startDateTime).inHours;
      double pricePerHour = 500.0;
      double totalPrice = durationInHours * pricePerHour;
      return totalPrice;
    }

 void _bookTurf(
    String userName,
    String address,
    String email,
    String mobileNumber,
    DateTime startDateTime,
    DateTime endDateTime,
    double totalPrice,
) async {
  try {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    // Convert startDateTime and endDateTime to Indian time
    DateTime indianStartTime = _convertToIndianTime(startDateTime);
    DateTime indianEndTime = _convertToIndianTime(endDateTime);

    await FirebaseFirestore.instance.collection('bookings').add({
      'userId': userId,
      'userName': userName,
      'address': address,
      'email': email,
      'mobileNumber': mobileNumber,
      'startDateTime': indianStartTime.toIso8601String(), // Use Indian time
      'endDateTime': indianEndTime.toIso8601String(), // Use Indian time
      'totalPrice': totalPrice,
      'turfId': widget.turf.id, // Add the turf ID to the booking data
      'turfName': widget.turf.name,
    });

    // Update Firestore with booking status using Indian time
    await FirebaseFirestore.instance.collection('booked_slots').add({
      'startTime': indianStartTime,
      'endTime': indianEndTime,
      'isAvailable': false,
      'isBooked': true,
      'turfId': widget.turf.id, // Add the turf ID to the booked slot
    });

    // Refresh UI or update state to reflect booking status
    setState(() {
      for (var slot in bookingSlots) {
        // Convert slot start and end times to Indian time for comparison
        DateTime slotStartIndianTime = _convertToIndianTime(slot.startTime);
        DateTime slotEndIndianTime = _convertToIndianTime(slot.endTime);
        if (slotStartIndianTime == indianStartTime &&
            slotEndIndianTime == indianEndTime) {
          slot.isAvailable = false;
          slot.isBooked = true;
          break;
        }
      }
    });

    // Show confirmation message or perform any additional actions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The turf has been booked.'),
        backgroundColor: Colors.green,
      ),
    );

    // Update slot availability immediately after booking
    _updateAvailability();
  } catch (e) {
    print('Error adding document: $e');
    // Handle errors appropriately
  }
}


    Widget _buildRuleItem(String rule) {
      return Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 5),
          Text(rule),
        ],
      );
    }
  }


class CardWidget extends StatelessWidget {
  final Turf turf;

  const CardWidget({Key? key, required this.turf}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(turf.id),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                height: 120,
                width: 120,
                child: Image.asset(
                  'assets/${turf.imageUrl}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turf.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      turf.location,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
