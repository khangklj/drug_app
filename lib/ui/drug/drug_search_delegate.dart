import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:drug_app/ui/drug/drug_details_screen.dart';
import 'package:drug_app/ui/drug/drug_search_results_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrugSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    final DrugManager drugManager = context.read<DrugManager>();
    List<Drug> drugs = drugManager.searchDrugsMetadataByQuery(query);
    return DrugSearchResultsWidget(drugs: drugs, query: query);
  }

  @override
  void showResults(BuildContext context) {
    query = query.trim();
    if (query.isEmpty) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Lỗi tìm kiếm',
          message: 'Không được để trống từ khóa tìm kiếm!',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }
    super.showResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final DrugManager drugManager = context.read<DrugManager>();
    List<Drug> drugs = drugManager.searchDrugsMetadataByQuery(query);
    if (query.isEmpty) {
      return Container();
    } else {
      if (drugs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                child: Image.asset(
                  'assets/icons/no_results_icon.png',
                  semanticLabel: 'No results',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Không tìm thấy kết quả phù hợp",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        );
      }
      return ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: drugs.length,
        itemBuilder: (context, index) {
          final drug = drugs[index];
          return ListTile(
            onTap: () {
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
          );
        },
      );
    }
  }

  @override
  String get searchFieldLabel => 'Tìm kiếm thuốc...';
}
