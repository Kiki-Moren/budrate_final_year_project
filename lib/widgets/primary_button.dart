import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PrimaryButton extends StatelessWidget {
  final Function() onPressed;
  final String buttonText;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading || isDisabled ? () {} : onPressed,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0.r),
          color: isDisabled
              ? const Color(0xff165a4a).withOpacity(0.5)
              : isLoading
                  ? const Color(0xff165a4a).withOpacity(0.6)
                  : const Color(0xff165a4a),
        ),
        child: isLoading
            ? Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: Colors.white,
                  size: 18.0.w,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) icon!,
                  if (icon != null) SizedBox(width: 10.0.w),
                  Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16.0.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
