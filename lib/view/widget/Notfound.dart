import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class NotFoundPage extends StatelessWidget {
  final String? title;
  final double? fontSize;
  final double? iconSize;
  const NotFoundPage({super.key, this.title, this.fontSize, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Column(
    mainAxisAlignment: MainAxisAlignment.center, 
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(Icons.search_off, size: iconSize ?? 35.sp),
      Gap(10),
      Text(title ?? 'Data Tidak Ditemukan',
          style: GoogleFonts.poppins(
            fontSize: fontSize ?? 16.sp,
          ), textAlign: TextAlign.center,),
          
    ]);
  }
}
