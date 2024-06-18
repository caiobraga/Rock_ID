import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:flutter_onboarding/ui/screens/favorite_page.dart';
import 'package:flutter_onboarding/ui/screens/home_page.dart';
import 'package:flutter_onboarding/ui/screens/premium_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/bottom_nav_service.dart';
import '../services/selection_modal.dart';
import 'screens/widgets/hexagon_floating_action_button.dart';

class RootPage extends StatefulWidget {
  final bool? showFavorites;

  const RootPage({
    Key? key,
    this.showFavorites,
  }) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Rock> favorites = [];
  List<Rock> myCart = [];
  final crownIcon =
      '''<svg width="80" height="80" viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg">
          <g filter="url(#filter0_d_2804_1009)">
          <rect x="12" y="6" width="56" height="56" rx="28" fill="#212528" shape-rendering="crispEdges"/>
          <g opacity="0.2">
          <path d="M29.2401 30.992C28.8061 29.208 30.8021 27.83 32.3161 28.87L35.9761 31.382C36.1992 31.5354 36.4512 31.6419 36.7167 31.695C36.9822 31.7482 37.2558 31.7468 37.5208 31.6911C37.7858 31.6354 38.0367 31.5264 38.2583 31.3708C38.4799 31.2153 38.6676 31.0163 38.8101 30.786L41.2981 26.754C41.4772 26.4637 41.7277 26.224 42.0256 26.0578C42.3235 25.8916 42.6589 25.8043 43.0001 25.8043C43.3412 25.8043 43.6767 25.8916 43.9746 26.0578C44.2725 26.224 44.5229 26.4637 44.7021 26.754L47.1901 30.786C47.3325 31.0163 47.5203 31.2153 47.7419 31.3708C47.9635 31.5264 48.2144 31.6354 48.4794 31.6911C48.7444 31.7468 49.0179 31.7482 49.2835 31.695C49.549 31.6419 49.8009 31.5354 50.0241 31.382L53.6841 28.87C55.1981 27.83 57.1941 29.208 56.7601 30.99L53.9601 42.474C53.854 42.909 53.6049 43.2959 53.2528 43.5726C52.9007 43.8493 52.4659 43.9998 52.0181 44H33.9801C33.5323 43.9998 33.0975 43.8493 32.7454 43.5726C32.3933 43.2959 32.1442 42.909 32.0381 42.474L29.2401 30.992Z" fill="#B88F71"/>
          <path fill-rule="evenodd" clip-rule="evenodd" d="M51.6501 35.064C50.3066 35.7591 48.7502 35.9211 47.2924 35.5176C45.8346 35.1141 44.583 34.1749 43.7881 32.888L43.0001 31.612L42.2121 32.888C41.4173 34.1744 40.166 35.1133 38.7086 35.5167C37.2513 35.9202 35.6953 35.7585 34.3521 35.064L35.5521 40H50.4461L51.6501 35.064ZM32.3161 28.87C30.8021 27.83 28.8061 29.208 29.2401 30.99L32.0401 42.474C32.1461 42.9087 32.3949 43.2953 32.7466 43.572C33.0983 43.8486 33.5326 43.9993 33.9801 44H52.0161C52.4639 43.9998 52.8987 43.8493 53.2508 43.5726C53.6029 43.2959 53.852 42.909 53.9581 42.474L56.7581 30.992C57.1921 29.208 55.1961 27.83 53.6821 28.87L50.0221 31.382C49.7989 31.5354 49.547 31.6419 49.2815 31.695C49.0159 31.7482 48.7424 31.7468 48.4774 31.6911C48.2124 31.6354 47.9615 31.5264 47.7399 31.3708C47.5182 31.2153 47.3305 31.0163 47.1881 30.786L44.7001 26.754C44.5209 26.4637 44.2705 26.224 43.9726 26.0578C43.6747 25.8916 43.3392 25.8043 42.9981 25.8043C42.6569 25.8043 42.3215 25.8916 42.0236 26.0578C41.7257 26.224 41.4752 26.4637 41.2961 26.754L38.8101 30.786C38.6676 31.0163 38.4799 31.2153 38.2583 31.3708C38.0367 31.5264 37.7858 31.6354 37.5208 31.6911C37.2558 31.7468 36.9822 31.7482 36.7167 31.695C36.4512 31.6419 36.1992 31.5354 35.9761 31.382L32.3161 28.87Z" fill="#B88F71"/>
          <path d="M45 22C45 22.5304 44.7893 23.0391 44.4142 23.4142C44.0391 23.7893 43.5304 24 43 24C42.4696 24 41.9609 23.7893 41.5858 23.4142C41.2107 23.0391 41 22.5304 41 22C41 21.4696 41.2107 20.9609 41.5858 20.5858C41.9609 20.2107 42.4696 20 43 20C43.5304 20 44.0391 20.2107 44.4142 20.5858C44.7893 20.9609 45 21.4696 45 22ZM60 26C60 26.5304 59.7893 27.0391 59.4142 27.4142C59.0391 27.7893 58.5304 28 58 28C57.4696 28 56.9609 27.7893 56.5858 27.4142C56.2107 27.0391 56 26.5304 56 26C56 25.4696 56.2107 24.9609 56.5858 24.5858C56.9609 24.2107 57.4696 24 58 24C58.5304 24 59.0391 24.2107 59.4142 24.5858C59.7893 24.9609 60 25.4696 60 26Z" fill="#B88F71"/>
          <path fill-rule="evenodd" clip-rule="evenodd" d="M32.5 47C32.5 46.6022 32.658 46.2206 32.9393 45.9393C33.2206 45.658 33.6022 45.5 34 45.5H51.474C51.8718 45.5 52.2534 45.658 52.5347 45.9393C52.816 46.2206 52.974 46.6022 52.974 47C52.974 47.3978 52.816 47.7794 52.5347 48.0607C52.2534 48.342 51.8718 48.5 51.474 48.5H34C33.6022 48.5 33.2206 48.342 32.9393 48.0607C32.658 47.7794 32.5 47.3978 32.5 47Z" fill="#B88F71"/>
          <path d="M30 26C30 26.5304 29.7893 27.0391 29.4142 27.4142C29.0391 27.7893 28.5304 28 28 28C27.4696 28 26.9609 27.7893 26.5858 27.4142C26.2107 27.0391 26 26.5304 26 26C26 25.4696 26.2107 24.9609 26.5858 24.5858C26.9609 24.2107 27.4696 24 28 24C28.5304 24 29.0391 24.2107 29.4142 24.5858C29.7893 24.9609 30 25.4696 30 26Z" fill="#B88F71"/>
          </g>
          <path fill-rule="evenodd" clip-rule="evenodd" d="M49.7921 41.636L52.8221 30.104L48.394 32.924C47.5111 33.4869 46.4426 33.6812 45.418 33.4651C44.3934 33.2489 43.4944 32.6396 42.914 31.768L40 27.39L37.084 31.77C36.5034 32.6413 35.6043 33.2502 34.5797 33.466C33.5551 33.6817 32.4868 33.4871 31.604 32.924L27.18 30.104L30.21 41.636H49.7941H49.7921ZM28.252 28.416C26.718 27.438 24.78 28.852 25.242 30.612L28.274 42.144C28.3863 42.5714 28.6369 42.9496 28.9868 43.2195C29.3367 43.4894 29.7661 43.6359 30.208 43.636H49.7921C50.234 43.6359 50.6634 43.4894 51.0133 43.2195C51.3632 42.9496 51.6138 42.5714 51.7261 42.144L54.7581 30.612C55.2181 28.852 53.2821 27.44 51.7481 28.416L47.32 31.236C46.8788 31.5176 46.3447 31.6151 45.8324 31.5074C45.3202 31.3997 44.8705 31.0955 44.58 30.66L41.664 26.28C41.4814 26.0061 41.234 25.7815 40.9437 25.6261C40.6534 25.4708 40.3293 25.3895 40 25.3895C39.6708 25.3895 39.3467 25.4708 39.0564 25.6261C38.7661 25.7815 38.5187 26.0061 38.336 26.28L35.42 30.66C35.1299 31.0958 34.6804 31.4005 34.1681 31.5085C33.6558 31.6166 33.1215 31.5195 32.68 31.238L28.252 28.416Z" fill="#B88F71"/>
          <path d="M41.888 21.89C41.8886 22.3912 41.69 22.8722 41.3359 23.227C40.9818 23.5818 40.5013 23.7814 40 23.782C39.4988 23.7825 39.0178 23.5839 38.663 23.2298C38.3082 22.8757 38.1086 22.3952 38.108 21.894C38.1075 21.3927 38.3061 20.9118 38.6602 20.5569C39.0143 20.2021 39.4948 20.0025 39.996 20.002C40.4973 20.0014 40.9782 20.2 41.3331 20.5541C41.6879 20.9082 41.8875 21.3887 41.888 21.89ZM57 25.672C57.0003 26.1732 56.8014 26.654 56.4472 27.0087C56.0929 27.3633 55.6123 27.5627 55.111 27.563C54.6098 27.5632 54.129 27.3643 53.7743 27.0101C53.4197 26.6558 53.2203 26.1752 53.22 25.674C53.22 25.1727 53.4192 24.692 53.7736 24.3375C54.1281 23.9831 54.6088 23.784 55.11 23.784C55.6113 23.784 56.092 23.9831 56.4465 24.3375C56.8009 24.692 57 25.1707 57 25.672ZM26.778 25.672C26.7782 25.9202 26.7294 26.1659 26.6346 26.3953C26.5397 26.6247 26.4006 26.8331 26.2252 27.0087C26.0498 27.1843 25.8415 27.3236 25.6122 27.4187C25.383 27.5138 25.1372 27.5628 24.889 27.563C24.6408 27.5631 24.3951 27.5143 24.1657 27.4195C23.9363 27.3246 23.7279 27.1855 23.5523 27.0101C23.3767 26.8347 23.2374 26.6264 23.1423 26.3972C23.0472 26.1679 22.9982 25.9222 22.998 25.674C22.998 25.1727 23.1972 24.692 23.5516 24.3375C23.9061 23.9831 24.3868 23.784 24.888 23.784C25.3893 23.784 25.87 23.9831 26.2245 24.3375C26.5789 24.692 26.778 25.1707 26.778 25.672Z" fill="#B88F71"/>
          <path fill-rule="evenodd" clip-rule="evenodd" d="M30.5 46C30.5 45.7348 30.6054 45.4804 30.7929 45.2929C30.9804 45.1054 31.2348 45 31.5 45H48.974C49.2392 45 49.4936 45.1054 49.6811 45.2929C49.8686 45.4804 49.974 45.7348 49.974 46C49.974 46.2652 49.8686 46.5196 49.6811 46.7071C49.4936 46.8946 49.2392 47 48.974 47H31.5C31.2348 47 30.9804 46.8946 30.7929 46.7071C30.6054 46.5196 30.5 46.2652 30.5 46Z" fill="#B88F71"/>
          </g>
          <defs>
          <filter id="filter0_d_2804_1009" x="0" y="0" width="80" height="80" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
          <feFlood flood-opacity="0" result="BackgroundImageFix"/>
          <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
          <feOffset dy="6"/>
          <feGaussianBlur stdDeviation="6"/>
          <feComposite in2="hardAlpha" operator="out"/>
          <feColorMatrix type="matrix" values="0 0 0 0 0.0976403 0 0 0 0 0.116137 0 0 0 0 0.138333 0 0 0 1 0"/>
          <feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow_2804_1009"/>
          <feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow_2804_1009" result="shape"/>
          </filter>
          </defs>
         </svg>
      ''';
  final BottomNavService _bottomNavService = BottomNavService();

