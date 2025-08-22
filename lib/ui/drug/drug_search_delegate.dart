import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/manager/search_history_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:drug_app/ui/drug/drug_details_screen.dart';
import 'package:drug_app/ui/drug/drug_search_results_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrugSearchDelegate extends SearchDelegate {
  final SearchHistoryManager _searchHistoryManager = SearchHistoryManager();
  late Future<void> _fetchSearchHistory;
  DrugSearchDelegate() {
    _fetchSearchHistory = _searchHistoryManager.fetchSearchHistory();
  }

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
      return FutureBuilder(
        future: _fetchSearchHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Lỗi không truy cập được lịch sử tìm kiếm'),
            );
          }
          final List<Drug> drugs = context.watch<SearchHistoryManager>().drugs;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: drugs.length,
                  itemBuilder: (context, index) {
                    return DrugSearchHistoryTile(drug: drugs[index]);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Image.asset(
                          "assets/icons/swipe_right_icon.avif",
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        textAlign: TextAlign.center,
                        MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? "Tips 💡: Xóa lịch sử tìm kiếm\nbằng cách vuốt từ trái sang phải"
                            : "Tips 💡: Xóa lịch sử tìm kiếm bằng cách vuốt từ trái sang phải",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
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
          return DrugSearchTile(drug: drug);
        },
      );
    }
  }

  @override
  String get searchFieldLabel => 'Tìm kiếm thuốc...';
}

class DrugSearchHistoryTile extends StatelessWidget {
  const DrugSearchHistoryTile({super.key, required this.drug});
  final Drug drug;

  @override
  Widget build(BuildContext context) {
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
      onDismissed: (direction) async {
        final searchHistoryManager = context.read<SearchHistoryManager>();
        await searchHistoryManager.removeSearchHistory(drug);
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Thành công',
            message: 'Xóa lịch sử tìm kiếm thành công',
            contentType: ContentType.success,
          ),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
      },
      child: ListTile(
        onTap: () {
          final searchHistoryManager = context.read<SearchHistoryManager>();
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
              return const Icon(Icons.image_not_supported_outlined, size: 40);
            },
          ),
        ),
        title: Text(drug.name),
        trailing: const Icon(Icons.history),
      ),
    );
  }
}

class DrugSearchTile extends StatelessWidget {
  const DrugSearchTile({super.key, required this.drug});
  final Drug drug;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        final searchHistoryManager = context.read<SearchHistoryManager>();
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
            return const Icon(Icons.image_not_supported_outlined, size: 40);
          },
        ),
      ),
      title: Text(drug.name),
    );
  }
}
