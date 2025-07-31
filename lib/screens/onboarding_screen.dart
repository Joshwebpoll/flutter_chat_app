import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:music_player_app/models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int activeIndex = 0;
  late PageController control;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    control = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    control.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  onPageChanged: (index) {
                    setState(() {
                      activeIndex = index;
                    });
                  },
                  controller: control,
                  itemCount: onboardingContent.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Image.asset(
                          onboardingContent[index].image,
                          fit: BoxFit.contain,
                          height: 300,
                          width: 300,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          onboardingContent[index].name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          onboardingContent[index].description,
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        const Row(children: []),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(onboardingContent.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 10,
                      width: activeIndex == index ? 15 : 10,
                      decoration: BoxDecoration(
                        color:
                            activeIndex == index
                                ? const Color(0xFFff660b)
                                : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(),
                    onPressed: () async {
                      final storage = FlutterSecureStorage();
                      await storage.write(
                        key: 'hasSeenOnboarding',
                        value: 'true',
                      );

                      if (!context.mounted) return;
                      Navigator.pushNamed(context, '/');

                      control.nextPage(
                        duration: Duration(microseconds: 500),
                        curve: Curves.bounceIn,
                      );
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (activeIndex == onboardingContent.length - 1) {
                        final storage = FlutterSecureStorage();
                        await storage.write(
                          key: 'hasSeenOnboarding',
                          value: 'true',
                        );
                        if (!context.mounted) return;
                        Navigator.pushNamed(context, '/');
                      }
                      control.nextPage(
                        duration: Duration(microseconds: 500),
                        curve: Curves.bounceIn,
                      );
                    },
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Container buildDot(BuildContext context, index) {
  //   return Container(
  //     height: 10,
  //     width: index,
  //   );
  // }
}
