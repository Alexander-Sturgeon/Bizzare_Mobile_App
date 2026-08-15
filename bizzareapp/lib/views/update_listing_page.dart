import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:bizzareapp/widgets/bottom_nav.dart';
import 'package:bizzareapp/core/app_colors.dart';
import 'package:bizzareapp/database/db_helper.dart';
import 'package:bizzareapp/models/db_result.dart';
import 'package:geocoding/geocoding.dart';

//Update page functionality. Also contains ability to delete listing. Stateful because input fields are prefilled upon the page loading, using didChangeDependencies.
class UpdateListingPage extends StatefulWidget {
  const UpdateListingPage({super.key});

  @override
  UpdateListingPageState createState() {
    return UpdateListingPageState();
  }
}

class UpdateListingPageState extends State<UpdateListingPage> {
  int? listingId;
  bool prefilled = false;

  static const String placeholderImage =
      'assets/images/placeholderListingImage.jpg';

  //list of available categories
  final List<String> categories = [
    'Furniture',
    'Electronics',
    'Clothing',
    'Books',
    'Sports',
    'Other',
  ];

  //list of possible listing conditions
  final List<String> conditions = ['New', 'Like New', 'Good', 'Fair', 'Used'];

  //this form group effectively holds the inputs and the validators for them, they are all required except for the price which also must be a number.
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

  //didChangeDepencies catches the information from the list view page and uses patchvalue to insert the currently selected product information into the formgroups inputs so the input fields are filled.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (prefilled) return;
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    listingId = args['listingId'] as int;

    //this is basically what prefills the formgroup
    frmListing.patchValue({
      'title': args['title'],
      'description': args['description'],
      'price': (args['price'] as num).toDouble().toString(),
      'category': args['category'],
      'condition': args['condition'],
      'address': args['address'] ?? '',
    });

    //boolean for checking prefilled status
    prefilled = true;
  }

  //way of disposing of objects that don't automatically end upon the page closing, in this case its just the form group.
  @override
  void dispose() {
    frmListing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          //main title text for the page.
          'Edit Listing',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            //this is the button that actually calls the helper method that accesses the db via DBHelper found below.
            onPressed: () => _updateListing(context),
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
        padding: const EdgeInsets.all(16),
        child: ReactiveForm(
          //reactive form is what basically makes form group available to the rest of the tree underneath it. It's essentially a way to make things cleaner; seperating the form data and ruleset from the widgets. Without it we would have needed 5 controllers with 5 rulesets and 5 things to dispose.
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
                  SizedBox(height: 30),
                  Expanded(
                    child: ReactiveDropdownField(
                      key: const Key('Cateogry'),
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
              SizedBox(height: 20),
              SizedBox(
                child: ElevatedButton(
                  //This is what calls the helper method that accesses the db helper function via DBHelper and actually deletes the listing.
                  onPressed: () => _deleteListing(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.danger,
                  ),
                  child: Text(
                    'Delete Listing',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _updateListing(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Update Listing',
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

  //Handles updating the listing in the db using listingId and the DBHelper.
  Future<void> _updateListing(BuildContext context) async {
    frmListing.controls.forEach((key, control) {
      control.markAsTouched();
      control.updateValueAndValidity();
    });

    if (frmListing.valid) {
      // verifying the address exists using geocoding
      try {
        final locations = await Geocoding().locationFromAddress(
          frmListing.control('address').value,
        );
        if (locations.isEmpty) throw Exception('No match found');
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to find that address.')));
        return;
      }

      //keys have to match column names in listings table
      final Map<String, dynamic> listing = {
        'title': frmListing.control('title').value,
        'description': frmListing.control('description').value,
        'price': double.parse(frmListing.control('price').value),
        'category': frmListing.control('category').value,
        'condition': frmListing.control('condition').value,
        'address': frmListing.control('address').value,
      };

      final DBResult result = await DBHelper.dbListing.updateListing(
        listingId!,
        listing,
      ); //await that calls the updateListing method to actually update the corrosponding listing in the db.

      if (!context.mounted) return;

      //Shows result message of the updateListing method
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      //If the item is successfully updated it pops the page from the stack.
      if (result.isSuccess) {
        Navigator.pop(context, true);
      }
    }
  }

  //handles deleting the product from the database using the DBHelper.
  Future<void> _deleteListing(BuildContext context) async {
    //essentially confirms that user actually wants to delete the product before continuing.
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deleteion"),
        content: Text("Are you sure you want to delete this?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Delete", style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    //virtually the same thing as the updatelisting function in terms of general structure, uses the delete Listing method from dbhelper and returns the result.message and pops the page if successful.
    final DBResult result = await DBHelper.dbListing.deleteListing(listingId!);

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (result.isSuccess) {
      Navigator.pop(context, true);
    }
  }
}
