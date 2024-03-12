import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uiproject/Screen/Home_page.dart';

// Define the TurfSlot class
class TurfSlot {
  final DateTime startTime;
  final DateTime endTime;
  bool isAvailable;
  bool isBooked;
  DateTime? bookingExpirationTime; // New property to store booking expiration time

  TurfSlot({
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.isBooked = false,
    this.bookingExpirationTime, // Initialize with null
  });
}

class BookingSlots extends ChangeNotifier {
  late List<TurfSlot> _slots;

  BookingSlots() {
    _initializeSlots();
    _initializeBookedSlots(); // Initialize booked slots
  }

  void _initializeSlots() {
    // Initialize slots here
    _slots = List.generate(5, (index) => TurfSlot(
      startTime: DateTime.now().add(Duration(hours: 3 * index)),
      endTime: DateTime.now().add(Duration(hours: 3 * (index + 1))),
      isAvailable: true,
    ));
  }

  void _initializeBookedSlots() {
    // Initialize booked slots
    _slots[0].isBooked = true;
    _slots[0].bookingExpirationTime = DateTime.now().add(Duration(minutes: 30)); // Example: Booking expires in 30 minutes
  }

  List<TurfSlot> get slots => _slots;

  void bookSlot(int index) {
    if (_slots[index].isAvailable) {
      _slots[index].isBooked = true;
      _slots[index].bookingExpirationTime = DateTime.now().add(Duration(minutes: 30)); // Example: Booking expires in 30 minutes
      notifyListeners(); // Notify listeners after updating
    }
  }

  void updateAvailability() {
    // Update availability logic here
    notifyListeners(); // Notify listeners after updating
  }
}

class BookingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bookingSlots = Provider.of<BookingSlots>(context).slots;

    // Use bookingSlots to display slots
    return ListView.builder(
      itemCount: bookingSlots.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Slot ${index + 1}'),
          subtitle: bookingSlots[index].isBooked
              ? Text('Booked until ${bookingSlots[index].bookingExpirationTime}')
              : Text('Available'),
          onTap: () {
            if (!bookingSlots[index].isBooked) {
              Provider.of<BookingSlots>(context, listen: false).bookSlot(index);
            }
          },
        );
      },
    );
  }
}

