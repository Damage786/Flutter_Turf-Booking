import 'package:flutter/material.dart';

class Method extends StatelessWidget {
  final image;
  const Method({super.key,required this.image});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            // height: 100, // Set a fixed height for the container
            width: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10)
              
            ),
            
            
            child: Image.asset(image,
             fit: BoxFit.cover,)
            
            ),
         
          
        ],
      ),
    );
  }
}