import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final String? message;
  const Loader({
    super.key,
    this.message = 'Cargando',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E424B).withOpacity(0.4),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 230,
            height: 80,
            child: Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: Row(
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.black,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '$message...',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
