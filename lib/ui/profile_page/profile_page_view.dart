import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stock_screener/providers/company_overview_providers.dart';
import 'package:stock_screener/ui/landing_page/landing_page_view.dart';


class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: double.infinity,
                child: SizedBox(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name",
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            user?.displayName ?? 'User',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Email",
                            style: const TextStyle(fontSize: 12),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                user?.email ?? 'Not provided',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    final email = user?.email ?? 'Not provided';
                                    Clipboard.setData(
                                        ClipboardData(text: email));
                                    _showSnackBar(
                                        context,
                                        "Email copied to clipboard.",
                                        Colors.green);
                                  },
                                  child: const Icon(Icons.copy)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildListTile(
                      context,
                      const Icon(Icons.clear),
                      "Clear cache",
                      () async {
                        final companyProvider = Provider.of<CompanyProvider>(
                            context,
                            listen: false);

                        await companyProvider.clearCache();

                        _showSnackBar(context, "Cache cleared!", Colors.green);
                      },
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    _buildListTile(
                      context,
                      const Icon(Icons.logout),
                      "Logout",
                      () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LandingPage()),
                        );
                      },
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

Widget _buildListTile(
    BuildContext context, Icon icon, String text, VoidCallback onTap) {
  return ListTile(
    leading: icon,
    title: Text(text),
    onTap: onTap,
  );
}

void _showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
    ),
  );
}
