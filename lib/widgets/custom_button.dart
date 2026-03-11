import 'package:flutter/material.dart';
import 'package:meetup/utils/colors.dart';
class CustomButton extends StatelessWidget {
  final String text;
  const CustomButton({super.key, required this.text, required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton(
        onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Colors.white, width: 2)
        )
      ),
        child: Text(
          text, 
          style:const TextStyle(
          fontSize: 28,
          color: Colors.white,
        ),
      ),
      ),
    );
  }
}