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
  Patient? _filterPatient;

  final _filterPatientTextController = TextEditingController();

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
      body: SingleChildScrollView(
        child: Consumer<DrugPrescriptionManager>(
          builder: (context, manager, child) {
            final dpList = manager.drugPrescriptions
                .where((dp) => dp.isActive)
                .where((dp) {
                  if (_filterPatient == null) return true;
                  return dp.patient!.id == _filterPatient?.id;
                })
                .toList();
            final isEmptyAll = dpList.every(
              (dp) => dp.items
                  .where((dpItem) => dpItem.timeOfDay == widget.timeOfDay)
                  .toList()
                  .isEmpty,
            );
            return Padding(
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
                      return TextField(
                        controller: _filterPatientTextController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Người bệnh',
                          suffixIcon: Icon(Icons.person),
                        ),

                        onTap: () async {
                          _filterPatient = await showFilterByPatientDialog(
                            context,
                            patientManager.patients,
                          );
                          if (_filterPatient == null) {
                            // All is selected
                            _filterPatientTextController.text = 'Tất cả';
                          } else {
                            _filterPatientTextController.text =
                                _filterPatient!.name!;
                          }
                          setState(() {});
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Divider(thickness: 5, indent: 40, endIndent: 40),
                  const SizedBox(height: 12),
                  if (isEmptyAll) ...[
                    Text(
                      "Không tìm thấy danh sách thuốc",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
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
                ],
              ),
            );
          },
        ),
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

    return Column(
      children: [
        CheckboxListTile(
          tristate: true,
          dense: true,
          title: Text(
            widget.drugPrescription.customName!,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            "của ${widget.drugPrescription.patient!.name!} - ${widget.drugPrescription.patient!.year!}",
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
    );
  }
}
