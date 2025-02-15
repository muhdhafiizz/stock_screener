import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_screener/providers/watchlist_provider.dart';
import 'package:stock_screener/ui/search_page/search_page_view.dart';
import 'package:stock_screener/ui/watchlist_page/watchlist_page_view.dart';
import 'package:stock_screener/ui/widgets/shimmer_widget.dart';
import '../../model/stock_listing_model.dart';
import '../../providers/price_percentage_provider.dart';
import '../../providers/stock_list_providers.dart';
import '../company_overview/company_overview_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildTopNavBar(context),
            SizedBox(height: 30),
            _buildSectionTitle("Stock List"),
            _buildStockList(context),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WatchlistPageView()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle("Watchlist"),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildWatchlist()
          ]),
        ),
      ),
    );
  }
}

Widget _buildTopNavBar(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Welcome",
        ),
        Text(
          user?.displayName ?? 'User',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ]),
      GestureDetector(
        child: Icon(Icons.search),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPageView()),
          );
        },
      )
    ],
  );
}

Widget _buildStockList(BuildContext context) {
  final stockProvider = Provider.of<StockProvider>(context);

  return SizedBox(
    height: 150,
    child: GridView.builder(
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 0.6,
      ),
      itemCount:
          stockProvider.stocks.length > 4 ? 5 : stockProvider.stocks.length,
      itemBuilder: (context, index) {
        if (index < 4) {
          final StockListing stock = stockProvider.stocks[index];

          return SizedBox(
            child: Card(
              margin: const EdgeInsets.all(8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    debugPrint(
                        "Stock Symbol: '${stock.symbol}'"); 

                    if (stock.symbol.trim().toLowerCase() == "n/a" ||
                        stock.symbol.trim().isEmpty) {
                      debugPrint("⚠️ API limit reached. Showing Snackbar.");

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "API limit has been reached. Please try again later."),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      return;
                    }

                    debugPrint(
                        "✅ Navigating to CompanyOverviewView with symbol: ${stock.symbol}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CompanyOverviewView(symbol: stock.symbol),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Symbol: ${stock.symbol}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return SizedBox(
            child: InkWell(
              onTap: () {
                debugPrint("Navigating to full watchlist");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPageView(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "View All",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      Icon(Icons.arrow_forward)
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    ),
  );
}

Widget _buildWatchlist() {
  return Consumer2<WatchlistProvider, StockPriceProvider>(
    builder: (context, watchlistProvider, stockPriceProvider, child) {
      final watchlist = watchlistProvider.watchlist;

      Future.microtask(() {
        for (var stock in watchlist) {
          if (!stockPriceProvider.stockPrices.containsKey(stock.symbol)) {
            stockPriceProvider.fetchStockPrice(stock.symbol);
          }
        }
      });

      return watchlist.isEmpty
          ? const Center(
              child: Text(
                "Your watchlist is currently empty.\nPlease select a stock.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          : SizedBox(
              height: 150,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 0.6,
                ),
                itemCount: watchlist.length,
                itemBuilder: (context, index) {
                  final StockListing stock = watchlist[index];
                  final stockData =
                      stockPriceProvider.stockPrices[stock.symbol];

                  return SizedBox(
                    child: Card(
                      margin: const EdgeInsets.all(8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CompanyOverviewView(symbol: stock.symbol),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stock.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              (stockData == null ||
                                      stockPriceProvider.isLoading)
                                  ? const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text("Price: "),
                                            SizedBox(width: 5),
                                            ShimmerLoadingWidget(
                                                width: 40, height: 14),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text("Change: "),
                                            SizedBox(width: 5),
                                            ShimmerLoadingWidget(
                                                width: 50, height: 14),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              "Price: ",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              '${stockData.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              "Change: ",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              "${stockData.changePercent.toStringAsFixed(2)}%",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    stockData.changePercent >= 0
                                                        ? Colors.green
                                                        : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
    },
  );
}

Widget _buildSectionTitle(String title) {
  return Text(title,
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold));
}
