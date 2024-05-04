import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class DropDownField extends StatefulWidget {
  final String hint;
  final String label;
  final String? selected;
  final List<String> data;
  final Widget? suffixIcon;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const DropDownField({
    Key? key,
    required this.hint,
    required this.label,
    required this.data,
    required this.selected,
    this.validator,
    this.onChanged,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<DropDownField> createState() => _DropDownFieldState();
}

class _DropDownFieldState extends State<DropDownField> {
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonHideUnderline(
          child: DropdownButtonFormField<String>(
            value: dropdownValue,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an option';
              }
              return null;
            },
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0.w,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8.0.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0.w,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8.0.r),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0.w,
                  color: Colors.red,
                ),
                borderRadius: BorderRadius.circular(8.0.r),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0.w,
                  color: Colors.red,
                ),
                borderRadius: BorderRadius.circular(8.0.r),
              ),
              disabledBorder: InputBorder.none,
              errorMaxLines: 3,
              contentPadding: EdgeInsets.fromLTRB(
                12.0.w,
                15.0.h,
                12.0.w,
                15.0.h,
              ),
            ),
            hint: Text(
              widget.hint,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            icon: Container(
              margin: const EdgeInsets.only(left: 10.0),
              child: SvgPicture.asset("assets/icons/arrow_down.svg"),
            ),
            iconSize: 24.0.w,
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue;
              });
              widget.onChanged!(newValue);
            },
            selectedItemBuilder: (BuildContext context) {
              return widget.data.map((String value) {
                return Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              }).toList();
            },
            items: widget.data.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
