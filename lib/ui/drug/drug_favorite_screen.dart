import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:drug_app/manager/drug_favorite_manager.dart';
import 'package:drug_app/manager/search_history_manager.dart';
import 'package:drug_app/ui/components/medi_app_drawer.dart';
import 'package:drug_app/ui/drug/drug_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrugFavoriteScreen extends StatefulWidget {
  const DrugFavoriteScreen({super.key});
  static const routeName = '/favorite_drugs';

  @override
  State<DrugFavoriteScreen> createState() => _DrugFavoriteScreenState();
}

class _DrugFavoriteScreenState extends State<DrugFavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final drugFavoriteManager = context.read<DrugFavoriteManager>();
    final drugs = context.watch<DrugFavoriteManager>().drugs;
    final searchHistoryManager = context.read<SearchHistoryManager>();
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách yêu thích"), elevation: 4.0),
      drawer: MediAppDrawer(),
      body: ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: drugs.length,
        itemBuilder: (context, index) {
          final drug = drugs[index];
          return Dismissible(
            key: ValueKey(drug.id),
            direction: DismissDirection.startToEnd,
            background: Container(
              color: Colors.red,
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  const Icon(Icons.delete, color: Colors.white),
                ],
              ),
            ),
            onDismissed: (direction) {
              drugFavoriteManager.removeFavoriteDrug(drug);
              final snackBar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Đã xóa khỏi yêu thích',
                  message: 'Thuốc đã xóa khỏi danh sách yêu thích!',
                  contentType: ContentType.success,
                ),
              );
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);
            },
            child: ListTile(
              onTap: () {
                searchHistoryManager.saveSearchHistory(drug);
                Navigator.of(
                  context,
                ).pushNamed(DrugDetailsScreen.routeName, arguments: drug.id);
              },
              leading: SizedBox(
                width: 100,
                child: Image.network(
                  drug.getImage(thumb: '125x125f'),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                    );
                  },
                ),
              ),
              title: Text(drug.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  drugFavoriteManager.removeFavoriteDrug(drug);
                  final snackBar = SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Đã xóa khỏi yêu thích',
                      message: 'Thuốc đã xóa khỏi danh sách yêu thích!',
                      contentType: ContentType.success,
                    ),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
