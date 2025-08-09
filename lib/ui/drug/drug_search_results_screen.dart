import 'package:drug_app/models/drug.dart';
import 'package:drug_app/ui/drug/drug_search_results_widget.dart';
import 'package:flutter/material.dart';

class DrugSearchResultsScreen extends StatelessWidget {
  final List<Drug> drugs;
  static const routeName = '/search-results';
  const DrugSearchResultsScreen({super.key, required this.drugs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("MediApp"),
      ),
      body: DrugSearchResultsWidget(drugs: drugs),
    );
  }
}
