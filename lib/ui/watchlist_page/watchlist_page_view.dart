import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../providers/watchlist_provider.dart';

class WatchlistPageView extends StatelessWidget {
  const WatchlistPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlistProvider = Provider.of<WatchlistProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
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
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Watchlist",
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: watchlistProvider.watchlist.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              'assets/animations/empty_list_green_animation.json',
                              height: 200,
                              width: 200,
                            ),
                            const SizedBox(height: 20),
                            const Text("Watchlist is empty.. and dusted."),
                          ],
                        ),
                      )
                    : Expanded(
                        child: Column(
                          children: ListTile.divideTiles(
                            context: context,
                            color: Colors.grey, 
                            tiles: watchlistProvider.watchlist.map((stock) {
                              return ListTile(
                                title: Text(stock.name),
                                subtitle: Text(stock.symbol),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    watchlistProvider
                                        .removeFromWatchlist(stock.symbol);
                                  },
                                ),
                              );
                            }),
                          ).toList(),
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
