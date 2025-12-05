import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:collection/collection.dart';
import 'package:drug_app/manager/drug_prescription_manager.dart';
import 'package:drug_app/manager/patient_manager.dart';
import 'package:drug_app/models/drug_prescription.dart';
import 'package:drug_app/models/drug_prescription_item.dart';
import 'package:drug_app/ui/components/medi_app_loading_dialog.dart';
import 'package:drug_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

int sortCardsByDrugNameComparator(
  DrugPrescriptionCardModel a,
  DrugPrescriptionCardModel b, {
  bool ascending = true,
}) {
  final nameA = a.drugName.trim();
  final nameB = b.drugName.trim();

  // Empty always last
  if (nameA.isEmpty && nameB.isEmpty) return 0;
  if (nameA.isEmpty) return 1;
  if (nameB.isEmpty) return -1;

  // Normal compare
  return ascending
      ? nameA.compareTo(nameB) // A–Z
      : nameB.compareTo(nameA); // Z–A
}

class DrugPrescriptionCardModel {
  final String id;
  final String drugName;
  final List<DrugPrescriptionItem> items;
  late final String? measurement;
  late final Map<TimeOfDayValues, double> dailyDosages;

  DrugPrescriptionCardModel(
    this.id,
    this.drugName,
    this.items, {
    String? measurement,
    Map<TimeOfDayValues, double>? dailyDosages,
  }) : measurement =
           measurement ?? (items.isNotEmpty ? items.first.measurement : null),
       dailyDosages =
           dailyDosages ??
           {
             for (var time in TimeOfDayValues.values)
               time:
                   items
                       .firstWhereOrNull((item) => item.timeOfDay == time)
                       ?.quantity ??
                   0,
           };

  DrugPrescriptionCardModel copyWith({
    String? id,
    String? drugName,
    List<DrugPrescriptionItem>? items,
    String? measurement,
    Map<TimeOfDayValues, double>? dailyDosages,
  }) {
    return DrugPrescriptionCardModel(
      id ?? this.id,
      drugName ?? this.drugName,
      items ?? this.items,
      measurement: measurement ?? this.measurement,
      dailyDosages: dailyDosages ?? this.dailyDosages,
    );
  }
}

class DrugPrescriptionEditScreen extends StatefulWidget {
  static const routeName = '/drug_prescription_edit_screen';
  DrugPrescriptionEditScreen(DrugPrescription? drugPrescription, {super.key})
    : drugPrescription =
          drugPrescription ??
          DrugPrescription(
            id: null,
            customName: null,
            deviceId: null,
            items: [],
            isActive: true,
          );

  late final DrugPrescription drugPrescription;
  late final bool isEditState = drugPrescription.id != null;

  @override
  State<DrugPrescriptionEditScreen> createState() =>
      _DrugPrescriptionEditScreenState();
}

