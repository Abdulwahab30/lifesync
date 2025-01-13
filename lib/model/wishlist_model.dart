class WishListItem {
  final String id;
  final String itemName;
  final String uid;
  bool isPurchased; // New field to track whether the item has been purchased

  WishListItem({
    required this.id,
    required this.itemName,
    required this.uid,
    this.isPurchased = false, // Default to false
  });

  // Convert WishListItem to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'uid': uid,
      'isPurchased': isPurchased, // Include isPurchased
    };
  }

  // Create WishListItem object from Firestore document
  static WishListItem fromMap(Map<String, dynamic> map, String documentId) {
    return WishListItem(
      id: documentId,
      itemName: map['itemName'],
      uid: map['uid'],
      isPurchased: map['isPurchased'] ??
          false, // Map the isPurchased field, default to false
    );
  }
}
