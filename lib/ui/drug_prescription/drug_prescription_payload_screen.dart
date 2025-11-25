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
          if (isEmptyAll) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Danh sách thuốc buổi ${widget.timeOfDay.toDisplayString().toLowerCase()}",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Expanded(
                    child: Center(
                      child: Text("Không tìm thấy danh sách thuốc"),
                    ),
                  ),
                ],
              ),
            );
          }
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
                  const SizedBox(height: 20),

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
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 30),
                    itemCount: dpList.length,
                    itemBuilder: (context, index) {
                      return DrugPrescriptionCheckBoxWidget(
                        drugPrescription: dpList[index],
                        timeOfDay: widget.timeOfDay,
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "💡 Tips: Nhấn giữ để xem thông tin thuốc",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DrugPrescriptionCheckBoxWidget extends StatefulWidget {
  DrugPrescriptionCheckBoxWidget({
    super.key,
    required this.drugPrescription,
    required this.timeOfDay,
  }) : dpItems = drugPrescription.items
           .where((dpItem) => dpItem.timeOfDay == timeOfDay)
           .toList();
  final DrugPrescription drugPrescription;
  final TimeOfDayValues timeOfDay;
  late final List<DrugPrescriptionItem> dpItems;

  @override
  State<DrugPrescriptionCheckBoxWidget> createState() =>
      _DrugPrescriptionCheckBoxWidgetState();
}

class _DrugPrescriptionCheckBoxWidgetState
    extends State<DrugPrescriptionCheckBoxWidget> {
  late List<bool> dpItemsChecked;

  @override
  void initState() {
    super.initState();
    dpItemsChecked = List.filled(widget.dpItems.length, false);
  }

  bool? get parentValue {
    if (dpItemsChecked.every((c) => c)) return true;
    if (dpItemsChecked.every((c) => !c)) return false;
    return null; // mixed state
  }

  void toggleParent(bool? value) {
    setState(() {
      dpItemsChecked = List.filled(dpItemsChecked.length, value ?? false);
    });
  }

  void toggleChild(int index, bool? value) {
    setState(() {
      dpItemsChecked[index] = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dpItems.isEmpty) return const SizedBox.shrink();

    final numberOfDay = DateTime.now()
        .difference(widget.drugPrescription.activeDate!)
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
              widget.drugPrescription.customName!,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text:
                        "của ${widget.drugPrescription.patient!.name!} - ${widget.drugPrescription.patient!.year!}",
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
              children: [
                for (int index = 0; index < widget.dpItems.length; index++)
                  Builder(
                    builder: (context) {
                      final dpItem = widget.dpItems[index];
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
                          title: Text(
                            dpItem.drugName,
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: dpItemsChecked[index]
                                      ? Colors.white
                                      : null,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          visualDensity: VisualDensity.compact,
                          subtitle: Text(
                            "${formatDoubleNumberToString(dpItem.quantity!)} ${dpItem.measurement}",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: dpItemsChecked[index]
                                      ? Colors.white
                                      : null,
                                ),
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
                              : SizedBox(
                                  width: 60,
                                  height: 45,
                                  child: Container(),
                                ),
                          value: dpItemsChecked[index],
                          onChanged: (value) {
                            toggleChild(index, value);
                          },
                          selectedTileColor: Colors.blue.shade800,
                          selected: dpItemsChecked[index],
                          fillColor: WidgetStateProperty.resolveWith<Color>((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.green;
                            }
                            return Colors.transparent;
                          }),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
