// ignore_for_file: public_member_api_docs, sort_constructors_first
class OnboardingModel {
  String name;
  String description;
  String image;
  OnboardingModel({
    required this.name,
    required this.description,
    required this.image,
  });
}

List<OnboardingModel> onboardingContent = [
  OnboardingModel(
    name: 'Welcome to ShopSmart',
    description:
        "Discover the latest fashion, electronics, home items, and more — all in one place. Enjoy a smarter way to shop.",
    image: "assets/images/onboard1.jpg",
  ),
  OnboardingModel(
    name: "Shop with Ease",
    description:
        "Add your favorite items to cart, save for later, and checkout in just a few taps. Fast, simple, and secure.",
    image: "assets/images/onboard2.jpg",
  ),
  OnboardingModel(
    name: "Ready to Shop Smarter?",
    description:
        "Stay updated with real-time delivery tracking, and get notified about your orders every step of the way.",
    image: "assets/images/onboard3.png",
  ),
];
