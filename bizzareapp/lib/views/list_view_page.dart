import 'package:flutter/material.dart';
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

  //Search as new state.
  bool _isSearching = false;
  bool _argsChecked = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchListings();
  }

  //Getting listings here and putting them into the _listings Var
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

  //The Search bar opens at the top
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsChecked) {
      _argsChecked = true;
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is Map && arguments['openSearch'] == true) {
        _isSearching = true;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  //Filters the already loaded listings by title or description so it doesnt hit
  //the db every time
  List<Map<String, dynamic>> get visibleListings {
    final searchText = _searchController.text.trim().toLowerCase();
    if (searchText.isEmpty) {
      return _listings;
    }

    return _listings.where((listing) {
      final title = (listing['title'] ?? '').toString().toLowerCase();
      final description = (listing['description'] ?? '')
          .toString()
          .toLowerCase();
      return title.contains(searchText) || description.contains(searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: Colors.white, fontSize: 18),
                //The app theme puts an outlined box on every field, which looks
                //wrong inside the app bar so the border is removed here
                decoration: InputDecoration(
                  hintText: 'Search listings...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                //For search bar changes on every new letter for a more dynamic
                //feel
                onChanged: (value) => setState(() {}),
              )
            : Text(
                'Bizzare Listings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                //Clearing when closing search brings the full list of listings back
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(16)),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : visibleListings.isNotEmpty
                ? ListView.builder(
                    itemCount: visibleListings.length,
                    itemBuilder: (context, index) {
                      final listing = visibleListings[index];

                      return InkWell(
                        onTap: () async {
                          final edited = await Navigator.pushNamed(
                            context,
                            '/detailsPage',
                            arguments: listing,
                          );

                          if (edited == true) {
                            fetchListings();
                          }
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        listing['description'] ??
                                            'No Description',
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
                : Center(
                    child: Text(
                      _searchController.text.trim().isEmpty
                          ? 'No listings available'
                          : 'No listings match your search',
                    ),
                  ),
          ),
        ],
      ),

      //Highlight the Search button in the bottom bar while searching is active
      bottomNavigationBar: BottomNavBar(currentIndex: _isSearching ? 1 : 0),
    );
  }
}
