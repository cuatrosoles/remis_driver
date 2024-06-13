import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

///import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/model/AdditionalFeesList.dart';
import 'package:taxi_driver/model/UserDetailModel.dart';
import 'package:taxi_driver/network/RestApis.dart';
import 'package:taxi_driver/utils/Colors.dart';
import 'package:taxi_driver/utils/Extensions/AppButtonWidget.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/utils/Extensions/app_common.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_textfield.dart';

class VehicleScreen extends StatefulWidget {
  @override
  VehicleScreenState createState() => VehicleScreenState();
}

List adicionalesActuales = [];

class VehicleScreenState extends State<VehicleScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController carModelController = TextEditingController();
  TextEditingController carColorController = TextEditingController();
  TextEditingController carPlateNumberController = TextEditingController();
  TextEditingController carProductionYearController = TextEditingController();
  TextEditingController vehicleService = TextEditingController();

  UserDetail userDetail = UserDetail();

  ///List<AdditionalFeesModel> adicionalesActuales = [];
  List listAdicionales = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    await getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
      userDetail = value.data!.userDetail!;
      carModelController.text = userDetail.carModel.validate();
      carColorController.text = userDetail.carColor.validate();
      carPlateNumberController.text = userDetail.carPlateNumber.validate();
      carProductionYearController.text =
          userDetail.carProductionYear.validate();
      vehicleService.text = value.data!.driverService!.name.validate();
      adicionalesActuales = jsonDecode(value.data!.listAdicionales!);
      appStore.setLoading(false);
      setState(() {});
      ////print('ADICIONALES ACTUALES DEL DRIVER: $adicionalesActuales');
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
    /////////////// agregar cargos adicionales  /////////////////
    await getAdditionalFees().then((value) {
      for (int i = 0; i < value.data!.length; i++) {
        ////print(value.data![i].title);
        listAdicionales
            .add({"id": value.data![i].id, "title": value.data![i].title});
      }
      setState(() {});
      print('Todos los Adicionales: $listAdicionales');
    }).catchError((error) {
      log(error.toString());
    });
    ///////////////////////////////////////////////////////////////
  }

  Future<void> updateVehicle() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setLoading(true);
      updateVehicleDetail(
        carColor: carColorController.text.trim(),
        carModel: carModelController.text.trim(),
        carPlateNumber: carPlateNumberController.text.trim(),
        carProduction: carProductionYearController.text.trim(),
      ).then((value) {
        appStore.setLoading(false);

        Navigator.pop(context);
        toast(language.vehicleInfoUpdateSucessfully);
      }).catchError((error) {
        appStore.setLoading(false);
        log(error.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    print('Adicionales Acuales en Scafold: $adicionalesActuales');
    return Scaffold(
      appBar: AppBar(
        title: Text(language.vehicleInfo,
            style: boldTextStyle(color: appTextPrimaryColorWhite)),
      ),
      body: Form(
        key: formKey,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  AppTextField(
                    controller: vehicleService,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.thisFieldRequired,
                    readOnly: true,
                    decoration:
                        inputDecoration(context, label: language.serviceInfo),
                    onTap: () {
                      toast(language.youCannotChangeService);
                    },
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: carModelController,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration:
                        inputDecoration(context, label: language.carModel),
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: carColorController,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration:
                        inputDecoration(context, label: language.carColor),
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: carPlateNumberController,
                    textFieldType: TextFieldType.NAME,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration: inputDecoration(context,
                        label: language.carPlateNumber),
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: carProductionYearController,
                    textFieldType: TextFieldType.PHONE,
                    errorThisFieldRequired: language.thisFieldRequired,
                    decoration: inputDecoration(context,
                        label: language.carProductionYear),
                  ),
                  SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.fromLTRB(1, 4, 1, 4),
                    decoration: BoxDecoration(
                        border: Border.all(color: dividerColor),
                        borderRadius: BorderRadius.circular(defaultRadius)),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Adicionales que Acepta',
                            style: secondaryTextStyle(size: 12)),
                        SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: EdgeInsets.all(0),
                                margin: EdgeInsets.all(0),
                                width: 295,
                                height: 150,
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius)),
                                child: ListView(
                                  padding: EdgeInsets.all(0),
                                  physics: ClampingScrollPhysics(),
                                  //children: listAdicionales.map((e) {
                                  children: listAdicionales.map((e) {
                                    var nuevoAdicActuales = adicionalesActuales;
                                    return Container(
                                      padding: EdgeInsets.all(0),
                                      width: 300,
                                      height: 30,
                                      child: Exercise(
                                        id: (e['id']).toString(),
                                        title: e['title'],
                                      ),
                                    );
                                  }).toList(),
                                )),
                            SizedBox(width: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Observer(builder: (context) {
              return Visibility(
                visible: appStore.isLoading,
                child: loaderWidget(),
              );
            })
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: AppButtonWidget(
          text: language.updateVehicle,
          color: primaryColor,
          textStyle: boldTextStyle(color: Colors.white),
          onTap: () {
            updateVehicle();
          },
        ),
      ),
    );
  }
}

class Exercise extends StatefulWidget {
  final String title;
  final String id;

  Exercise({required this.id, required this.title});

  @override
  _ExerciseState createState() => _ExerciseState();
}

List selectedAdditional = [];

class _ExerciseState extends State<Exercise> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    ///List adicionales_actuales = adicionalesActuales;
    ///int encontrado = adicionales_actuales.indexWhere((id) => id == widget.id);
    ///bool selected = encontrado == 1 ? true : false;

    ///bool selected = widget.id == adicionales_actuales ? true : false;
    /// print('Adicionales Actuales en Exercise: $adicionales_actuales');

    return ListTile(
      title: Text(widget.title),
      trailing: Checkbox(
          value: selected,
          onChanged: (val) {
            setState(() {
              selected = val!;

              if (selected == true) {
                selectedAdditional.add(widget.id);
              } else {
                selectedAdditional.remove(widget.id);
              }

              print('Adicionales Seleccionados: $selectedAdditional');
            });
          }),
    );
  }
}
