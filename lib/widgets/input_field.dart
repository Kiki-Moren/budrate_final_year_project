import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final String? Function(String?) validator;
  final void Function(String?)? onChanged;
  final void Function()? onTap;
  final TextInputType textInputType;
  final bool notEditable;
  final AutovalidateMode? autoValidate;
  final FocusNode? focusNode;
  final int? maxLength;
  final List<TextInputFormatter>? formatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const InputField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.validator,
    this.notEditable = false,
    this.autoValidate = AutovalidateMode.disabled,
    this.textInputType = TextInputType.text,
    this.focusNode,
    this.prefixIcon,
    this.maxLength,
    this.onChanged,
    this.formatters,
    this.onTap,
    this.suffixIcon,
    required this.label,
  }) : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
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
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: TextFormField(
            focusNode: widget.focusNode,
            controller: widget.controller,
            autocorrect: false,
            autovalidateMode: widget.autoValidate,
            validator: widget.validator,
            onChanged: widget.onChanged,
            keyboardType: widget.textInputType,
            maxLength: widget.maxLength,
            readOnly: widget.notEditable,
            inputFormatters: widget.formatters,
            textInputAction: TextInputAction.done,
            onTap: widget.onTap,
            decoration: InputDecoration(
              counterText: "",
              prefix: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0.w,
                  color: Colors.grey,
                ),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0.w,
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0.w,
                  color: Colors.red,
                ),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0.w,
                  color: Colors.red,
                ),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
              disabledBorder: InputBorder.none,
              errorMaxLines: 3,
              contentPadding: EdgeInsets.fromLTRB(
                12.0.w,
                15.0.h,
                12.0.w,
                15.0.h,
              ),
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
            style: TextStyle(
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
