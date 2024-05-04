import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoreItemsWidget extends ConsumerStatefulWidget {
  final Function() onPressed;
  final String text;
  final Widget leadingIcon;
  final Widget? suffix;

  const MoreItemsWidget({
    super.key,
    required this.onPressed,
    required this.text,
    required this.leadingIcon,
    this.suffix,
  });

  @override
  ConsumerState<MoreItemsWidget> createState() => _MoreItemsWidgetState();
}

class _MoreItemsWidgetState extends ConsumerState<MoreItemsWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: const Color(0xff165A4A),
          borderRadius: BorderRadius.circular(8.0.r),
          border: Border.all(color: Colors.grey),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  widget.leadingIcon,
                  SizedBox(width: 10.0.w),
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.0.w),
              widget.suffix ?? const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