  @override
  void initState() {
    super.initState();

    List<Rock> favoritedRocks = [];

    DatabaseHelper().wishlist().then((wishlist) {
      for (final rock in Rock.rockList) {
        for (final rockId in wishlist) {
          if (rockId == rock.rockId) {
            favoritedRocks.add(rock);
          }
        }
      }

      setState(() {
        favorites = favoritedRocks;
      });
    });

    if (widget.showFavorites == true) {
      setState(() {
        _bottomNavService.setIndex(1);
      });
    }
  }

  // List of the pages
  List<Widget> _widgetOptions() {
    return [
      const HomePage(),
      FavoritePage(
        favoritedRocks: favorites,
        showWishlist: widget.showFavorites == true,
      ),
    ];
  }

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home, size: 40),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(
        Icons.folder_copy,
        size: 40,
      ),
      label: 'Favorite',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ROCKAPP',
          style: TextStyle(
            color: Constants.primaryColor,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          InkWell(
            child: SvgPicture.string(crownIcon),
            onTap: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const PremiumScreen(),
              ),
            ),
          ),
        ],
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: IndexedStack(
        index: _bottomNavService.bottomNavIndex,
        children: _widgetOptions(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          BottomNavigationBar(
            backgroundColor: Constants.darkGrey,
            selectedItemColor: Constants.primaryColor,
            enableFeedback: false,
            unselectedItemColor: Constants.white.withOpacity(.5),
            items: _bottomNavItems,
            currentIndex: _bottomNavService.bottomNavIndex,
            onTap: (index) async {
              setState(() {
                _bottomNavService.setIndex(index);
              });
            },
          ),
          Positioned(
            bottom: 20,
            child: HexagonFloatingActionButton(
              heroTag: "scan",
              onPressed: () {
                ShowSelectionModalService().show(context);
              },
              child: Icon(
                Icons.camera_alt_rounded,
                size: 40,
                color: Constants.white,
              ),
              backgroundColor: Constants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
