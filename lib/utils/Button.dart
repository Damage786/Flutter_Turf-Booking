import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String button;
  final Function()? onTap;
  final bool isLoading;

  const Button({
    Key? key,
    required this.button,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFF0F4C75),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Text(
                    button,
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
