import 'package:flutter/material.dart';
import 'package:kas_mini_flutter_app/utils/colors.dart';
import 'package:kas_mini_flutter_app/utils/responsif/fsize.dart';

class ExpensiveFloatingButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final double? bottom;
  final double? left;
  final double? right;
  final Widget? child;
  final bool? isPositioned;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ExpensiveFloatingButton({
    super.key,
    required this.onPressed,
    this.isPositioned,
    this.text,
    this.bottom,
    this.left,
    this.right,
    this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return (isPositioned ?? false)
        ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 150.0, end: 0.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: margin,
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: LinearGradient(
                        colors: const [primaryColor, secondaryColor],
                        begin: Alignment(0, 2),
                        end: Alignment(-0, -2)),
                  ),
                  child: TextButton(
                    onPressed: onPressed,
                    child: child ??
                        Text(
                          text ?? "SIMPAN",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize:
                                  SizeHelper.Fsize_expensiveFloatingButton(
                                      context)),
                        ),
                  ),
                )
              ],
            ),
          )
        : Positioned(
            bottom: bottom ?? 15,
            left: left ?? 0,
            right: right ?? 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 150.0, end: 0.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: margin,
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        // color: primaryColor
                        gradient: LinearGradient(
                            colors: const [primaryColor, secondaryColor],
                            begin: Alignment(0, 2),
                            end: Alignment(-0, -2)),
                      ),
                      child: TextButton(
                        onPressed: onPressed,
                        child: child ??
                            Text(
                              text ?? "SIMPAN",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize:
                                      SizeHelper.Fsize_expensiveFloatingButton(
                                          context)),
                            ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
