import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Centered success dialog (e.g. after a ticket purchase). Stays on screen,
/// clearly visible, until the user taps OK.
void showSuccessDialog(String message) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 56),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E2B76),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

/// A small white spinner sized to sit inside a button in place of its label,
/// used to show an action is in progress (and the button is disabled).
Widget buttonSpinner() => const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
