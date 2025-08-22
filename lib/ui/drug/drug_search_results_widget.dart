import 'package:drug_app/models/drug.dart';
import 'package:drug_app/ui/drug/drug_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DrugSearchResultsWidget extends StatelessWidget {
  final List<Drug> drugs;
  final String? query;
  const DrugSearchResultsWidget({super.key, required this.drugs, this.query});

  @override
  Widget build(BuildContext context) {
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (query == null)
            Text(
              "Kết quả quét nhanh",
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            )
          else ...[
            Text(
              "Kết quả tìm kiếm cho từ khóa",
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              "\"$query\"",
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: MasonryGridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 12,
              itemCount: drugs.length,
              itemBuilder: (context, index) {
                return DrugCard(drug: drugs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
