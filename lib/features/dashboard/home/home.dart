import 'package:budrate/routes.dart';
import 'package:budrate/services/app.dart';
import 'package:budrate/state/data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  // User data
  Map<String, dynamic>? _userData;
  // Stream the user savings
  final _savings = Supabase.instance.client
      .from('savings')
      .stream(primaryKey: ['id']).eq(
          'user_id', Supabase.instance.client.auth.currentUser!.id);

  // Stream the user data
  final _user = Supabase.instance.client
      .from('users')
      .stream(primaryKey: ['id']).eq(
          'user_id', Supabase.instance.client.auth.currentUser!.id);

  // Stream the user activities
  final _activities = Supabase.instance.client
      .from('activities')
      .stream(primaryKey: ['id']).eq(
          'user_id', Supabase.instance.client.auth.currentUser!.id);

  @override
  void initState() {
    // Get the user data
    _getUser();
    super.initState();
  }

  void _getUser() async {
    // Get the user data
    _userData = await Supabase.instance.client
        .from('users')
        .select()
        .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
        .single();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  // Build the body of the home tab
  Widget _buildBody() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            StreamBuilder(
              stream: _user,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                final user = snapshot.data!.first;
                return Text(
                  "Hello ${user['first_name']},",
                  style: TextStyle(
                    fontSize: 24.0.sp,
                    fontWeight: FontWeight.w400,
                  ),
                );
              },
            ),
            SizedBox(height: 20.0.h),
            _buildTotalSavingsContainer(),
            SizedBox(height: 20.0.h),
            _buildCreateNewBudgetButton(),
            SizedBox(height: 20.0.h),
            _buildRecentActivities(),
            SizedBox(height: 20.0.h),
            _buildExchangeRate(),
            SizedBox(height: 20.0.h),
            _buildQuoteSection(),
          ],
        ),
      ),
    );
  }

  // Build Quote UI
  Widget _buildQuoteSection() {
    return FutureBuilder(
        future: ref.read(appApiProvider).getBusinessQuote(
              ref: ref,
              onError: (_) {},
            ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          }

          String quote = snapshot.data.toString();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Quote of the Day",
                style: TextStyle(
                  fontSize: 24.0.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                color: const Color(0xff165A4A),
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  quote,
                  style: TextStyle(
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        });
  }

  // Build the exchange rate UI
  Widget _buildExchangeRate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Exchange Rate (USD - ${_userData?['base_currency'] ?? "NGN"})",
          style: TextStyle(
            fontSize: 24.0.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        _buildChart(),
      ],
    );
  }

  // Build the exchange rate chart
  Widget _buildChart() {
    var exchangeRates = Data.exchangeRates
        .firstWhere((element) =>
            element["currency"] ==
            (_userData?['base_currency'] ?? "NGN"))["rates"]
        .map((e) => e["rate"])
        .toList();

    var spots = <FlSpot>[];

    for (int i = 0; i < exchangeRates.length; i++) {
      spots.add(FlSpot(i.toDouble(), exchangeRates[i].toDouble()));
    }

    return SizedBox(
      width: double.infinity,
      height: 200.h,
      child: LineChart(
        LineChartData(
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            border: const Border(
              left: BorderSide(
                color: Color(0xFF165A4A),
                width: 2,
              ),
              bottom: BorderSide(
                color: Color(0xFF165A4A),
                width: 2,
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          lineBarsData: [
            LineChartBarData(
              // spots: const [
              //   FlSpot(1, Data.exchangeRates),
              // ],
              spots: spots,
              isCurved: true,
              barWidth: 4,
              isStrokeCapRound: true,
              // belowBarData: BarAreaData(show: false),
              // dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  // Build the recent activities UI
  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Activies",
          style: TextStyle(
            fontSize: 24.0.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        StreamBuilder(
          stream: _activities,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            }

            final activities = snapshot.data as List;
            // get the last two records
            final shownActiviest = activities.reversed.toList().sublist(0, 2);

            return ListView.separated(
              itemBuilder: (ctx, idx) => _buildRecentItem(
                leadingIcon: SvgPicture.asset("assets/icons/budget.svg"),
                title: shownActiviest[idx]['title'],
                description: DateFormat('hh:mm a')
                    .format(DateTime.parse(shownActiviest[idx]['created_at'])),
                onPressed: () {},
              ),
              separatorBuilder: (ctx, idx) => SizedBox(height: 10.0.h),
              itemCount: shownActiviest.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            );
          },
        ),
      ],
    );
  }

  // Build the recent item
  Widget _buildRecentItem({
    required String title,
    required String description,
    required Function() onPressed,
    required Widget leadingIcon,
  }) {
    return GestureDetector(
      onTap: onPressed,
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
            children: [
              leadingIcon,
              SizedBox(width: 10.0.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the create new budget button
  Widget _buildCreateNewBudgetButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.addBudget);
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/create.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20.0.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create New Budget",
                    style: TextStyle(
                      fontSize: 24.0.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.0.h),
                  Text(
                    "Create a new budget to start saving",
                    style: TextStyle(
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20.0.w),
            SvgPicture.asset("assets/icons/money_bag.svg"),
          ],
        ),
      ),
    );
  }

  // Build the total savings container
  Widget _buildTotalSavingsContainer() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.topUpSaving),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/total_savings_bg.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20.0.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Savings",
              style: TextStyle(
                fontSize: 24.0.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.0.h),
            StreamBuilder(
              stream: _savings,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                final saving = snapshot.data!.first;
                return Text(
                  NumberFormat.currency(
                          locale: "en_US", symbol: saving['base_currency'])
                      .format(saving['amount']),
                  style: TextStyle(
                    fontSize: 34.0.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                );
              },
            ),
            SizedBox(height: 10.0.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.topUpSaving),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
