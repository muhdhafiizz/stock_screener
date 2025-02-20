import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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

  Future<void> _refreshStockList(BuildContext context) async {
    final stockProvider = Provider.of<StockProvider>(context, listen: false);
    await stockProvider.fetchStocks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopNavBar(context),
              const SizedBox(height: 10),
              Expanded(
                child: RefreshIndicator(
                  backgroundColor: Colors.black,
                  color: Colors.green,
                  onRefresh: () => _refreshStockList(context),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildSectionTitle("Stock List"),
                      _buildStockList(context),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WatchlistPageView(),
                            ),
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
                      _buildWatchlist(),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

  if (stockProvider.apiRateLimited) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
            ),
            Text(
              "API limit has been reached.\nPlease try again later.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  if (stockProvider.stocks == null || stockProvider.stocks!.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.sentiment_dissatisfied_sharp),
            Text(
              'Your stocklist is empty.\nPlease refresh.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  return SizedBox(
    height: 150,
    child: GridView.builder(
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 0.6,
      ),
      itemCount:
          stockProvider.stocks!.length > 4 ? 5 : stockProvider.stocks!.length,
      itemBuilder: (context, index) {
        if (index < 4) {
          final StockListing stock = stockProvider.stocks![index];

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
                    debugPrint("Stock Symbol: '${stock.symbol}'");

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

      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (var stock in watchlist) {
          stockPriceProvider.fetchStockPrice(stock.symbol);
        }
      });

      return watchlist.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.sentiment_dissatisfied_sharp),
                    Text(
                      'Your watchlist is currently empty.\nPlease select a stock.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
                              Expanded(
                                child: Text(
                                  stock.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              (stockData == null)
                                  ? const Text(
                                      "No data available",
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    )
                                  : stockPriceProvider.isLoading
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
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  '${stockData.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  "Change: ",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                                Text(
                                                  "${stockData.changePercent.toStringAsFixed(2)}%",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: stockData
                                                                .changePercent >=
                                                            0
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
