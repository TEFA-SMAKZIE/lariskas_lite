import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kas_mini_flutter_app/model/product.dart';
import 'package:kas_mini_flutter_app/services/database_service.dart';
import 'package:kas_mini_flutter_app/view/widget/Notfound.dart';
import 'package:sizer/sizer.dart';

class ProductTerbaruList extends StatefulWidget {
  const ProductTerbaruList({super.key});

  @override
  State<ProductTerbaruList> createState() => _ProductTerbaruListState();
}

class _ProductTerbaruListState extends State<ProductTerbaruList> {
  DatabaseService db = DatabaseService.instance;
  List<Product> data = [];

  @override
  void initState() {
    super.initState();
    getProduct();
  }

  void getProduct() async {
    List<Product> producte = await db.getProducts();
    setState(() {
      data = producte;
    });
  }

  @override
  Widget build(BuildContext context) {
    return data.isNotEmpty ? ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: data.length > 4 ? 4 : data.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            children: [
              Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: data[index].productImage ==
                                  'assets/products/no-image.png' ||
                              !File(data[index].productImage).existsSync()
                          ? Image.asset('assets/products/no-image.png')
                          : Image.file(File(data[index].productImage),
                              fit: BoxFit.cover))),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  print(data[index].productName);
                },
                child: Text(
                  data[index].productName,
                  style:
                      TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        );
      },
    ) : Center(
      child: NotFoundPage(
        fontSize: 12.sp,
        iconSize: 25.sp,
        title: "Produk masih kosong",
      ),
    );
  }
}
