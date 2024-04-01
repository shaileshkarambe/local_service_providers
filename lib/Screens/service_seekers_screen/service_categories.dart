import 'package:flutter/material.dart';
import 'package:local_service_providers/Screens/service_seekers_screen/service_providers.dart';
import 'package:local_service_providers/Widget/categories_grid_item.dart';
import 'package:local_service_providers/dummyData/service_categorie.dart';

class ServiceCategoryScreen extends StatelessWidget {
  const ServiceCategoryScreen({Key? key}) : super(key: key);

  void _selectCategory(BuildContext context, String cat) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => ServiceProviderScreen(
        item: cat, //passing category name
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: availabelCategories.length,
        itemBuilder: (ctx, index) {
          final category = availabelCategories[index];
          return CategoryGridItem(
            category: category,
            onSelectCategory: () {
              _selectCategory(context, category.title);
            },
          );
        },
      ),
    );
  }
}
