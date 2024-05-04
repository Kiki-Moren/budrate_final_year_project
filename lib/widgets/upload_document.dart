// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:budrate/utilities/methods.dart';
import 'package:budrate/widgets/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadDocumentWidget extends StatefulWidget {
  final File? image;
  final Function({required File file}) onTap;
  final String? error;
  final String hint;

  const UploadDocumentWidget({
    super.key,
    this.image,
    required this.onTap,
    required this.hint,
    this.error,
  });

  @override
  State<UploadDocumentWidget> createState() => _UploadDocumentWidgetState();
}

class _UploadDocumentWidgetState extends State<UploadDocumentWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<PermissionStatus> getStatus() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        return await Permission.storage.status;
      } else {
        return await Permission.photos.status;
      }
    } else {
      return await Permission.photos.status;
    }
  }

  Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        await Permission.storage.request();
      } else {
        await Permission.photos.request();
      }
    } else {
      await Permission.photos.request();
    }
  }

  void _selectImage() async {
    // await requestPermission();

    if (await getStatus().isDenied) {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return const PermissionDialog();
        },
      );
      await requestPermission();
      return;
    } else if (await getStatus().isPermanentlyDenied) {
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return const PermissionDialog();
        },
      );
      await requestPermission();
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (photo != null) {
        File file = await AppMethods.compressFilePNG(File(photo.path));
        widget.onTap(file: file);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _selectImage,
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            color: const Color(0xff165a4a),
            dashPattern: const [8],
            child: Container(
              width: double.infinity,
              height: 120.0.h,
              padding: const EdgeInsets.all(0),
              child: widget.image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/upload.svg',
                          // ignore: deprecated_member_use
                          color: Colors.green,
                        ),
                        SizedBox(height: 8.0.h),
                        Text(
                          widget.hint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.0.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      margin: const EdgeInsets.all(10.0),
                      height: 200.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.image!.path.fileName(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 10.0.h),
                          Text(
                            'Replace',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        if (widget.error != null)
          Text(
            widget.error!,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.red,
                ),
          ),
      ],
    );
  }
}

extension E on String {
  String fileName() {
    List<String> parts = split('/');

    if (parts.isNotEmpty) {
      String desiredSubstring = parts[parts.length - 1];
      return desiredSubstring;
    }

    return '';
  }
}
