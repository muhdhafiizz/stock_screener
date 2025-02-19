import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/watchlist_provider.dart';
import '../company_overview/company_overview_view.dart';
import 'search_page_controller.dart';

class SearchPageView extends StatelessWidget {
  const SearchPageView({super.key});

  Future<void> _refreshSearchList(BuildContext context) async {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    await searchProvider.refreshStocks();
    print("_refreshSearchList");
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back)),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "Search",
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: searchProvider.searchController,
                decoration: InputDecoration(
                  hintText: "Search your desire stock or symbol",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _refreshSearchList(context),
                  backgroundColor: Colors.black,
                  color: Colors.green,
                  child: (searchProvider.filteredStocks?.isEmpty ?? true)
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'assets/animations/empty_list_green_animation.json',
                                  height: 200,
                                  width: 200,
                                ),
                                const SizedBox(height: 20),
                                const Text("No results here."),
                              ],
                            ),
                          ],
                        )
                      : Scrollbar(
                          thickness: 6.0,
                          radius: Radius.circular(10),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount:
                                searchProvider.filteredStocks?.length ?? 0,
                            itemBuilder: (context, index) {
                              final stock =
                                  searchProvider.filteredStocks?[index];
                              if (stock == null) return SizedBox.shrink();

                              return InkWell(
                                onTap: () {
                                  debugPrint(
                                      "Navigating to CompanyOverviewView with symbol: ${stock.symbol}");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CompanyOverviewView(
                                          symbol: stock.symbol),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  title: Text(stock.name),
                                  subtitle: Text(
                                      "Symbol: ${stock.symbol} | Exchange: ${stock.exchange}"),
                                  trailing: Consumer<WatchlistProvider>(
                                    builder:
                                        (context, watchlistProvider, child) {
                                      final isInWatchlist = watchlistProvider
                                          .isInWatchlist(stock.symbol);
                                      return IconButton(
                                        icon: Icon(
                                          isInWatchlist
                                              ? Icons.check_circle
                                              : Icons.add_circle,
                                          color: isInWatchlist
                                              ? Colors.grey
                                              : Colors.green,
                                        ),
                                        onPressed: () {
                                          if (!isInWatchlist) {
                                            watchlistProvider
                                                .addToWatchlist(stock);
                                            _showSnackBar(
                                                context,
                                                "${stock.name} added to Watchlist!",
                                                Colors.green);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

void _showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
    ),
  );
}
