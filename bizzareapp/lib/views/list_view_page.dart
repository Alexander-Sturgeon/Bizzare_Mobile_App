import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:bizzareapp/database/db_helper.dart';
import 'package:bizzareapp/models/db_result.dart';
import 'package:bizzareapp/widgets/bottom_nav.dart';
import 'package:bizzareapp/core/app_colors.dart';


class ListViewPage extends StatefulWidget {
  const ListViewPage({super.key});

  @override
  ListViewPageState createState() {
    return ListViewPageState();
  }

}

class ListViewPageState extends State<ListViewPage> {
  List<Map<String, dynamic>> _listings = [];
  bool _isLoading = true;
  String _message = "";

  @override
  void initState() {
    super.initState();
    fetchListings();
  }

  Future<void> fetchListings() async {
    DBResult result = await DBHelper.dbListing.readAllListing();

    setState(() {
      if (result.isSuccess) {
        _listings = result.listingList;
      } else {
        _message = result.message;
      }

      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bizzare Listings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(16),
          ),

          Expanded(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator()) 
              : _listings.isNotEmpty 
                ? ListView.builder(
                    itemCount: _listings.length,
                    itemBuilder: (context, index) {
                      final listing = _listings[index];

                    return InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/detailsPage',
                            arguments: listing,
                          ),
                          child: Card(
                            
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shadowColor: Colors.grey.shade400,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                'assets/images/placeholderListingImage.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listing['title'] ?? 'No Title',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    listing['description'] ?? 'No Description',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '\$${listing['price'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                          ),
                        );
                    },
                  )
                : Center(child: Text('No listings available')),
          )
        ],
      ),

      bottomNavigationBar: BottomNavBar(currentIndex: 0),
      );
  }
}

