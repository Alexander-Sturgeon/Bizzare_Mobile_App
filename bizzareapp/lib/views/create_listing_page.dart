import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:bizzareapp/widgets/bottom_nav.dart';
import 'package:bizzareapp/core/app_colors.dart';
import 'package:bizzareapp/database/db_helper.dart';
import 'package:bizzareapp/models/db_result.dart';
import 'package:geocoding/geocoding.dart';

class CreateListingPage extends StatelessWidget {
  CreateListingPage({super.key});

  //Every new listing uses this image until photo uploading is added.
  static const String placeholderImage =
      'assets/images/placeholderListingImage.jpg';

  final List<String> categories = [
    'Furniture',
    'Electronics',
    'Clothing',
    'Books',
    'Sports',
    'Other',
  ];

  final List<String> conditions = ['New', 'Like New', 'Good', 'Fair', 'Used'];

  final FormGroup frmListing = FormGroup({
    'title': FormControl<String>(validators: [Validators.required]),
    'description': FormControl<String>(validators: [Validators.required]),
    'price': FormControl<String>(
      validators: [
        Validators.required,
        Validators.number(allowedDecimals: 2, allowNegatives: false),
      ],
    ),
    'category': FormControl<String>(validators: [Validators.required]),
    'condition': FormControl<String>(validators: [Validators.required]),
    'address': FormControl<String>(validators: [Validators.required]),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          //The bottom nav replaces the route instead of pushing, so there is
          //no listings page under this one to pop back to.
          onPressed: () => Navigator.pushReplacementNamed(context, '/listView'),
        ),
        title: Text(
          'New Listing',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _publishListing(context),
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveForm(
          formGroup: frmListing,
          child: ListView(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  placeholderImage,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              ReactiveTextField(
                key: const Key('Title'),
                formControlName: 'title',
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 10),
              ReactiveTextField(
                key: const Key('Description'),
                formControlName: 'description',
                maxLines: 4,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ReactiveTextField(
                      key: const Key('Price'),
                      formControlName: 'price',
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Price'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ReactiveDropdownField(
                      key: const Key('Category'),
                      formControlName: 'category',
                      hint: Text('Select'),
                      decoration: InputDecoration(labelText: 'Category'),
                      items: categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ReactiveDropdownField(
                key: const Key('Condition'),
                formControlName: 'condition',
                hint: Text('Select a condition'),
                decoration: InputDecoration(labelText: 'Condition'),
                items: conditions
                    .map(
                      (condition) => DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 10),
              ReactiveTextField(
                key: const Key('Address'),
                formControlName: 'address',
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _publishListing(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Publish Listing',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2),
    );
  }

  Future<void> _publishListing(BuildContext context) async {
    frmListing.controls.forEach((key, control) {
      control.markAsTouched();
      control.updateValueAndValidity();
    });

    if (!frmListing.valid) return;

    final String address = frmListing.control('address').value;

    //  Using geocoding to verify the address
    try {
      final locations = await Geocoding().locationFromAddress(address);
      if (locations.isEmpty) throw Exception('No match found');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to find address. Try again')),
      );
      return;
    }

    //The keys have to match the column names in the listings table.
    final Map<String, dynamic> newListing = {
      'title': frmListing.control('title').value,
      'description': frmListing.control('description').value,
      'price': double.parse(frmListing.control('price').value),
      'category': frmListing.control('category').value,
      'condition': frmListing.control('condition').value,
      'image': placeholderImage,
      'address': address,
    };

    final DBResult result = await DBHelper.dbListing.insertListing(newListing);

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.isSuccess) {
      Navigator.pushReplacementNamed(context, '/listView');
    }
  }
}