class _DrugPrescriptionEditScreenState
    extends State<DrugPrescriptionEditScreen> {
  late DrugPrescription drugPrescription;
  late List<DrugPrescriptionCardModel> cards = [];
  final _formKey = GlobalKey<FormState>();
  final Map<String, Map<TimeOfDayValues, TextEditingController>> _controllers =
      {};

  var uuid = Uuid();

  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  bool _isSortAscending = false;
  bool _showResetActiveDateSwitchTileWarning = false;
  bool _showResetActiveDateButtonInfo = false;

  final TextEditingController _scheduledDateController =
      TextEditingController();

  late final int? numberOfActiveDate;

  @override
  void initState() {
    super.initState();
    drugPrescription = widget.drugPrescription;
    _initCards();
    _initControllers();

    _scrollController.addListener(() {
      if (_scrollController.offset > 300) {
        if (!_showBackToTopButton) {
          setState(() => _showBackToTopButton = true);
        }
      } else {
        if (_showBackToTopButton) {
          setState(() => _showBackToTopButton = false);
        }
      }
    });

    final scheduledDate = drugPrescription.scheduledDate ?? DateTime.now();

    _scheduledDateController.text = DateFormat(
      'dd/MM/yyyy',
    ).format(scheduledDate);
    drugPrescription = drugPrescription.copyWith(scheduledDate: scheduledDate);

    // Check if it is an active dp or a new dp then set numberOfActiveDate to null
    numberOfActiveDate =
        drugPrescription.isActive && drugPrescription.id != null
        ? DateTime.now().difference(drugPrescription.activeDate!).inDays
        : null;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      for (final value in controller.values) {
        value.dispose();
      }
    }
    _scheduledDateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, List<DrugPrescriptionItem>> groupDPByName() {
    Map<String, List<DrugPrescriptionItem>> groupItems = groupBy(
      drugPrescription.items,
      (item) => item.drugName,
    );
    return groupItems;
  }

  void _initCards() {
    final groupItems = groupDPByName();
    groupItems.forEach((drugName, dpItems) {
      String id = uuid.v4();
      DrugPrescriptionCardModel cardModel = DrugPrescriptionCardModel(
        id,
        drugName,
        dpItems,
      );
      cards.add(cardModel);
    });
    _resortCards();

    // Add a card if empty
    if (cards.isEmpty) {
      _addNewCard();
    }
  }

  void _initControllers() {
    for (final card in cards) {
      _controllers[card.id] = {};
      for (var time in TimeOfDayValues.values) {
        _controllers[card.id]![time] = TextEditingController(
          text: formatDoubleNumberToString(card.dailyDosages[time] ?? 0),
        );
      }
    }
  }

  void _addNewCard() {
    setState(() {
      String id = uuid.v4();
      DrugPrescriptionCardModel cardModel = DrugPrescriptionCardModel(
        id,
        '',
        [],
        measurement: 'viên',
      );
      cards.add(cardModel);
      _controllers[id] = {};
      for (var time in TimeOfDayValues.values) {
        _controllers[id]![time] = TextEditingController(text: '0');
      }
    });
  }

  void _removeCard(String id) {
    if (cards.length == 1) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.scale,
        title: 'Xóa thuốc thất bại',
        desc: 'Toa thuốc phải có ít nhất 1 thuốc',
        btnOkOnPress: () {},
        btnOkIcon: Icons.check_circle,
        btnCancel: null,
        btnOkText: 'OK',
      ).show();
      return;
    }
    setState(() {
      cards.removeWhere((card) => card.id == id);
      _controllers.remove(id);
    });
  }

  DrugPrescription? _onSaveForm() {
    // Convert to drug prescription item from card model
    List<DrugPrescriptionItem> dpItems = [];
    for (final card in cards) {
      // If all quanity of time is 0.0, return null
      if (card.dailyDosages.values.every((quantity) => quantity == 0.0)) {
        return null;
      }

      for (var time in TimeOfDayValues.values) {
        final quantity = double.tryParse(_controllers[card.id]![time]!.text);
        if (quantity == null || quantity == 0.0) continue;
        dpItems.add(
          DrugPrescriptionItem(
            id: card.items
                .firstWhereOrNull((item) => item.timeOfDay == time)
                ?.id,
            drugName: card.drugName,
            timeOfDay: time,
            quantity: quantity,
            measurement: card.measurement,
          ),
        );
      }
    }

    if (dpItems.isEmpty) {
      return null;
    }

    final formatter = DateFormat('HH:mm:ss-dd/MM/yyyy');
    final generatedCustomName =
        'Toa thuốc ${formatter.format(DateTime.now().toLocal())}';

    late final String? customName;
    if (drugPrescription.customName == null ||
        drugPrescription.customName!.isEmpty) {
      customName = generatedCustomName;
    } else {
      customName = drugPrescription.customName;
    }

    if (drugPrescription.isActive && !widget.drugPrescription.isActive ||
        drugPrescription.id == null) {
      drugPrescription = drugPrescription.copyWith(activeDate: DateTime.now());
    }

    final DrugPrescription dp = DrugPrescription(
      id: drugPrescription.id,
      customName: customName,
      deviceId: drugPrescription.deviceId,
      items: dpItems,
      isActive: drugPrescription.isActive,
      patient: drugPrescription.patient,
      diagnosis: drugPrescription.diagnosis,
      doctorName: drugPrescription.doctorName,
      scheduledDate: drugPrescription.scheduledDate,
      activeDate: drugPrescription.activeDate,
    );

    return dp;
  }

  void _resortCards() {
    _isSortAscending = !_isSortAscending;
    setState(() {
      cards.sort(
        (a, b) =>
            sortCardsByDrugNameComparator(a, b, ascending: _isSortAscending),
      );
    });
  }

  void _showScheduledDatePicker() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      currentTime: DateFormat(
        "dd/MM/yyyy",
      ).parse(_scheduledDateController.text),
      locale: LocaleType.vi,
      onConfirm: (date) {
        setState(() {
          _scheduledDateController.text = DateFormat('dd/MM/yyyy').format(date);
          drugPrescription = drugPrescription.copyWith(scheduledDate: date);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 4.0,
        title: widget.isEditState
            ? Text("Chỉnh sửa toa thuốc")
            : Text("Thêm toa thuốc"),
        actions: [
          Consumer<DrugPrescriptionManager>(
            builder: (context, drugDPManager, child) {
              return IconButton(
                icon: Icon(Icons.save_outlined),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final dp = _onSaveForm();

                    if (dp == null) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.scale,
                        title: 'Lỗi nhập liệu',
                        desc: 'Vui lòng nhập đúng thông tin toa thuốc.',
                        btnOkOnPress: () {},
                        btnOkIcon: Icons.check_circle,
                        btnCancel: null,
                        btnOkText: 'OK',
                      ).show();
                      return;
                    }

                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return const MediAppLoadingDialog();
                      },
                    );

                    if (widget.isEditState) {
                      await drugDPManager.updateDrugPrescription(dp);
                    } else {
                      await drugDPManager.addDrugPrescription(dp);
                    }

                    if (context.mounted) {
                      Navigator.of(context).pop();

                      if (drugDPManager.hasError) {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.scale,
                          headerAnimationLoop: false,
                          title: "Lỗi kết nối",
                          desc: drugDPManager.errorMessage,
                          btnOkText: "OK",
                          btnOkOnPress: () {},
                          btnOkColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          onDismissCallback: (type) {
                            return;
                          },
                        ).show();
                        drugDPManager.clearError();
                        return;
                      }

                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.success,
                        animType: AnimType.scale,
                        title: 'Lưu toa thuốc thành công',
                        btnOkOnPress: () {
                          Navigator.of(context).pop();
                        },
                        onDismissCallback: (type) {
                          if (type != DismissType.btnOk) {
                            Navigator.of(context).pop();
                          }
                        },
                        btnOkIcon: Icons.check_circle,
                        btnCancel: null,
                        btnOkText: 'OK',
                      ).show();
                    }
                  } else {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.scale,
                      title: 'Lỗi khi lưu toa thuốc',
                      desc: 'Vui lòng nhập thông tin toa thuốc.',
                      btnOkOnPress: () {},
                      btnOkIcon: Icons.check_circle,
                      btnCancel: null,
                      btnOkText: 'OK',
                    ).show();
                  }
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: _showBackToTopButton
          ? ClipOval(
              child: FloatingActionButton(
                elevation: 4.0,
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Icon(Icons.arrow_upward),
              ),
            )
          : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Thông tin toa thuốc",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      dense: true,
                      secondary: const Icon(Icons.watch_later_outlined),
                      title: Text(
                        "Bật chế độ theo dõi",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      value: drugPrescription.isActive,
                      onChanged: (value) {
                        setState(() {
                          drugPrescription = drugPrescription.copyWith(
                            isActive: value,
                          );

                          // If it is a new dp, skip warning
                          if (drugPrescription.id == null) {
                            _showResetActiveDateSwitchTileWarning = false;
                            return;
                          }

                          // Old active status is true -> display warning
                          if (!drugPrescription.isActive &&
                              widget.drugPrescription.isActive) {
                            _showResetActiveDateSwitchTileWarning = true;
                          } else if (drugPrescription.isActive &&
                              widget.drugPrescription.isActive) {
                            _showResetActiveDateSwitchTileWarning = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
                if (_showResetActiveDateSwitchTileWarning) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      spacing: 5.0,
                      children: [
                        const Icon(Icons.warning_amber_outlined),
                        Expanded(
                          child: Text(
                            "Tắt chế độ theo dõi sẽ đặt lại số ngày theo dõi",
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Display reset active date button
                if (numberOfActiveDate != null) ...[
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyLarge,
                                children: [
                                  TextSpan(text: "Đã theo dõi được "),
                                  TextSpan(
                                    text: "$numberOfActiveDate",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: " ngày"),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.restore),
                              onPressed: () {
                                setState(() {
                                  {
                                    drugPrescription = drugPrescription
                                        .copyWith(activeDate: DateTime.now());
                                    _showResetActiveDateButtonInfo = true;
                                  }
                                });
                              },
                              label: Text(
                                "Đặt lại",
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (_showResetActiveDateButtonInfo) ...[
                          Row(
                            spacing: 5.0,
                            children: [
                              const Icon(Icons.info_outline),
                              Expanded(
                                child: Text(
                                  "Số ngày theo dõi sẽ được đặt lại sau khi lưu",
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 25),
                Text(
                  "Các thông tin chung",
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 20),
                Consumer<DrugPrescriptionManager>(
                  builder: (context, drugDPManager, child) {
                    return TextFormField(
                      autovalidateMode: AutovalidateMode.onUnfocus,
                      initialValue: drugPrescription.customName,
                      decoration: const InputDecoration(
                        labelText: 'Tên ghi nhớ',
                      ),
                      onChanged: (value) {
                        setState(() {
                          drugPrescription = drugPrescription.copyWith(
                            customName: value,
                          );
                        });
                      },
                      inputFormatters: [LengthLimitingTextInputFormatter(30)],
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            drugDPManager.drugPrescriptions.any((element) {
                              return element.customName == value &&
                                  element.id != widget.drugPrescription.id;
                            })) {
                          return 'Tên ghi nhớ này đã được sử dụng';
                        }
                        return null;
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),
                Consumer<PatientManager>(
                  builder: (context, patientManger, child) {
                    return DropdownMenu(
                      menuHeight: 200,
                      enableSearch: true,
                      enableFilter: true,
                      requestFocusOnTap: true,
                      width: double.infinity,
                      label: const Text("Người bệnh"),
                      initialSelection: patientManger.findPatientById(
                        drugPrescription.patient?.id,
                      ),
                      dropdownMenuEntries: [
                        ...patientManger.patients.map((patient) {
                          return DropdownMenuEntry(
                            label: patient.name!,
                            value: patient,
                            trailingIcon: drugPrescription.patient == patient
                                ? const Icon(Icons.check)
                                : null,
                          );
                        }),
                      ],
                      onSelected: (value) {
                        setState(() {
                          drugPrescription = drugPrescription.copyWith(
                            patient: value,
                          );
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        " Năm sinh: ${drugPrescription.patient?.year ?? ""}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Giới tính: ${genderDisplayStringMap[drugPrescription.patient?.gender]}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 4,
                  initialValue: drugPrescription.diagnosis,
                  decoration: const InputDecoration(
                    labelText: 'Chẩn đoán bệnh',
                  ),
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                  onChanged: (value) {
                    setState(() {
                      drugPrescription = drugPrescription.copyWith(
                        diagnosis: value,
                      );
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: drugPrescription.doctorName,
                  decoration: const InputDecoration(labelText: 'Bác sĩ khám'),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  onChanged: (value) {
                    setState(() {
                      drugPrescription = drugPrescription.copyWith(
                        doctorName: value,
                      );
                    });
                  },
                ),

                const SizedBox(height: 20),
                TextFormField(
                  controller: _scheduledDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Ngày tái khám',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _showScheduledDatePicker,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn ngày tái khám';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách thuốc',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _isSortAscending ? Text("A-Z") : Text("Z-A"),
                          IconButton(
                            icon: const Icon(Icons.sort),
                            onPressed: () {
                              _resortCards();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20),
                  itemCount: cards.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildCardWidget(index);
                  },
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  label: Text("Thêm thuốc mới"),
                  icon: Icon(Icons.add_box_outlined),
                  onPressed: () {
                    _addNewCard();
                  },
                ),
                if (widget.isEditState) ...[
                  Consumer<DrugPrescriptionManager>(
                    builder: (context, drugDPManager, child) {
                      return TextButton.icon(
                        label: Text("Xóa toa thuốc"),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          iconColor: Colors.white,
                          backgroundColor: Colors.red,
                        ),
                        icon: Icon(Icons.delete_forever_outlined),
                        onPressed: () async {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.warning,
                            animType: AnimType.scale,
                            title: 'Xóa toa thuốc',
                            desc:
                                'Hành động này không thể hoàn tác.\nXóa toa thuốc này?',
                            btnOkOnPress: () async {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return const MediAppLoadingDialog();
                                },
                              );
                              if (context.mounted) {
                                await drugDPManager.deleteDrugPrescription(
                                  drugPrescription.id!,
                                );
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  if (drugDPManager.hasError) {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.scale,
                                      headerAnimationLoop: false,
                                      title: "Lỗi kết nối",
                                      desc: drugDPManager.errorMessage,
                                      btnOkText: "OK",
                                      btnOkOnPress: () {},
                                      btnOkColor: Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                      onDismissCallback: (type) {
                                        return;
                                      },
                                    ).show();
                                    drugDPManager.clearError();
                                    return;
                                  }

                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.success,
                                    animType: AnimType.scale,
                                    title: 'Xóa toa thuốc thành công',
                                    btnOkOnPress: () {
                                      Navigator.of(context).pop();
                                    },
                                    onDismissCallback: (type) {
                                      if (type != DismissType.btnOk) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    btnOkIcon: Icons.check_circle,
                                    btnCancel: null,
                                    btnOkText: 'OK',
                                  ).show();
                                }
                              }
                            },
                            btnCancelOnPress: () async {},
                            btnOkIcon: Icons.delete_forever,
                            btnOkColor: Colors.red,
                            btnOkText: 'Đồng ý',
                            btnCancelText: 'Từ chối',
                            btnCancelColor: Colors.grey,
                          ).show();
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Card _buildCardWidget(int index) {
    final card = cards[index];
    return Card(
      key: ValueKey(card.id),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                initialValue: card.drugName,
                decoration: InputDecoration(
                  labelText: 'Tên thuốc (*)',
                  hintText: 'Nhập tên thuốc',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên thuốc';
                  }
                  final duplicateCount = cards
                      .where((card) => card.drugName == value)
                      .length;

                  if (duplicateCount > 1) {
                    return 'Tên thuốc bị trùng lặp';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    cards[index] = card.copyWith(drugName: value);
                  });
                },
              ),
              Column(
                children: [
                  TextFormField(
                    initialValue: card.measurement,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Đơn vị tính (*)',
                      hintText: 'viên, mg, gói, ...',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(15)],
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập đơn vị tính';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        cards[index] = card.copyWith(measurement: value);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Số lượng uống (nhập ít nhất 1 buổi):"),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    spacing: 5.0,
                    children: [
                      ...TimeOfDayValues.values.map((time) {
                        return Expanded(
                          child: TextFormField(
                            controller: _controllers[cards[index].id]?[time],
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                              labelText: time.toDisplayString(),
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+(\.\d*)?'),
                              ),
                            ],
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                cards[index] = cards[index].copyWith(
                                  dailyDosages: {
                                    ...card.dailyDosages,
                                    time: double.tryParse(value) ?? 0.0,
                                  },
                                );
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 1.0,
            right: 1.0,
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.warning,
                  animType: AnimType.scale,
                  title: 'Xóa thuốc',
                  desc: 'Bạn có muốn xóa thuốc này?',
                  btnOkText: 'Đồng ý',
                  btnCancelText: 'Hủy',
                  btnOkOnPress: () => _removeCard(card.id),
                  btnCancelOnPress: () {},
                ).show();
              },
            ),
          ),
        ],
      ),
    );
  }
}
