import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';

Widget loadingCurrentLocation() {
  return Container(
    height: 120,
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoActivityIndicator(color: kPrimary),
        SizedBox(height: 8),
        Text("detect_your_location".tr(), style: TextStyle(fontSize: 14)),
      ],
    ),
  );
}
