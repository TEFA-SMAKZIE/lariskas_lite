import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kas_mini_lite/utils/colors.dart';
import 'package:kas_mini_lite/utils/modal_animation.dart';

class CreateCategoryModal {
  static void showCustomModal({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String title,
    required String hintText,
    required String buttonText,
    
    required Future<void> Function(String) onSave,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Set focus to the TextField when dialog is shown
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
        });

        return ModalAnimation(
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    hintText: hintText,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const Gap(5),
                ElevatedButton(
                  onPressed: () async {
                    final text = controller.text;
                    if (text.isNotEmpty) {
                      await onSave(text); // Callback function to save the data
                      Navigator.pop(context); // Close the modal
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Input Tidak Boleh Kosong")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      buttonText,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
