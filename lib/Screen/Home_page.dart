// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:uiproject/Screen/turf_Detailpage.dart';
import 'package:uiproject/models/authentication.dart';
import 'package:uiproject/Screen/turf_Detailpage.dart' as TurfPage;
import 'package:uiproject/Screen/bookingpage_state.dart';
// import 'package:uiproject/models/turf_slot.dart'; // Import the file where TurfSlot is defined


class TurfSlot {
  final DateTime startTime;
  final DateTime endTime;
  bool isAvailable;
  String isBooked;

  TurfSlot({
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.isBooked = '',
  });
}

class Turf {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String additionalDetail;
  final String size;
  final int prize;
  final List<TurfSlot> timeSlots; // Each turf has its own set of time slots

  Turf({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.additionalDetail,
    required this.size,
    required this.prize,
    required this.timeSlots,
  });
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();

  final List<Turf> turfs = [
    Turf(
      id: '1',
      name: 'NHGSA, Mira Road - by SPORLOC',
      location: 'Rooftop, Prema Laxman Vidyalaya, Penkarpada Rd, Mira Road, Mira Bhayandar, Mumbai 401107',
      imageUrl: 'turf1.jpg',
      size: '2mtrsx25.5mtrs',
      prize: 800,
      additionalDetail: '',
      timeSlots: List.generate(5, (index) => TurfSlot(
        startTime: DateTime.now().add(Duration(hours: 3 * index)),
        endTime: DateTime.now().add(Duration(hours: 3 * (index + 1))),
        isAvailable: true,
        isBooked: '',
      )),
    ),
    Turf(
      id: '2',
      name: 'UMRB Turf, Azad Nagar - by SPORLOC',
      location: 'Backgate, Andheri Sports Complex, Veera Desai Road, Next To Azad Nagar Metro Station, Mumbai 400053.',
      imageUrl: 'turf2.jpg',
      size: '2mtrsx25.5mtrs',
      prize: 700,
      additionalDetail: '', 
      timeSlots: List.generate(5, (index) => TurfSlot(
        startTime: DateTime.now().add(Duration(hours: 3 * index)),
        endTime: DateTime.now().add(Duration(hours: 3 * (index + 1))),
        isAvailable: true,
        isBooked: '',
      )),
    ),
    Turf(
      id: '3',
      name: 'Urban Sports Park - Chembur',
      location: 'Urban Sports Park, Sree Narayan Guru College , Lokhandemarg, Chembur (West), Mumbai - 400 089',
      imageUrl: 'turf3.jpg',
      size: '2mtrsx25.5mtrs',
      prize: 1000,
      additionalDetail: '', 
      timeSlots: List.generate(5, (index) => TurfSlot(
        startTime: DateTime.now().add(Duration(hours: 3 * index)),
        endTime: DateTime.now().add(Duration(hours: 3 * (index + 1))),
        isAvailable: true,
        isBooked: '',
      )),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        elevation: 0,
        title: const Text('Turf'),
      ),
      drawer: Drawer(
        child: ListView(
          
          children: [
            const DrawerHeader(
              child: Center(
                child: Text(
                  'L O G O',
                  style: TextStyle(fontSize: 35),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: const ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
              ),
            ),
             GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/booking');
              },
               child: const ListTile(
                leading: Icon(Icons.book_online),
                title: Text("Booking"),
               
                           ),
             ),
           GestureDetector(
        onTap: () async {
          try {
      _auth.signOut();
      // Perform any additional cleanup or navigation after sign-out
          } catch (e) {
      // Handle any sign-out errors
      print('Error signing out: $e');
          }
        },
        child: ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
        ),
      )
      
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // CarouselSlider widget for displaying turf images
          CarouselSlider(
            options: CarouselOptions(
              height: 250.0,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              autoPlay: true,
            ),
            items: turfs.map((turf) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // Add decoration properties if needed
                    ),
                    child: Image.asset(
                      'assets/${turf.imageUrl}',
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20), // Add spacing between carousel and cards
          // Expanded ListView for displaying turf cards
          Expanded(
            child: ListView.builder(
              itemCount: turfs.length,
              itemBuilder: (context, index) {
                final turf = turfs[index];
                List<String> carouselImages = [];
                if (turf.id == '1') {
                  carouselImages = [
                    'turf1.jpg',
                    'turf1A.jpg',
                    'turf1B.jpg',
                    'turf1c.jpg',
                  ];
                } else if (turf.id == '2') {
                  carouselImages = [
                    'turf2.jpg',
                    'turf2A.jpg',
                    'Turf2B.jpg',
                    'Turf2c.jpg',
                  ];
                } else if (turf.id == '3') {
                  carouselImages = [
                    'turf3.jpg',
                    'turf3A.jpg',
                    'turf3B.jpg',
                    'turf3c.jpg',
                  ];
                }

                return GestureDetector(
  onTap: () {
    // Navigate to Turf detail page when tapped
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TurfPage.TurfDetailPage(
      turf: turf,
      carouselImages: carouselImages,
    ),
  ),
);
  },
  child: CardWidget(turf: turf),
);

              },
            ),
          ),
        ],
      ),
    );
  }
}

