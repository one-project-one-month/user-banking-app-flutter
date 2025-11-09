import 'package:banking_app/Routes/app_routes.dart';
import 'package:banking_app/core/utils/main_screen/ads_container.dart';
import 'package:banking_app/core/utils/main_screen/icon_button.dart';
import 'package:banking_app/core/utils/main_screen/transaction_card.dart';
import 'package:banking_app/screens/Transactions/transactions_history.dart';
import 'package:banking_app/screens/Transactions/controllers/transaction_bloc.dart';
import 'package:banking_app/screens/Transactions/controllers/transaction_event.dart';
import 'package:banking_app/screens/Transactions/controllers/transaction_state.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:banking_app/screens/Main/controllers/user_bloc.dart';
import 'package:banking_app/screens/Main/controllers/user_event.dart';
import 'package:banking_app/screens/Main/controllers/user_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isVisible = false;
  List<Widget> adList = [
    AdsContainer(backgroundImage: 'assets/ad_img.png'),
    AdsContainer(backgroundImage: 'assets/ad_img.png'),
    AdsContainer(backgroundImage: 'assets/ad_img.png'),
  ];
  final carouselController = CarouselSliderController();
  int currentIndex = 0;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void initState() {
    super.initState();
    // Dispatch once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserBloc>().add(const UserLoadData());
        context.read<TransactionBloc>().add(const TransactionLoadData());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildHomeContent();
  }

  Widget _buildHomeContent() {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            final username = state.user?.username ?? 'User';
            return Row(
              children: [
                Icon(Icons.account_circle, size: 45, color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getGreeting(), style: theme.textTheme.bodySmall?.copyWith(color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary)),
                    Text(username, style: theme.textTheme.bodySmall?.copyWith(color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary)),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          Row(
            children: [
              Icon(Icons.notifications_active, size: 30, color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary),
              const SizedBox(width: 15),
              IconButton(
                icon: const Icon(Icons.settings, size: 30, color: Colors.white),
                onPressed: () {
                  AppRoutes.navigateTo(context, AppRoutes.settings);
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state.hasError) {
            if (state.errorMessage?.contains('login') ?? false) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Session expired'), backgroundColor: Colors.red),
              );
              Future.delayed(const Duration(seconds: 1), () {
                AppRoutes.navigateAndRemoveUntil(context, AppRoutes.login);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'An error occurred'), backgroundColor: Colors.orange),
              );
            }
          }
        },
        builder: (context, userState) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<UserBloc>().add(const UserRefreshData());
              context.read<TransactionBloc>().add(const TransactionRefreshData());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary,theme.colorScheme.tertiary,theme.colorScheme.onTertiary,theme.colorScheme.onPrimary,],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: kMinInteractiveDimension - 14 + MediaQuery.of(context).padding.top),

                  // Balance Card
                  Card(
                    color: theme.cardTheme.color ?? theme.colorScheme.surface,
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.15,
                      vertical: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
                      child: Column(
                        children: [
                          Text(
                            "E-Wallet Balance (MMK)",
                            style: theme.textTheme.titleLarge?.copyWith(fontFamily: 'DMsansSB'),
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (userState.isLoading || userState.isRefreshing)
                                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              else
                                Text(
                                  
                                  isVisible ? "${userState.user?.formattedBalance ?? '0'} MMK" : "xx,xxx MMK",
                                  style: TextStyle(
                                    fontFamily: 'DMsansSB',
                                    fontSize: MediaQuery.of(context).size.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff072B46),
                                  ),
                                  
                                ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isVisible = !isVisible;
                                  });
                                },
                                icon: Icon(
                                  isVisible ? Icons.visibility_off : Icons.visibility,
                                  size: 24,
                                  color: theme.iconTheme.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
 SizedBox(height: 40),

                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MainScreenIcon(
                                    onPressed: () {
                                      AppRoutes.navigateTo(context, AppRoutes.transfer);
                                    },
                                    icon: Icons.sync_alt,
                                    title: 'Transfer',
                                  ),
                                  SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                                  MainScreenIcon(
                                    onPressed: () {
                                      AppRoutes.navigateTo(context, AppRoutes.qr);
                                    },
                                    icon: Icons.center_focus_strong_outlined,
                                    title: 'Scan',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: CarouselSlider(
                                  carouselController: carouselController,
                                  items: adList,
                                  options: CarouselOptions(
                                    autoPlay: true,
                                    viewportFraction: 1,
                                    height: MediaQuery.of(context).size.height * 0.14,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        currentIndex = index;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SmoothPageIndicator(
                                controller: PageController(viewportFraction: 0.3, initialPage: currentIndex),
                                count: 3,
                                effect: WormEffect(
                                  dotHeight: 10,
                                  dotWidth: 10,
                                  activeDotColor: theme.colorScheme.primary,
                                  dotColor: Colors.grey.shade300,
                                ),
                                onDotClicked: (index) {},
                              ),
                              const SizedBox(height: 15),
                              Container(
                                color: theme.colorScheme.primary,
                                height: 40,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '  Recent History',
                                      style: TextStyle(fontSize: 16, fontFamily: 'DMsansSB', color: Colors.white),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const TransactionsHistory()),
                                        );
                                      },
                                      child: const Row(
                                        children: [
                                          Text(
                                            'See All ',
                                            style: TextStyle(fontSize: 16, fontFamily: 'DMsansSB', color: Colors.white),
                                          ),
                                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                                          SizedBox(width: 10),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Recent Transactions from API
                              BlocBuilder<TransactionBloc, TransactionState>(
                                builder: (context, transactionState) {
                                  if (transactionState.isLoading) {
                                    return const Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  if (transactionState.hasError) {
                                    return Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        transactionState.errorMessage ?? 'Failed to load transactions',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    );
                                  }

                                  if (!transactionState.hasData) {
                                    return const Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: Text('No recent transactions'),
                                    );
                                  }

                                  // Show only the 3 most recent transactions
                                  final recentTransactions = transactionState.recentTransactions;

                                  return Column(
                                    children:
                                        recentTransactions.map((transaction) {
                                          return TransactionCard(
                                            name: transaction.user.name,
                                            time: transaction.time ?? '',
                                            amount: transaction.account.balance.toStringAsFixed(0),
                                            income: transaction.isIncome,
                                            walltetNumber: transaction.account.accountNumber,
                                            quickPay: transaction.quickPay,
                                          );
                                        }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
