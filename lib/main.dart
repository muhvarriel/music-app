import 'package:music_app/ui/chat_home_screen.dart';
import 'package:music_app/ui/widgets/button_widget.dart';
import 'package:music_app/ui/widgets/custom_text.dart';
import 'package:music_app/utils/app_navigators.dart';
import 'package:music_app/utils/constants.dart';
import 'package:music_app/utils/music_storage.dart';
import 'package:music_app/utils/shared_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ChatAI Messenger',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initSplash();
  }

  void initSplash() async {
    await MusicStorage.loadStorage();

    if (await getSharedBool("initial") ?? false) {
      pageOpenAndRemovePrevious(const DifferentOfWebScreen());
    } else {
      setState(() {
        isLoading = false;
      });

      await setSharedBool("initial", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;

    return screenWidth > 600
        ? Container(
            padding: screenWidth > 600
                ? EdgeInsets.symmetric(
                    horizontal: screenWidth / ((screenWidth > 1028) ? 3 : 4),
                    vertical: 30)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
                color: isLoading
                    ? const Color(0xFFF0F9FD)
                    : Theme.of(context).cardColor),
            child: ClipRRect(
                borderRadius: screenWidth > 600
                    ? BorderRadius.circular(20)
                    : BorderRadius.zero,
                child: _buildSplash()))
        : _buildSplash();
  }

  Widget _buildSplash() {
    return isLoading
        ? Container(
            decoration: const BoxDecoration(
                color: Color(0xFFF0F9FD),
                image: DecorationImage(
                    image: AssetImage("assets/icons/logo.png"),
                    fit: BoxFit.fitWidth)),
          )
        : Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.viewPaddingOf(context).top + 16,
                16,
                MediaQuery.viewPaddingOf(context).bottom + 16),
            child: Column(
              children: [
                Expanded(child: Container()),
                const SizedBox(height: 20),
                _buildCopywriting(),
              ],
            ),
          );
  }

  Widget _buildCopywriting() {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "Chat with Your Personal AI Assistant",
          fontSize: 33,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : Colors.grey.shade900,
        ),
        const SizedBox(height: 12),
        CustomText(
          text:
              "Your personal AI assistant, designed to help you streamline tasks and enhance productivity.",
          fontWeight: FontWeight.normal,
          color: isDark ? Colors.white : Colors.grey.shade900,
        ),
        const SizedBox(height: 32),
        ButtonWidget(
            label: "Get Started",
            textColor: isDark ? Colors.white : Colors.grey.shade900,
            borderColor: isDark ? Colors.white : Colors.grey.shade900,
            backgroundColor: isDark ? Colors.black12 : Colors.white,
            onPressed: () {
              HapticFeedback.lightImpact();

              pageOpenAndRemovePrevious(const DifferentOfWebScreen());
            }),
      ],
    );
  }
}

class DifferentOfWebScreen extends StatefulWidget {
  const DifferentOfWebScreen({super.key});

  @override
  State<DifferentOfWebScreen> createState() => _DifferentOfWebScreenState();
}

class _DifferentOfWebScreenState extends State<DifferentOfWebScreen> {
  String? id;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;

    return screenWidth > 600
        ? Material(
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: SizedBox(
                      width: screenWidth / ((screenWidth > 1028) ? 3 : 2.5),
                      child: ChatHomeScreen(
                        onWeb: (value) {
                          setState(() {
                            id = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                      child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: const Center(
                      child: CustomText(
                        text: "Start a message",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          )
        : const MainPage();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Widget> _fragmentList = [
    const ChatHomeScreen(),
    Container(
      color: Colors.white,
      child: const Center(
        child: CustomText(text: "Profile Page"),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: _fragmentList.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 7,
              offset: const Offset(0, -7),
            ),
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          items: _itemBottomMenu(),
          currentIndex: _tabController.index,
          onTap: _onMenuBottomTapped,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      */
      body: DefaultTabController(
        length: _fragmentList.length,
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: _fragmentList,
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _itemBottomMenu() {
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home_rounded),
        label: "".tr,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline_rounded),
        activeIcon: const Icon(Icons.person_rounded),
        label: "".tr,
      ),
    ];
  }

  void _onMenuBottomTapped(int index) {
    HapticFeedback.lightImpact();
    if (_tabController.index != index) {
      setState(() {
        _tabController.index = index;
      });
    }
  }
}
