import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:stock_screener/model/stock_listing_model.dart';
import 'package:stock_screener/providers/stock_chart_provider.dart';
import 'package:stock_screener/ui/widgets/shimmer_widget.dart';
import '../../model/company_overview_model.dart';
import '../../providers/company_overview_providers.dart';
import '../../providers/watchlist_provider.dart';

class CompanyOverviewView extends StatelessWidget {
  final String symbol;

  const CompanyOverviewView({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final companyProvider =
        Provider.of<CompanyProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      companyProvider.loadCompanyOverview(symbol);
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Company Overview")),
      body: Consumer<CompanyProvider>(
        builder: (context, provider, child) {
          debugPrint("Loading state: ${provider.isLoading}");

          return _buildBody(provider, context);
        },
      ),
    );
  }
}

Widget _buildBody(CompanyProvider provider, BuildContext context) {
  if (provider.apiRateLimited) {
    return _buildApiLimitReached();
  }

  if (provider.company == null) {
    return _buildNoData(provider);
  }

  return _buildCompanyDetails(provider.company!, context);
}

Widget _buildCompanyDetails(CompanyOverview company, BuildContext context) {
  StockListing stock = StockListing(
      symbol: company.symbol, name: company.name, exchange: company.marketCap);

  final stockProvider = Provider.of<StockChartProviders>(context);
  final companyProvider = Provider.of<CompanyProvider>(context);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    stockProvider.fetchStockChart(company.symbol);
  });
  

  return Padding(
    padding: const EdgeInsets.all(20.0),
    child: ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(company.name,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.visible),
                      maxLines: 10),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    company.symbol,
                    style: const TextStyle(
                        fontSize: 20, color: Color.fromARGB(255, 61, 61, 61)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Consumer<WatchlistProvider>(
              builder: (context, watchlistProvider, child) {
                final isAdded = watchlistProvider.isInWatchlist(stock.symbol);
                return IconButton(
                  icon: Icon(
                    isAdded ? Icons.delete : Icons.add_circle,
                    color: isAdded ? Colors.red : Colors.green,
                  ),
                  onPressed: () {
                    if (!isAdded) {
                      watchlistProvider.addToWatchlist(stock);
                      _showSnackBar(context,
                          "${stock.name} added to Watchlist!", Colors.green);
                    } else {
                      watchlistProvider.removeFromWatchlist(stock.symbol);
                      _showSnackBar(context,
                          "${stock.name} removed from Watchlist!", Colors.red);
                    }
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3,
          children: [
            _buildDetailText(
                "Market Cap",
                formatMarketCap(num.tryParse(company.marketCap) ?? 0),
                companyProvider.isLoading),
            _buildDetailText(
                "52 Weeks Low", company.weeksLow, companyProvider.isLoading),
            _buildDetailText(
                "52 Weeks High", company.weeksHigh, companyProvider.isLoading),
            _buildDetailText("Dividend Yield", company.dividendYield,
                companyProvider.isLoading),
            _buildDetailText(
                "Currency", company.currency, companyProvider.isLoading),
            _buildDetailText("Earning Per Share", company.earningPerShare,
                companyProvider.isLoading)
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionTitle("Description"),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(company.description, textAlign: TextAlign.justify),
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionTitle("Chart"),
        _buildStockChart(context, stock.symbol),
      ],
    ),
  );
}

Widget _buildDetailText(String label, String value, bool isLoading) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(child: Text(label, style: const TextStyle(fontSize: 14))),
      const SizedBox(height: 4),
      isLoading
          ? const ShimmerLoadingWidget(width: 20, height: 14)
          : Flexible(
              child: Text(
                value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
    ],
  );
}

Widget _buildSectionTitle(String title) {
  return Text(title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
}

void _showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
    ),
  );
}

Widget _buildStockChart(BuildContext context, String symbol) {
  return Selector<StockChartProviders, bool>(
    selector: (_, provider) => provider.isLoading,
    builder: (context, isLoading, child) {
      debugPrint("StockChartProviders - isLoading: $isLoading");

      return Consumer<StockChartProviders>(
        builder: (context, stockProvider, child) {
          if (stockProvider.isLoading) {
            return const Center(
                child: ShimmerLoadingWidget(width: 250, height: 14));
          } else if (stockProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/empty_list_green_animation.json',
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    stockProvider.errorMessage ?? "No data available",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          } else if (stockProvider.stockHistory.isEmpty) {
            return const Center(child: Text("No data available"));
          }

          int itemCount = stockProvider.stockHistory.length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _calculateDynamicInterval(
                            stockProvider.stockHistory.length),
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 &&
                              index < stockProvider.stockHistory.length) {
                            String fullDate =
                                stockProvider.stockHistory[index].date;
                            String year = fullDate.split("-")[0];

                            return Text(
                              year,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return Container();
                        },
                        reservedSize: 20,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(itemCount, (index) {
                        final data = stockProvider.stockHistory[index];
                        return FlSpot(index.toDouble(), data.closingPrice);
                      }),
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.green.withOpacity(0.8),
                      isStrokeCapRound: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildApiLimitReached() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/api_limit_reached_animation.json',
          height: 200,
          width: 200,
        ),
        const SizedBox(height: 10),
        const Text(
          "Oops.. You have reached your API limit.\nPlease try again later.",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildNoData(CompanyProvider provider) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/empty_list_green_animation.json',
          height: 200,
          width: 200,
        ),
        const SizedBox(height: 10),
        Text(
          provider.errorMessage ?? "No data available",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

String formatMarketCap(num value) {
  if (value >= 1e9) {
    return '${(value / 1e9).toStringAsFixed(1)}B';
  } else if (value >= 1e6) {
    return '${(value / 1e6).toStringAsFixed(1)}M';
  } else {
    return value.toString();
  }
}

double _calculateDynamicInterval(int itemCount) {
  if (itemCount <= 5) {
    return 1;
  } else if (itemCount <= 20) {
    return 2;
  } else if (itemCount <= 50) {
    return 5;
  } else if (itemCount <= 100) {
    return 10;
  } else {
    return (itemCount / 10).floorToDouble();
  }
}
