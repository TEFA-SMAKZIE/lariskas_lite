import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kas_mini_lite/model/stock_addition.dart';
import 'package:kas_mini_lite/utils/colors.dart';

class StockAdditionCard extends StatefulWidget {
  const StockAdditionCard({
    super.key,
    required this.stock,
  });

  final StockAdditionData stock;

  @override
  State<StockAdditionCard> createState() => _StockAdditionCardState();
}

class _StockAdditionCardState extends State<StockAdditionCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Nama Produk & Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.stock.stockAdditionName,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.stock.stockAdditionDate,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(4),
          Divider(
            color: primaryColor,
            thickness: 1,
          ),
          const Gap(4),
          Text(
            "+${widget.stock.stockAdditionAmount}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          if (widget.stock.stockAdditionNote.isNotEmpty)
            Text(
              "Catatan : ${widget.stock.stockAdditionNote}",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
