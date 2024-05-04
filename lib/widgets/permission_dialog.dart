import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'primary_button.dart';

class PermissionDialog extends StatefulWidget {
  final String? title;
  const PermissionDialog({super.key, this.title});

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.0.h,
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 20.0,
        left: 20.0,
        right: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0.r),
          topRight: Radius.circular(30.0.r),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15.0.h),
            SvgPicture.asset("assets/icons/info.svg"),
            SizedBox(height: 6.0.h),
            Text(
              widget.title == 'Camera'
                  ? "Please allow access to your camera in order to take your picture"
                  : "Please allow access to your gallery in order to upload your document",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 50.0.h),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                buttonText: "Okay",
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            SizedBox(height: 50.0.h),
          ],
        ),
      ),
    );
  }
}
