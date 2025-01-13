import 'package:flutter/material.dart';
import 'package:todo_app/firebase/wishlist_crud.dart';

class AddWishListItemDialog extends StatefulWidget {
  const AddWishListItemDialog({super.key});

  @override
  _AddWishListItemDialogState createState() => _AddWishListItemDialogState();
}

class _AddWishListItemDialogState extends State<AddWishListItemDialog> {
  final _formKey = GlobalKey<FormState>();
  String _itemName = '';

  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners
      ),
      elevation: 16,
      backgroundColor: Colors.white, // Set a clean white background
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog Title
            const Text(
              'Add Wish List Item',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey, // Stylish title color
              ),
            ),
            const SizedBox(height: 16),

            // Form Input
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  labelStyle: const TextStyle(color: Colors.blueGrey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Rounded corners for text field
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueGrey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _itemName = value!;
                },
              ),
            ),
            const SizedBox(height: 20),

            // Actions: Cancel and Add Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel Button
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Colors.grey[300], // Light grey for cancel button
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Dark text for contrast
                    ),
                  ),
                ),
                // Add Button
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueGrey, // Blue for the add button
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      // Add the item to Firestore
                      _firestoreService.addWishListItem(_itemName).then((_) {
                        Navigator.of(context).pop();
                      }).catchError((error) {
                        print("Failed to add wish list item: $error");
                      });
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for contrast
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
