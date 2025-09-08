import 'package:collection/collection.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:uuid/uuid.dart';

class DrugPrescriptionEditScreen extends StatefulWidget {
  static const routeName = '/drug_prescription_edit_screen';
  DrugPrescriptionEditScreen(DrugPrescription? drugPrescription, {super.key})
    : drugPrescription =
          drugPrescription ?? DrugPrescription(id: '', deviceId: '', items: []);

  late final DrugPrescription drugPrescription;

  @override
  State<DrugPrescriptionEditScreen> createState() =>
      _DrugPrescriptionEditScreenState();
}

class _DrugPrescriptionEditScreenState
    extends State<DrugPrescriptionEditScreen> {
  late DrugPrescription drugPrescription;
  final _formKey = GlobalKey<FormState>();
  var uuid = Uuid();
  Map<String, List<DrugPrescriptionItem>> _groupedItemsByDrugName = {};

  @override
  void initState() {
    super.initState();
    drugPrescription = widget.drugPrescription.copyWith();
    if (drugPrescription.items.isEmpty) {
      drugPrescription.items.add(
        DrugPrescriptionItem(
          id: uuid.v4(),
          drugName: 'efd',
          timeOfDay: TimeOfDayValues.morning,
        ),
      );
      drugPrescription.items.add(
        DrugPrescriptionItem(
          id: uuid.v4(),
          drugName: 'abc',
          timeOfDay: TimeOfDayValues.noon,
        ),
      );
    }
    _groupItems();
  }

  void _groupItems() {
    _groupedItemsByDrugName = groupBy(
      drugPrescription.items,
      (item) => item.drugName,
    );
  }

  void _addDPItem(String drugName, TimeOfDayValues timeOfDay) {
    setState(() {
      drugPrescription = drugPrescription.copyWith(
        items: [
          ...drugPrescription.items,
          DrugPrescriptionItem(
            id: uuid.v4(),
            drugName: drugName,
            timeOfDay: timeOfDay,
          ),
        ],
      );
      _groupItems();
    });
  }

  void _removeDPItem(DrugPrescriptionItem item, {bool isRemoveAll = false}) {
    setState(() {
      final itemCount = _groupedItemsByDrugName[item.drugName]!.length;
      if (itemCount == 1 && !isRemoveAll) {
        return;
      }
      drugPrescription.items.remove(item);
      _groupItems();
    });
  }

  void _renameDPItem(String value, List<DrugPrescriptionItem> changedItems) {
    setState(() {
      for (var changedItem in changedItems) {
        final itemId = changedItem.id;
        final itemIndex = drugPrescription.items.indexWhere(
          (item) => item.id == itemId,
        );
        if (itemIndex != -1) {
          drugPrescription = drugPrescription.copyWith(
            items: [
              ...drugPrescription.items.sublist(0, itemIndex),
              drugPrescription.items[itemIndex].copyWith(drugName: value),
              ...drugPrescription.items.sublist(itemIndex + 1),
            ],
          );
        }
      }
      _groupItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 4.0,
        title: const Text("Quản lý toa thuốc - Chỉnh sửa"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Text(
                "Thông tin toa thuốc",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {
                  var logger = Logger();
                  for (var item in drugPrescription.items) {
                    logger.i(item.toJson());
                  }
                },
                child: const Text("DEMO"),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tên ghi nhớ (có thể bỏ trống)',
                ),
                onChanged: (value) {
                  setState(() {
                    drugPrescription = drugPrescription.copyWith(
                      customName: value,
                    );
                  });
                },
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              ListView.separated(
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _groupedItemsByDrugName.length,
                itemBuilder: (context, index) {
                  final groupItems = _groupedItemsByDrugName.values
                      .toList()[index];
                  return DrugPrescriptionItemWidget(
                    items: groupItems,
                    onDrugNameChange: (value, changedItems) {
                      _renameDPItem(value, changedItems);
                    },
                    onTimeCheckedChange: (value, item, drugName, time) {
                      if (item == null) {
                        _addDPItem(drugName, time);
                      } else {
                        _removeDPItem(item);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrugPrescriptionItemWidget extends StatefulWidget {
  const DrugPrescriptionItemWidget({
    super.key,
    required this.items,
    required this.onDrugNameChange,
    // required this.onRemove,
    required this.onTimeCheckedChange,
  });

  final List<DrugPrescriptionItem> items;
  final void Function(String value, List<DrugPrescriptionItem> items)
  onDrugNameChange;
  // final void Function(String drugName, TimeOfDayValues timeOfDay) onRemove;

  final void Function(
    bool? value,
    DrugPrescriptionItem? item,
    String drugName,
    TimeOfDayValues time,
  )
  onTimeCheckedChange;

  @override
  State<DrugPrescriptionItemWidget> createState() =>
      _DrugPrescriptionItemWidgetState();
}

class _DrugPrescriptionItemWidgetState
    extends State<DrugPrescriptionItemWidget> {
  @override
  Widget build(BuildContext context) {
    final drugName = widget.items[0].drugName;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: drugName,
              decoration: InputDecoration(
                labelText: 'Tên thuốc',
                hintText: 'Nhập tên thuốc',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                fillColor: Colors.transparent,
              ),
              onChanged: (value) {
                widget.onDrugNameChange(value, widget.items);
              },
            ),
            const SizedBox(height: 16.0),
            Column(
              children: [
                ...TimeOfDayValues.values.map((time) {
                  final item = widget.items.firstWhereOrNull(
                    (item) => item.timeOfDay == time,
                  );
                  return CheckboxListTile(
                    title: Text(time.name),
                    value: item != null,
                    onChanged: (value) {
                      widget.onTimeCheckedChange(value, item, drugName, time);
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
