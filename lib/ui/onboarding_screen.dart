import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/ui/root_page.dart';
import 'package:flutter_onboarding/ui/screens/premium_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:page_transition/page_transition.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  List<ProductDetails> _products = [];
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = true;

  @override
  void initState() {
    _initialize();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    purchaseUpdated.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    });
    super.initState();
  }

  Future<void> _initialize() async {
    _available = await _iap.isAvailable();
    if (_available) {
      const Set<String> _kIds = {'product_id_1', 'product_id_2'};
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_kIds);
      setState(() {
        _products = response.productDetails;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.blackColor,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            onPageChanged: (int page) {
              setState(() {
                currentIndex = page;
              });
            },
            controller: _pageController,
            children: const [
              CreatePage(
                backgroundImage: 'assets/images/bg1.png',
                title: Constants.titleOne,
                description: Constants.descriptionOne,
              ),
              CreatePage(
                backgroundImage: 'assets/images/bg2.png',
                title: Constants.titleTwo,
                description: Constants.descriptionTwo,
              ),
              CreatePage(
                backgroundImage: 'assets/images/bg3.png',
                title: Constants.titleThree,
                description: Constants.descriptionThree,
              ),
              PremiumScreen(),
            ],
          ),
          Positioned(
            bottom: 60,
            child: GestureDetector(
              onTap: () {
                if (currentIndex < 3) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                } else {
                  if (_products.isNotEmpty) {
                    _buyProduct(_products.first);
                  }
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        child: const RootPage(),
                        type: PageTransitionType.bottomToTop),
                    (route) => false,
                  );
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  gradient: Constants.darkDegrade,
                ),
                child: const Text(
                  'Continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        // Handle pending status
      } else if (purchase.status == PurchaseStatus.error) {
        // Handle error status
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Handle purchased or restored status
        _verifyPurchase(purchase);
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    // Verifique a compra com o seu servidor ou serviço de backend
    // Após verificação, consuma ou reconheça a compra
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  void _buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }
}

class CreatePage extends StatelessWidget {
  final String backgroundImage;
  final String title;
  final String description;

  const CreatePage({
    Key? key,
    required this.backgroundImage,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 110),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.bebasNeue(
              color: Constants.primaryColor,
              fontSize: 32,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
