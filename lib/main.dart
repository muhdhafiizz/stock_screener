import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'package:stock_screener/firebase_options.dart';
import 'package:stock_screener/providers/price_percentage_provider.dart';
import 'package:stock_screener/providers/watchlist_provider.dart';
import 'package:stock_screener/repositories/stock_price_repository.dart';
import 'package:stock_screener/ui/bottom_navbar/bottom_navbar_view.dart';
import 'package:stock_screener/ui/landing_page/landing_page_view.dart';
import 'package:stock_screener/ui/search_page/search_page_controller.dart';
import 'package:stock_screener/ui/splash_screen/splash_screen.dart';

import 'model/company_overview_model.dart';
import 'model/stock_chart_model.dart';
import 'model/stock_listing_model.dart';
import 'providers/company_overview_providers.dart';
import 'providers/stock_chart_provider.dart';
import 'providers/stock_list_providers.dart';
import 'repositories/stocks_chart_repositories.dart';
import 'ui/bottom_navbar/bottom_navbar_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  Hive.registerAdapter(StockListingAdapter());
  Hive.registerAdapter(CompanyOverviewAdapter());
  Hive.registerAdapter(StockChartDataAdapter());
  await openHiveBoxes();

  final stockRepository = StockChartRepository();

  runApp(MyApp(stockRepository: stockRepository));
}

Future<void> openHiveBoxes() async {
  await Hive.openBox<StockListing>('stock_cache');
  await Hive.openBox<CompanyOverview>('company_cache');
  await Hive.openBox('stock_prices_cache');
}

class MyApp extends StatelessWidget {
  final StockChartRepository stockRepository;
  const MyApp({super.key, required this.stockRepository});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavController()),
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => StockProvider()..fetchStocks()),
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(
            create: (_) => StockChartProviders(stockRepository)),
        ChangeNotifierProvider(
            create: (_) => StockPriceProvider(StockPriceRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: ThemeData(fontFamily: 'Liter'),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthNotifier extends ChangeNotifier {
  bool _isLoading = true;
  bool _hasInternet = false;

  bool get isLoading => _isLoading;
  bool get hasInternet => _hasInternet;

  AuthNotifier() {
    _initialize();
  }

  Future<void> _initialize() async {
    _hasInternet = await _checkInternetConnection();
    if (!_hasInternet) {
      _showNoInternetDialog();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _showNoInternetDialog() {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: MyApp.navigatorKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            title: const Text("No Internet Connection"),
            content: const Text("Please check your connection and try again."),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  _initialize();
                },
                child: const Text("Retry"),
              ),
            ],
          );
        },
      );
    });
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        if (authNotifier.isLoading) {
          return const SplashScreen();
        } else {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              } else if (snapshot.hasData) {
                return BottomNavView();
              } else {
                return const LandingPage();
              }
            },
          );
        }
      },
    );
  }
}
