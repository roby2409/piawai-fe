import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingModel {
  final String title;
  final String description;
  final String image;

  OnboardingModel({
    required this.title,
    required this.description,
    required this.image,
  });
}

final onboardingData = [
  OnboardingModel(
    title: 'onboarding.slide_1_title'.tr(),
    description: 'onboarding.slide_1_desc'.tr(),
    image: 'assets/images/onboarding_1.png',
  ),
  OnboardingModel(
    title: 'onboarding.slide_2_title'.tr(),
    description: 'onboarding.slide_2_desc'.tr(),
    image: 'assets/images/onboarding_2.png',
  ),
  OnboardingModel(
    title: 'onboarding.slide_3_title'.tr(),
    description: 'onboarding.slide_3_desc'.tr(),
    image: 'assets/images/onboarding_3.png',
  ),
];

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text('onboarding.skip'.tr()),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = onboardingData[index];

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Image.asset(item.image)),

                        const SizedBox(height: 32),

                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: currentIndex == index ? 28 : 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF04A5BA),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentIndex == onboardingData.length - 1) {
                      widget.onFinish();
                    } else {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    currentIndex == onboardingData.length - 1
                        ? 'onboarding.start'.tr()
                        : 'onboarding.next'.tr(),
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
