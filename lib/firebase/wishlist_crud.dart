import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app/model/wishlist_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  // Add a wish list item
  Future<void> addWishListItem(String itemName) async {
    if (currentUser != null) {
      final wishListItem = WishListItem(
        id: _db.collection('wishlist').doc().id,
        itemName: itemName,
        uid: currentUser!.uid,
        isPurchased: false, // New items are not purchased by default
      );
      await _db
          .collection('wishlist')
          .doc(wishListItem.id)
          .set(wishListItem.toMap());
    }
  }

  // Stream of wish list items
  // Get wish list for the current user
  Stream<List<WishListItem>> getWishListForUser() {
    if (currentUser != null) {
      return _db
          .collection('wishlist')
          .where('uid', isEqualTo: currentUser!.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => WishListItem.fromMap(doc.data(), doc.id))
              .toList());
    }
    return const Stream.empty();
  }

  // Update wish list item
  Future<void> updateWishListItem(String id, bool isPurchased) async {
    await _db
        .collection('wishlist')
        .doc(id)
        .update({'isPurchased': isPurchased});
  }

  // Delete wish list item
  Future<void> deleteWishListItem(String id) async {
    try {
      await _db.collection('wishlist').doc(id).delete();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }
}
