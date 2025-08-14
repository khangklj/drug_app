import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/manager/theme_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrugDetailsScreen extends StatefulWidget {
  final String drugId;
  static const String routeName = '/drug_details';
  const DrugDetailsScreen({super.key, required this.drugId});

  @override
  State<DrugDetailsScreen> createState() => _DrugDetailsScreenState();
}

class _DrugDetailsScreenState extends State<DrugDetailsScreen> {
  late Future<Drug?> _fetchDrugs;
  @override
  void initState() {
    _fetchDrugs = context.read<DrugManager>().fetchDrugDetails(
      id: widget.drugId,
    );
    super.initState();
  }

  List<Widget> convertHtmlToListWidgets(String htmlString) {
    List<Widget> resultWidgets = [];
    List<String> parts = htmlString.split(
      RegExp(r'(?<=</ul>)|(?=<ul>)|(?<=</li>)|(?=<li>)'),
    );

    bool inList = false;
    for (String part in parts) {
      String trimmedPart = part.trim();
      if (trimmedPart.isEmpty) {
        continue;
      }
      if (trimmedPart == '<ul>') {
        inList = true;
      } else if (trimmedPart == '</ul>') {
        inList = false;
      } else if (trimmedPart.startsWith('<li>') &&
          trimmedPart.endsWith('</li>') &&
          inList) {
        String listItemText = trimmedPart.substring(4, trimmedPart.length - 5);
        resultWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: Theme.of(context).textTheme.bodyLarge),
                Expanded(
                  child: Text(
                    listItemText.trim(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        String cleanedText = trimmedPart.replaceAll(
          RegExp(r'<[^>]*>|&[^;]+;'),
          '',
        );
        if (cleanedText.isNotEmpty) {
          List<String> paragraphs = cleanedText.split('\n');
          for (String paragraph in paragraphs) {
            paragraph = paragraph.trim();
            resultWidgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: paragraph,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }
      }
    }

    return resultWidgets;
  }

  Widget _buildDrugExpansionTile({
    required String title,
    required String content,
  }) {
    return ExpansionTile(
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      children: convertHtmlToListWidgets(content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = context.watch<ThemeManager>().themeMode;
    ValueNotifier<int> index = ValueNotifier<int>(0);
    return FutureBuilder(
      future: _fetchDrugs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          showDialog(
            context: context,
            builder: (context) {
              return CustomAlertDialog();
            },
          );
          return Container();
        }
        final Drug? drug = snapshot.data;
        if (drug == null || drug.data == null) {
          return CustomAlertDialog();
        }

        final List<Widget> tabBarContents = drug.data!.map((drugData) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      height: 300,
                      child: Image.network(
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
                        fit: BoxFit.fill,
                        drugData.getImage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      drugData.displayName,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (drug.aliases != null && drug.aliases!.isNotEmpty)
                    Center(
                      child: Text(
                        'Tên gọi khác: ${drug.aliases!.map((alias) => alias.name).join(', ')}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildDrugExpansionTile(
                    title: 'Chỉ định',
                    content: drugData.indications,
                  ),
                  _buildDrugExpansionTile(
                    title: 'Chống chỉ định',
                    content: drugData.contraindications,
                  ),
                  _buildDrugExpansionTile(
                    title: 'Cách dùng và liều dùng',
                    content: drugData.dosage,
                  ),
                  _buildDrugExpansionTile(
                    title: 'Tác dụng phụ',
                    content: drugData.adverseEffects,
                  ),
                  _buildDrugExpansionTile(
                    title: 'Bảo quản',
                    content: drugData.preservation,
                  ),
                  _buildDrugExpansionTile(
                    title: 'Lưu ý chung',
                    content: drugData.generalWarnings,
                  ),
                  _buildDrugExpansionTile(
                    title: 'Thời kì mang thai',
                    content: drugData.pregnacyWarnings,
                  ),
                  _buildDrugExpansionTile(
                    title: 'Thời kì cho con bú',
                    content: drugData.breastfeedingWarnings,
                  ),
                  _buildDrugExpansionTile(
                    title: 'Khả năng vận hành máy móc và lái xe',
                    content: drugData.drivingWarnings,
                  ),
                  _buildDrugExpansionTile(
                    title: 'Dược lực học',
                    content: drugData.pharmacodynamics,
                  ),
                  _buildDrugExpansionTile(
                    title: 'Dược động học',
                    content: drugData.pharmacokinetics,
                  ),
                ],
              ),
            ),
          );
        }).toList();

        return DefaultTabController(
          length: drug.data!.length,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              elevation: 4.0,
              title: Text(
                "MediApp",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              bottom: drug.data!.length > 1
                  ? TabBar(
                      tabs: List.generate(
                        drug.data!.length,
                        (index) => Tab(
                          child: Text(
                            drug.data![index].displayName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      onTap: (i) {
                        setState(() {
                          index.value = i;
                        });
                      },
                    )
                  : null,

              actions: [
                IconButton(
                  icon: currentThemeMode == ThemeMode.light
                      ? const Icon(Icons.light_mode_outlined)
                      : const Icon(Icons.dark_mode_outlined),
                  onPressed: () {
                    context.read<ThemeManager>().toggleTheme();
                  },
                ),
              ],
            ),
            body: TabBarView(children: tabBarContents),
          ),
        );
      },
    );
  }
}

class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error'),
      content: const Text(
        'Failed to fetch drug details. Please try again later.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Back to home'),
        ),
      ],
    );
  }
}
