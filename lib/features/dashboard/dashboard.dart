import 'package:budrate/features/dashboard/budgets/budgets.dart';
import 'package:budrate/features/dashboard/converter/converter.dart';
import 'package:budrate/services/app.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'account/account.dart';
import 'home/home.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    // Create wallet
    _createWallet();
    super.initState();
    // Load initial values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appApiProvider).getCurrencies(ref: ref, onError: (_) {});
    });
  }

  // Create wallet
  void _createWallet() async {
    // Get the user's savings
    final savings = await Supabase.instance.client
        .from('savings')
        .select()
        .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

    // Create the wallet if it doesn't exist
    if (savings.isEmpty) {
      await Supabase.instance.client.from('savings').upsert({
        'user_id': Supabase.instance.client.auth.currentUser!.id,
        'amount': 0,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  // Build the body of the screen
  Widget _buildBody() {
    return _selectedIndex == 0
        ? const HomeTab()
        : _selectedIndex == 1
            ? const BudgetTab()
            : _selectedIndex == 2
                ? const CurrencyConverterTab()
                : const AccountTab();
  }

  // Build the navigation bar
  Widget _buildNavBar() {
    return FlashyTabBar(
      selectedIndex: _selectedIndex,
      showElevation: true,
      onItemSelected: (index) => setState(() {
        _selectedIndex = index;
      }),
      items: [
        FlashyTabBarItem(
          icon: const Icon(CupertinoIcons.home),
          title: const Text('Home'),
        ),
        FlashyTabBarItem(
          icon: const Icon(CupertinoIcons.chart_bar_circle),
          title: const Text('Budgets'),
        ),
        FlashyTabBarItem(
          icon: const Icon(CupertinoIcons.money_dollar_circle),
          title: const Text('Convert'),
        ),
        FlashyTabBarItem(
          icon: const Icon(CupertinoIcons.profile_circled),
          title: const Text('Profile'),
        ),
      ],
    );
  }
}
