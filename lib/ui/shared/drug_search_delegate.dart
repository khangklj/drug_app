import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/models/drug.dart';
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
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final DrugManager drugManager = context.read<DrugManager>();
    List<Drug> drugs = query.isEmpty
        ? drugManager.drugs
        : drugManager.searchDrugsMetadata(query);
    if (query.isEmpty) {
      // TODO: handle query is empty case
      return const Placeholder();
    } else {
      return ListView.separated(
        separatorBuilder: (context, index) => const Divider(),
        itemCount: drugs.length,
        itemBuilder: (context, index) {
          final drug = drugs[index];
          return ListTile(
            leading: SizedBox(
              width: 100,
              child: Image.network(
                drug.image,
                fit: BoxFit.fill,
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
                    Icons.broken_image,
                    size: 60,
                    color: Colors.grey,
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
}
