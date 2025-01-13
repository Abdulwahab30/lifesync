import 'package:flutter/material.dart';
import 'package:todo_app/firebase/wishlist_crud.dart';
import 'package:todo_app/model/wishlist_model.dart';
import 'package:todo_app/screens/wishlist/wishlist_dialogue.dart';

class WishListScreen extends StatefulWidget {
  WishListScreen({super.key});

  @override
  _WishListScreenState createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Wish List',
          style: TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueGrey,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blueGrey,
          tabs: const [
            Tab(
                child: Text(
              "Wish List",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
            Tab(
                child: Text(
              "Purchased",
              style: TextStyle(fontWeight: FontWeight.bold),
            )),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWishListTab(false), // Items not purchased
          _buildWishListTab(true), // Purchased items
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddWishListItemDialog(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Method to build the content of each tab
  Widget _buildWishListTab(bool isPurchased) {
    return StreamBuilder<List<WishListItem>>(
      stream: _firestoreService.getWishListForUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading wish list'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              isPurchased
                  ? 'No purchased items yet'
                  : 'No items in your wish list',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final wishList = snapshot.data!
            .where((item) => item.isPurchased == isPurchased)
            .toList();

        if (wishList.isEmpty) {
          return Center(
            child: Text(
              isPurchased
                  ? 'No purchased items yet'
                  : 'No items in your wish list',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: wishList.length,
          itemBuilder: (context, index) {
            final item = wishList[index];
            return _buildWishListCard(item);
          },
        );
      },
    );
  }

  // Method to build the wish list card
  Widget _buildWishListCard(WishListItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor:
                    item.isPurchased ? Colors.green : Colors.blueGrey,
                child: Icon(
                  item.isPurchased ? Icons.check : Icons.shopping_cart,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.itemName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: item.isPurchased,
                onChanged: (newValue) {
                  _firestoreService.updateWishListItem(item.id, newValue!);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () {
                  _firestoreService.deleteWishListItem(item.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
