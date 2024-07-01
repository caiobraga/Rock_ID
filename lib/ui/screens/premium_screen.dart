import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/ui/widgets/text.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool isFreeTrialEnabled = true;
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = true;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    _initialize();
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    purchaseUpdated.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    });
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 50),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            image: DecorationImage(
              image: AssetImage('assets/images/premium_background.png'),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          child: Image.asset('assets/videos/background.gif'),
        ),
        Positioned(
          bottom: 145,
          left: MediaQuery.of(context).size.width / 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DSCustomText(
                text: 'Enable free trial',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 24,
                child: Switch(
                  activeColor: AppColors.naturalBlack,
                  activeTrackColor: AppColors.primaryMedium,
                  inactiveThumbColor: AppColors.white,
                  inactiveTrackColor: Colors.transparent,
                  value: isFreeTrialEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      isFreeTrialEnabled = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          left: MediaQuery.of(context).size.width / 5,
          child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    // Terms of Use action
                  },
                  child: const DSCustomText(
                    text: 'Terms of Use',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.naturalSilver,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.naturalSilver,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '|',
                  style: TextStyle(
                    color: AppColors.naturalSilver,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    // Privacy Policy action
                  },
                  child: const DSCustomText(
                    text: 'Privacy Policy',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.naturalSilver,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.naturalSilver,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget isFreeTrialEnabledWidget() {
    return const SizedBox(
      height: 188,
      child: Column(
        children: [
          FeatureItem(
            title: 'No Payment',
            imagePath: 'ad-freeExperience.png',
            subTitle: 'now',
          ),
          DSCustomText(
            text: "TRY 3 DAYS FOR FREE, THEN \$4.99 PER WEEK",
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryMedium,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          DSCustomText(
            text: 'Auto-renewable. Cancel anytime.',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }

  Widget freeTrialNotEnabledWidget() {
    return const SizedBox(
      height: 188,
      child: Column(
        children: [
          DSCustomText(
            text: 'JUST \$24.99 PER YEAR',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryMedium,
          ),
          SizedBox(height: 4),
          DSCustomText(
            text: 'Auto-renewable. Cancel anytime.',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.white,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subTitle;
  const FeatureItem(
      {Key? key,
      required this.imagePath,
      required this.title,
      required this.subTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFB88F71),
              Color(0xFFA16132),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        height: 64,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 42,
                width: 42,
                child: Image(
                  image: AssetImage('assets/images/$imagePath'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSCustomText(
                      text: title,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.naturalBlack,
                    ),
                    DSCustomText(
                      text: subTitle,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.naturalBlack,
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
}
