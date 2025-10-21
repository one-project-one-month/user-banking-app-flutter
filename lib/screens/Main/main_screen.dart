import 'package:banking_app/core/utils/main_screen/ads_container.dart';
import 'package:banking_app/core/utils/main_screen/icon_button.dart';
import 'package:banking_app/core/utils/main_screen/transaction_card.dart';
import 'package:banking_app/screens/Transactions/transactions_history.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isVisible = false;
  List<Widget> adList = [
    AdsContainer(backgroundImage: 'assets/ad_img.png'),
    AdsContainer(backgroundImage: 'assets/ad_img.png'),
    AdsContainer(backgroundImage: 'assets/ad_img.png'),
  ];
  final carouselController = CarouselSliderController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const Icon(Icons.account_circle, size: 45, color: Colors.white),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Good Morning',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
                Text(
                  'User',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Row(
            children: const [
              Icon(Icons.notifications_active, size: 30, color: Colors.white),
              SizedBox(width: 15),
              Icon(Icons.settings, size: 30, color: Colors.white),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff0A3D62),
              Color(0xff1888D9),
              Color(0xff1888D9),
              Color(0xff0A3D62),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // 4. Add space to push your content down below the AppBar.
            SizedBox(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
            ),
            Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.15,
                vertical: MediaQuery.of(context).size.width * 0.1,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 15.0,
                ),
                child: Column(
                  children: [
                    Text(
                      "E-Wallet Balance (MMK)",
                      style: TextStyle(
                        fontFamily: 'DMsansSB',
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff072B46),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isVisible ? "5,000,000 MMK" : "xx,xxx MMK",
                          style: TextStyle(
                            fontFamily: 'DMsansSB',
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff072B46),
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
                            color: Color(0xff072B46),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MainScreenIcon(
                              onPressed: () {},
                              icon: Icons.sync_alt,
                              title: 'Transfer',
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.1,
                            ),
                            MainScreenIcon(
                              onPressed: () {},
                              icon: Icons.center_focus_strong_outlined,
                              title: 'Scan',
                            ),
                          ],
                        ),
                        SizedBox(height: 30),

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
                        SizedBox(height: 10),
                        SmoothPageIndicator(
                          controller: PageController(
                            viewportFraction: 0.3,
                            initialPage: currentIndex,
                          ), // PageController
                          count: 3,
                          effect: WormEffect(
                            dotHeight: 10,
                            dotWidth: 10,
                            activeDotColor: Color(0xff0A3D62),
                            dotColor: Colors.grey.shade300,
                          ), // your preferred effect
                          onDotClicked: (index) {},
                        ),
                        SizedBox(height: 15),
                        Container(
                          color: Color(0xff0A3D62),
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '  Recent History',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'DMsansSB',
                                  color: Colors.white,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const TransactionsHistory(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'See All ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'DMsansSB',
                                        color: Colors.white,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TransactionCard(
                          name: 'Aung Phyo',
                          time: '20:22:21',
                          amount: '45000',
                          income: true,
                          walltetNumber: '123456789',
                          quickPay: false,
                        ),

                        TransactionCard(
                          name: 'Aung Phyo',
                          time: '20:22:21',
                          amount: '45000',
                          income: true,
                          walltetNumber: '123456789',
                          quickPay: false,
                        ),

                        TransactionCard(
                          name: 'Aung Phyo',
                          time: '20:22:21',
                          amount: '45000',
                          income: false,
                          walltetNumber: '123456789',
                          quickPay: false,
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
  }
}
