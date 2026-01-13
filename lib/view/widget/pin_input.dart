import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputWidget extends StatefulWidget {
  final List<TextEditingController> controllers;

  const PinInputWidget({super.key, required this.controllers});

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in widget.controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleBackspace(int index) {
    if (index > 0 && widget.controllers[index].text.isEmpty) {
      final prevIndex = index - 1;
      widget.controllers[prevIndex].clear();
      _focusNodes[prevIndex].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.first.canRequestFocus) {
        _focusNodes.first.requestFocus();
      }
    });

    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.controllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          final focusNode = _focusNodes[index];

          return SizedBox(
            width: 44,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: RawKeyboardListener(
                focusNode: focusNode,
                onKey: (RawKeyEvent event) {
                  if (event.isKeyPressed(LogicalKeyboardKey.backspace) &&
                      controller.text.isEmpty &&
                      index > 0) {
                    widget.controllers[index - 1].clear();
                    _focusNodes[index - 1].requestFocus();
                  }
                },
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty &&
                        index < widget.controllers.length - 1) {
                      Future.delayed(const Duration(milliseconds: 50), () {
                        _focusNodes[index + 1].requestFocus();
                      });
                    }
                  },
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
