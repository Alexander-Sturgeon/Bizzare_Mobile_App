import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:bizzareapp/core/app_colors.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  DetailsPageState createState() {
    return DetailsPageState();
  }
}

class DetailsPageState extends State<DetailsPage> {
  static const String placeholderImage =
      'assets/images/placeholderListingImage.jpg';

  // Just using some fake listing info for now. as we are not implementing a
  // geolocator
  static const double listingLatitude = 49.282730;
  static const double listingLongitude = -123.120735;
  static const String listingLocation = 'Vancouver, BC';
  static const String listingAddress = '433 Robston St Vancouver, BC, V6B 6L9';
  static const String sellerName = 'User12345';
  static const String sellerRating = '4.9';
  static const String sellerSales = '(42 sales)';

  GoogleMapController? mapController;
  final Set<Marker> _markers = {};

  String title = '';
  String description = '';
  String price = '';
  bool prefilled = false;

  bool showFullDescription = false;

  // Gets the listing info passed from the previous page.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (prefilled) return;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    setState(() {
      title = args?['title'] ?? 'No Title';
      description = args?['description'] ?? 'No Description';
      price = (args?['price'] as num?)?.toDouble().toString() ?? 'N/A';
    });

    prefilled = true;
  }

  // Add the marker once the map is ready.
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("Listing Location"),
          position: LatLng(listingLatitude, listingLongitude),
          infoWindow: InfoWindow(title: title),
        ),
      );
    });
  }

  // Switches between the short and full description.
  void _toggleDescription() {
    setState(() {
      showFullDescription = !showFullDescription;
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = AppColors.background;
    final primaryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Listing Details',
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // These buttons are just for the UI right now.
          IconButton(
            icon: Icon(Icons.share, color: primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Image.asset(
            placeholderImage,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            color: primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        listingLocation,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$$price',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  maxLines: showFullDescription ? null : 4,
                  overflow: showFullDescription
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: _toggleDescription,
                  child: Row(
                    children: [
                      Text(
                        showFullDescription ? 'Read Less' : 'Read More',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        showFullDescription
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.danger,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Seller info is hardcoded for now.
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryColor, width: 2),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sellerName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: AppColors.danger,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                sellerRating,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 6),
                              Text(
                                sellerSales,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // The SizedBox gives the map a fixed height inside the ListView.
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(listingLatitude, listingLongitude),
                        zoom: 14.0,
                      ),
                      onMapCreated: _onMapCreated,
                      markers: _markers,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: primaryColor,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        listingAddress,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Buy button is only visual for now.
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Buy Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
