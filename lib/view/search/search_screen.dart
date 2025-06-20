import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/common/color_extension.dart';
import 'package:untitled/controller/expense_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ExpenseController expenseCtrl = Get.put(ExpenseController());

  List<String> _allItems = []; // All category names
  List<String> _filteredItems = []; // Filtered category names

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  Future<void> _loadCategories() async {
    // Call the fetch method which populates the RxList
    await expenseCtrl.fetchCurrentMonthExpenseCategories().then((fetchedCategories) {
      // Populate RxList manually here if fetchCategories() isn't used
      expenseCtrl.currentMonthCategories.assignAll(fetchedCategories);

      if (fetchedCategories.isNotEmpty) {
        setState(() {
          _allItems = fetchedCategories.map((cat) => cat['category'] ?? '').toList();
          _filteredItems = _allItems;
        });
      }
    });
  }



  // Filter categories based on the search query
  void _filterSearchResults(String query) {
    setState(() {
      _filteredItems = _allItems
          .where((category) =>
          category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.back,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Search category",
                  style: TextStyle(color: TColor.gray80, fontSize: 16),
                )
              ],
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey, width: 1),
                color: Colors.white,
              ),
              child: TextField(
                onChanged: _filterSearchResults,
                decoration: const InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredItems.isNotEmpty
                  ? ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_filteredItems[index]),
                    leading: const Icon(Icons.check_circle_outline),
                  );
                },
              )
                  : const Center(
                child: Text(
                  "No results found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
