import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
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

  // Seller details for now.
  static const String sellerName = 'User12345';
  static const String sellerRating = '4.9';
  static const String sellerSales = '(42 sales)';

  GoogleMapController? mapController;

  Map<String, dynamic> listingArgs = {};
  String title = '';
  String description = '';
  String price = '';
  String address = '';
  bool prefilled = false;

  // Stores the address lookup result.
  Future<LatLng?>? coordinates;

  bool showFullDescription = false;

  // Loads listing data from the previous page.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (prefilled) return;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    setState(() {
      listingArgs = args ?? {};
      title = args?['title'] ?? 'No Title';
      description = args?['description'] ?? 'No Description';
      price = (args?['price'] as num?)?.toDouble().toString() ?? 'N/A';
      address = args?['address'] ?? '';
      coordinates = resolveAddress(address);
    });

    prefilled = true;
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  // Converts the address into map coordinates.
  Future<LatLng?> resolveAddress(String address) async {
    if (address.isEmpty) return null;

    try {
      final locations = await Geocoding().locationFromAddress(address);
      if (locations.isEmpty) return null;
      return LatLng(locations.first.latitude, locations.first.longitude);
    } catch (e) {
      // Returns null if the address cannot be found.
      return null;
    }
  }

  // Shows loading, error, or the map.
  Widget buildMap(BuildContext context, AsyncSnapshot<LatLng?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    final position = snapshot.data;

    if (position == null) {
      return Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: Text(
          'Location unavailable',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: position, zoom: 14.0),
      onMapCreated: (controller) => mapController = controller,
      // Adds the listing location marker.
      markers: {
        Marker(
          markerId: MarkerId("Listing Location"),
          position: position,
          infoWindow: InfoWindow(title: title),
        ),
      },
    );
  }

  // Toggles the description length.
  void _toggleDescription() {
    setState(() {
      showFullDescription = !showFullDescription;
    });
  }

  Future<void> onUpdate() async {
    final update_Result = await Navigator.pushNamed(
      context,
      '/updateListing',
      arguments: listingArgs,
    );

    if (!mounted) {
      return;
    }

    if (update_Result == true) {
      Navigator.pop(context, true);
    }
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
          // UI buttons for future actions.
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
                        address.isEmpty ? 'No location provided' : address,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
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

                // Seller information.
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

                // Keeps the map at a fixed height.
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: FutureBuilder<LatLng?>(
                      future: coordinates,
                      builder: buildMap,
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
                        address.isEmpty ? 'No address provided' : address,
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

                SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor, width: 2),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Edit Listing',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Buy button is just avisual for now.
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
