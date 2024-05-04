// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:budrate/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../widgets/more_items_widgets.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  // Stream of the user
  final _user = Supabase.instance.client
      .from('users')
      .stream(primaryKey: ['id']).eq(
          'user_id', Supabase.instance.client.auth.currentUser!.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  // Build the body of the account tab
  Widget _buildBody() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Center(
              child: Text(
                "Account",
                style: TextStyle(
                  fontSize: 24.0.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(height: 10.0.h),
            CachedNetworkImage(
              imageUrl: 'https://picsum.photos/200',
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 60.r,
                backgroundImage: imageProvider,
                backgroundColor: Colors.transparent,
              ),
              placeholder: (context, url) => CircleAvatar(
                radius: 60.r,
                child: const Icon(
                  CupertinoIcons.profile_circled,
                  size: 130,
                ),
              ),
              errorWidget: (context, url, error) => CircleAvatar(
                radius: 60.r,
                child: const Icon(
                  CupertinoIcons.profile_circled,
                  size: 130,
                ),
              ),
            ),
            StreamBuilder(
              stream: _user,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                final user = snapshot.data!.first;
                return Center(
                  child: Text(
                    "${user['first_name']} ${user['last_name']}",
                    style: TextStyle(
                      fontSize: 24.0.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.0.h),
            Text(
              "ACCOUNT SETTINGS",
              style: TextStyle(
                fontSize: 24.0.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 20.0.h),
            MoreItemsWidget(
              leadingIcon: SvgPicture.asset("assets/icons/profile.svg"),
              text: "Profile Information",
              suffix: const Icon(Icons.navigate_next, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.profile);
              },
            ),
            SizedBox(height: 3.0.h),
            MoreItemsWidget(
              leadingIcon: SvgPicture.asset("assets/icons/converter.svg"),
              text: "Currency",
              suffix: Row(
                children: [
                  StreamBuilder(
                    stream: Supabase.instance.client
                        .from('users')
                        .stream(primaryKey: ['id']).eq('user_id',
                            Supabase.instance.client.auth.currentUser!.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      }
                      final currency = snapshot.data!.first['base_currency'];

                      return Text(
                        currency,
                        style: TextStyle(
                          fontSize: 12.0.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      );
                    },
                  ),
                  // const Icon(Icons.navigate_next, color: Colors.white)
                ],
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.changeCurrency);
              },
            ),
            SizedBox(height: 3.0.h),
            MoreItemsWidget(
              leadingIcon: SvgPicture.asset("assets/icons/delete.svg"),
              text: "Delete Account",
              suffix: const SizedBox(),
              onPressed: () async {
                await Supabase.instance.client
                    .from('users')
                    .delete()
                    .eq('id', Supabase.instance.client.auth.currentUser!.id);
                Supabase.instance.client.auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.signIn, (route) => false);
              },
            ),
            SizedBox(height: 3.0.h),
            MoreItemsWidget(
              leadingIcon: SvgPicture.asset("assets/icons/signout.svg"),
              text: "Sign Out",
              suffix: const SizedBox(),
              onPressed: () {
                Supabase.instance.client.auth.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.signIn, (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
