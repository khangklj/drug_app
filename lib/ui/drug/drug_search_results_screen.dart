import 'package:drug_app/models/drug.dart';
import 'package:drug_app/ui/drug/drug_card.dart';
import 'package:flutter/material.dart';

class DrugSearchResultsScreen extends StatelessWidget {
  final List<Drug> drugs;
  final String? query;
  const DrugSearchResultsScreen({super.key, required this.drugs, this.query});

  @override
  Widget build(BuildContext context) {
    if (drugs.isEmpty) {
      //TODO: implement no results screen
      return Container();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (query == null)
          const Text("Kết quả tìm kiếm nhanh")
        else
          Text(
            "Kết quả tìm kiếm cho từ khóa \"$query\"",
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
        DrugCard(drug: drugs[0]),
      ],
    );
  }
}
