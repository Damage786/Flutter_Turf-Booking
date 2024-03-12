import 'package:flutter/material.dart';

class BookingSlotsProvider extends ChangeNotifier {
  late List<TurfSlot> bookingSlots;

  BookingSlotsProvider(List<TurfSlot> slots) {
    bookingSlots = slots;
  }

  void updateSlotAvailability(int index, bool isAvailable) {
    bookingSlots[index].isAvailable = isAvailable;
    notifyListeners();
  }
}

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
