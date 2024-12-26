import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLottieDialog extends StatelessWidget {
  const CustomLottieDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/animations/maintanence_animation.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            "Halaman ini sedang dalam tahap pengembangan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              "OK",
              style: TextStyle(
                color: Color.fromARGB(255, 238, 185, 11)
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showCustomLottieDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => const CustomLottieDialog(),
  );
}
