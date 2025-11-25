import 'package:collection/collection.dart';
import 'package:drug_app/manager/drug_manager.dart';
import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/manager/patient_manager.dart';
import 'package:drug_app/models/drug.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/models/patient.dart';
import 'package:drug_app/ui/components/medi_app_drawer.dart';
import 'package:drug_app/ui/drug/drug_details_screen.dart';
import 'package:drug_app/ui/medi_app_homepage_screen.dart';
import 'package:drug_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _SortDrugPrescriptionOptions { nodAsc, nodDesc }

class DrugPrescriptionPayloadScreen extends StatefulWidget {
  const DrugPrescriptionPayloadScreen({super.key, required this.timeOfDay});

  static const routeName = "/drug_prescription_payload";
  final TimeOfDayValues timeOfDay;

  @override
  State<DrugPrescriptionPayloadScreen> createState() =>
      _DrugPrescriptionPayloadScreenState();
}

class _DrugPrescriptionPayloadScreenState
    extends State<DrugPrescriptionPayloadScreen> {
  late Patient? _filterPatient;
  late _SortDrugPrescriptionOptions _sortOption;
  final Map<String, List<bool>> dpCheckedMap = {};

  @override
  void initState() {
    super.initState();

    _filterPatient = null;
    _sortOption = _SortDrugPrescriptionOptions.nodAsc;
  }

  Future<Patient?> showFilterByPatientDialog(
    BuildContext context,
    List<Patient> patients,
  ) async {
    Patient? selectedValue = _filterPatient;
    return showDialog<Patient>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Lọc theo người bệnh"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                height: 3 * 60,
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    child: RadioGroup<Patient?>(
                      groupValue: selectedValue,
                      onChanged: (value) =>
                          setState(() => selectedValue = value),
                      child: Column(
                        children: [
                          RadioListTile<Patient?>(
                            title: Text("Tất cả"),
                            value: null,
                          ),
                          ...patients.map((patient) {
                            return RadioListTile<Patient?>(
                              title: Text(patient.name!),
                              value: patient,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedValue),
              child: const Text("Chọn"),
            ),
          ],
        );
      },
    );
  }

  List<DrugPrescription> _applySortAndFilter(
    List<DrugPrescription> original, {
    required _SortDrugPrescriptionOptions sortOption,
    required Patient? filterPatient,
  }) {
    final List<DrugPrescription> newList = original
        .where((dp) => dp.isActive)
        .where((dp) {
          if (_filterPatient == null) return true;
          return dp.patient!.id == _filterPatient!.id;
        })
        .where((dp) {
          return dp.items.any((item) => item.timeOfDay == widget.timeOfDay);
        })
        .sorted((a, b) {
          if (sortOption == _SortDrugPrescriptionOptions.nodAsc) {
            return b.activeDate!.compareTo(a.activeDate!);
          } else if (sortOption == _SortDrugPrescriptionOptions.nodDesc) {
            return a.activeDate!.compareTo(b.activeDate!);
          }
          return b.activeDate!.compareTo(a.activeDate!);
        })
        .toList();
    return newList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4.0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Text(
          "Danh sách thuốc",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed(MediAppHomepageScreen.routeName);
            },
          ),
        ],
      ),
      drawer: MediAppDrawer(),
      body: Consumer<DrugPrescriptionManager>(
        builder: (context, manager, child) {
          final dpList = _applySortAndFilter(
            manager.drugPrescriptions,
            sortOption: _sortOption,
            filterPatient: _filterPatient,
          );

          final isEmptyAll = dpList.every(
            (dp) => dp.items
                .where((dpItem) => dpItem.timeOfDay == widget.timeOfDay)
                .toList()
                .isEmpty,
          );
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Danh sách thuốc buổi ${widget.timeOfDay.toDisplayString().toLowerCase()}",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text("💡 Tips: Nhấn giữ để xem thông tin thuốc"),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list_alt),
                        const SizedBox(width: 5),
                        Text(
                          "Bộ lọc",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Consumer<PatientManager>(
                    builder: (context, patientManager, child) {
                      return DropdownMenu(
                        menuHeight: 200,
                        enableSearch: true,
                        enableFilter: true,
                        requestFocusOnTap: true,
                        width: double.infinity,
                        label: const Text("Người bệnh"),
                        initialSelection: _filterPatient,
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            label: "Tất cả",
                            value: null,
                            trailingIcon: _filterPatient == null
                                ? const Icon(Icons.check)
                                : null,
                          ),
                          ...patientManager.patients.map((patient) {
                            return DropdownMenuEntry(
                              label: patient.name!,
                              value: patient,
                              trailingIcon: _filterPatient == patient
                                  ? const Icon(Icons.check)
                                  : null,
                            );
                          }),
                        ],
                        onSelected: (value) {
                          setState(() {
                            _filterPatient = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Expanded(child: const Divider(thickness: 5)),
                        const SizedBox(width: 4),
                        TextButton.icon(
                          icon:
                              _sortOption == _SortDrugPrescriptionOptions.nodAsc
                              ? const Icon(Icons.arrow_upward)
                              : const Icon(Icons.arrow_downward),
                          label: Text("Số ngày theo dõi"),
                          onPressed: () {
                            setState(() {
                              _sortOption =
                                  _sortOption ==
                                      _SortDrugPrescriptionOptions.nodAsc
                                  ? _SortDrugPrescriptionOptions.nodDesc
                                  : _SortDrugPrescriptionOptions.nodAsc;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (isEmptyAll) ...[
                    Center(
                      child: Text(
                        "Không tìm thấy danh sách thuốc",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 30),
                      itemCount: dpList.length,
                      itemBuilder: (context, index) {
                        final dp = dpList[index];

                        // Initialize if not present
                        dpCheckedMap.putIfAbsent(
                          dp.id ?? index.toString(),
                          () => List.filled(dp.items.length, false),
                        );
                        return DrugPrescriptionCheckBoxWidget(
                          key: ValueKey(dpList[index].id),
                          drugPrescription: dpList[index],
                          timeOfDay: widget.timeOfDay,

                          checkedList: dpCheckedMap[dp.id ?? index.toString()]!,
                          onChanged: (updatedChecked) {
                            setState(() {
                              dpCheckedMap[dp.id ?? index.toString()] =
                                  List.from(updatedChecked);
                            });
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DrugPrescriptionCheckBoxWidget extends StatelessWidget {
  final DrugPrescription drugPrescription;
  final TimeOfDayValues timeOfDay;
  final List<bool> checkedList;
  final ValueChanged<List<bool>> onChanged;

  late final List<DrugPrescriptionItem> dpItems;

  DrugPrescriptionCheckBoxWidget({
    super.key,
    required this.drugPrescription,
    required this.timeOfDay,
    required this.checkedList,
    required this.onChanged,
  }) {
    dpItems = drugPrescription.items
        .where((dpItem) => dpItem.timeOfDay == timeOfDay)
        .toList();
  }

  bool? get parentValue {
    if (checkedList.every((c) => c)) return true;
    if (checkedList.every((c) => !c)) return false;
    return null;
  }

  void toggleParent(bool? value) {
    onChanged(List.filled(checkedList.length, value ?? false));
  }

  void toggleChild(int index, bool? value) {
    final newList = List<bool>.from(checkedList);
    newList[index] = value ?? false;
    onChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    if (dpItems.isEmpty) return const SizedBox.shrink();

    final numberOfDay = DateTime.now()
        .difference(drugPrescription.activeDate!)
        .inDays;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            tristate: true,
            dense: true,
            isThreeLine: true,
            title: Text(
              drugPrescription.customName ?? "",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text:
                        "của ${drugPrescription.patient!.name!} - ${drugPrescription.patient!.year!}",
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  TextSpan(text: "\nĐã theo dõi được "),
                  TextSpan(
                    text: "$numberOfDay ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: "ngày."),
                ],
              ),
            ),
            value: parentValue,
            onChanged: toggleParent,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Column(
              children: List.generate(dpItems.length, (index) {
                final dpItem = dpItems[index];
                final drugManager = context.read<DrugManager>();
                final Drug? drug = dpItem.drugId == null
                    ? null
                    : drugManager.searchDrugMetadataById(dpItem.drugId!);

                return GestureDetector(
                  onLongPress: () {
                    if (drug == null) return;
                    Navigator.of(context).pushNamed(
                      DrugDetailsScreen.routeName,
                      arguments: dpItem.drugId,
                    );
                  },
                  child: CheckboxListTile(
                    title: Text(dpItem.drugName),
                    subtitle: Text(
                      "${formatDoubleNumberToString(dpItem.quantity!)} ${dpItem.measurement}",
                    ),
                    secondary: drug != null
                        ? SizedBox(
                            width: 60,
                            height: 45,
                            child: Image.network(
                              drug.getImage(),
                              fit: BoxFit.fill,
                            ),
                          )
                        : SizedBox(width: 60, height: 45),
                    value: checkedList[index],
                    onChanged: (value) => toggleChild(index, value),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
