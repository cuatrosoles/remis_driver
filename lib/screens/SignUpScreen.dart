import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxi_driver/Services/AuthService.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/model/AdditionalFeesList.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/utils/Extensions/context_extensions.dart';
import '../model/ServiceModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';
import 'TermsConditionScreen.dart';

class SignUpScreen extends StatefulWidget {
  final bool isOtp;
  final bool socialLogin;

  final String? countryCode;
  final String? privacyPolicyUrl;
  final String? termsConditionUrl;

  ////final String? userName;
  final String? dni_number;

  SignUpScreen(
      {this.socialLogin = false,
      ////this.userName,
      this.dni_number,
      this.isOtp = false,
      this.countryCode,
      this.privacyPolicyUrl,
      this.termsConditionUrl});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  AuthServices authService = AuthServices();

  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController firstController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dni_numberController = TextEditingController();

  ///TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController carModelController = TextEditingController();
  TextEditingController carProductionController = TextEditingController();
  TextEditingController carPlateController = TextEditingController();
  TextEditingController carColorController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode dni_numberFocus = FocusNode();

  ///FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  bool mIsCheck = false;
  bool isAcceptedTc = false;
  String countryCode = defaultCountryCode;

  int currentIndex = 0;

  List<ServiceList> listServices = [];

  ///Iterable<AdditionalFeesList> listAdicionales = [];
  List listAdicionales = [];

  int selectedService = 0;

  XFile? imageProfile;
  int radioValue = -1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (sharedPref.getString(PLAYER_ID).validate().isEmpty) {
      await saveOneSignalPlayerId().then((value) {
        //
      });
    }
    await getServices().then((value) {
      listServices.addAll(value.data!);
      print(value.data);
      setState(() {});
    }).catchError((error) {
      log(error.toString());
    });

    ///// agregar cargos adicionales
    await getAdditionalFees().then((value) {
      ///listAdicionales.addAll(value as Iterable<AdditionalFeesList>);
      for (int i = 0; i < value.data!.length; i++) {
        ////print(value.data![i].title);
        listAdicionales
            .add({"id": value.data![i].id, "title": value.data![i].title});
      }
      print(listAdicionales);
      setState(() {});
    }).catchError((error) {
      log(error.toString());
    });
    /////////////////////////////////
  }

  Future<void> register() async {
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (isAcceptedTc) {
        appStore.setLoading(true);
        Map req = {
          'first_name': firstController.text.trim(),
          'last_name': lastNameController.text.trim(),
          'dni_number': dni_numberController.text.trim(),

          ///'username': widget.socialLogin ? widget.userName : userNameController.text.trim(),
          'email': emailController.text.trim(),
          "user_type": "driver",
          "contact_number": widget.socialLogin
              ? '${widget.countryCode}'
              : '$countryCode${phoneController.text.trim()}',
          'password': widget.socialLogin
              ? firstController.text.trim()
              : passController.text.trim(),
          /*
          "contact_number": widget.socialLogin ? '${widget.countryCode}${widget.userName}' : '$countryCode${phoneController.text.trim()}',
          'password': widget.socialLogin ? widget.userName : passController.text.trim(),
          */
          "player_id": sharedPref.getString(PLAYER_ID).validate(),
          if (widget.socialLogin) 'login_type': LoginTypeOTP,
          "user_detail": {
            'car_model': carModelController.text.trim(),
            'car_color': carColorController.text.trim(),
            'car_plate_number': carPlateController.text.trim(),
            'car_production_year': carProductionController.text.trim(),
          },
          'service_id': listServices[selectedService].id,
          'list_adicionales': selectedAdditional,
        };
        print(req);

        await signUpApi(req).then((value) {
          authService
              .signUpWithEmailPassword(context,
                  mobileNumber: widget.socialLogin
                      ? '${widget.countryCode}'
                      : '$countryCode${phoneController.text.trim()}',

                  ///mobileNumber: widget.socialLogin ? '${widget.countryCode}${widget.userName}' : '$countryCode${phoneController.text.trim()}',
                  email: emailController.text.trim(),
                  fName: firstController.text.trim(),
                  lName: lastNameController.text.trim(),
                  dni_number: dni_numberController.text.trim(),

                  ///userName: widget.socialLogin ? widget.userName : userNameController.text.trim(),
                  ///password: widget.socialLogin ? widget.userName : passController.text.trim(),
                  password: widget.socialLogin
                      ? firstController.text.trim()
                      : passController.text.trim(),
                  userType: DRIVER,
                  isOtpLogin: widget.socialLogin)
              .then((res) async {
            //
          }).catchError((e) {
            appStore.setLoading(false);
            toast('$e');
          });
        }).catchError((error) {
          appStore.setLoading(false);
          toast('${error['message']}');
        });
      } else {
        toast(language.pleaseAcceptTermsOfServicePrivacyPolicy);
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(color: context.iconColor),
        title: Text(language.signUp, style: boldTextStyle()),
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: Stepper(
              currentStep: currentIndex,
              onStepCancel: () {
                if (currentIndex > 0) {
                  currentIndex--;
                  setState(() {});
                }
              },
              onStepContinue: () {
                if (formKeys[currentIndex].currentState!.validate()) {
                  if (currentIndex == 1 && listServices.isEmpty) {
                    return toast(language.pleaseSelectService);
                  } else if (currentIndex <= 5) {
                    currentIndex++;
                    setState(() {});
                  } else {
                    register();
                  }
                }
              },
              onStepTapped: (int index) {
                currentIndex = index;
                setState(() {});
              },
              steps: [
                Step(
                  isActive: currentIndex <= 0,
                  state: currentIndex <= 0
                      ? StepState.disabled
                      : StepState.complete,
                  title: Text(language.userDetail, style: boldTextStyle()),
                  content: Form(
                    key: formKeys[0],
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                textFieldType: TextFieldType.NAME,
                                controller: firstController,
                                focus: firstNameFocus,
                                nextFocus: lastNameFocus,
                                errorThisFieldRequired:
                                    language.thisFieldRequired,
                                decoration: inputDecoration(context,
                                    label: language.firstName),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                textFieldType: TextFieldType.NAME,
                                controller: lastNameController,
                                focus: lastNameFocus,
                                nextFocus: emailFocus,
                                errorThisFieldRequired:
                                    language.thisFieldRequired,
                                decoration: inputDecoration(context,
                                    label: language.lastName),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                textFieldType: TextFieldType.EMAIL,
                                focus: emailFocus,
                                controller: emailController,
                                nextFocus: dni_numberFocus,

                                ///nextFocus: userNameFocus,
                                errorThisFieldRequired:
                                    language.thisFieldRequired,
                                decoration: inputDecoration(context,
                                    label: language.email),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                textFieldType: TextFieldType.NAME,
                                focus: dni_numberFocus,
                                controller: dni_numberController,
                                nextFocus: phoneFocus,
                                errorThisFieldRequired:
                                    language.thisFieldRequired,
                                decoration:
                                    inputDecoration(context, label: 'DNI'),
                              ),
                            ),
                            /*
                            if (widget.socialLogin != true)
                              Expanded(
                                child: AppTextField(
                                  textFieldType: TextFieldType.USERNAME,
                                  focus: userNameFocus,
                                  controller: userNameController,
                                  nextFocus: phoneFocus,
                                  errorThisFieldRequired: language.thisFieldRequired,
                                  decoration: inputDecoration(context, label: language.userName),
                                ),
                              ),
                              */
                          ],
                        ),
                        if (widget.socialLogin != true) SizedBox(height: 8),
                        if (widget.socialLogin != true)
                          AppTextField(
                            controller: phoneController,
                            textFieldType: TextFieldType.PHONE,
                            focus: phoneFocus,
                            nextFocus: passFocus,
                            decoration: inputDecoration(
                              context,
                              label: language.phoneNumber,
                              prefixIcon: IntrinsicHeight(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CountryCodePicker(
                                      padding: EdgeInsets.zero,
                                      initialSelection: countryCode,
                                      showCountryOnly: false,
                                      dialogSize: Size(
                                          MediaQuery.of(context).size.width -
                                              60,
                                          MediaQuery.of(context).size.height *
                                              0.6),
                                      showFlag: true,
                                      showFlagDialog: true,
                                      showOnlyCountryWhenClosed: false,
                                      alignLeft: false,
                                      textStyle: primaryTextStyle(),
                                      dialogBackgroundColor:
                                          Theme.of(context).cardColor,
                                      barrierColor: Colors.black12,
                                      dialogTextStyle: primaryTextStyle(),
                                      searchDecoration: InputDecoration(
                                        iconColor:
                                            Theme.of(context).dividerColor,
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .dividerColor)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: primaryColor)),
                                      ),
                                      searchStyle: primaryTextStyle(),
                                      onInit: (c) {
                                        countryCode = c!.dialCode!;
                                      },
                                      onChanged: (c) {
                                        countryCode = c.dialCode!;
                                      },
                                    ),
                                    VerticalDivider(
                                        color: Colors.grey.withOpacity(0.5)),
                                  ],
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value!.trim().isEmpty)
                                return language.thisFieldRequired;
                              return null;
                            },
                          ),
                        if (widget.socialLogin != true) SizedBox(height: 8),
                        if (widget.socialLogin != true)
                          AppTextField(
                            controller: passController,
                            focus: passFocus,
                            autoFocus: false,
                            textFieldType: TextFieldType.PASSWORD,
                            errorThisFieldRequired: language.thisFieldRequired,
                            decoration: inputDecoration(context,
                                label: language.password),
                          ),
                      ],
                    ),
                  ),
                ),
                Step(
                  isActive: currentIndex <= 1,
                  state: currentIndex <= 1
                      ? StepState.disabled
                      : StepState.complete,
                  title: Text(language.selectService, style: boldTextStyle()),
                  content: Form(
                    key: formKeys[1],
                    child: listServices.isNotEmpty
                        ? Column(
                            children: listServices.map((e) {
                              return inkWellWidget(
                                onTap: () {
                                  selectedService = listServices.indexOf(e);
                                  setState(() {});
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.only(
                                      left: 16, right: 8, top: 4, bottom: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: selectedService ==
                                                listServices.indexOf(e)
                                            ? Colors.green
                                            : primaryColor.withOpacity(0.5)),
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius),
                                  ),
                                  child: Row(
                                    children: [
                                      commonCachedNetworkImage(e.serviceImage,
                                          fit: BoxFit.contain,
                                          height: 50,
                                          width: 50),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Text(e.name.validate(),
                                            style: boldTextStyle()),
                                      ),
                                      Visibility(
                                        visible: selectedService ==
                                            listServices.indexOf(e),
                                        child: Icon(Icons.check_circle_outline,
                                            color: Colors.green),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : emptyWidget(),
                  ),
                ),

                ///////// Selector Adicionales que Acepta Driver      /////////
                Step(
                  isActive: currentIndex <= 2,
                  state: currentIndex <= 2
                      ? StepState.disabled
                      : StepState.complete,
                  title: Text('Seleccione Adicionales que Acepta',
                      style: boldTextStyle()),
                  content: Form(
                      key: formKeys[2],
                      child:
                          ////listAdicionales.isNotEmpty ?
                          Column(
                        //children: listAdicionales.map((e) {
                        children: listAdicionales.map((e) {
                          return Container(
                            ///width: 420,
                            height: 60,
                            child: ListView(
                              children: <Widget>[
                                Exercise(
                                  id: (e['id']).toString(),
                                  title: e['title'],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )

                      /// : emptyWidget(),
                      ),
                ),

                /////////////////////////  Fin Selector Adicionales   /////////

                Step(
                  isActive: currentIndex <= 3,
                  state: currentIndex <= 3
                      ? StepState.disabled
                      : StepState.complete,
                  title: Text(language.carModel, style: boldTextStyle()),
                  content: Form(
                    key: formKeys[3],
                    child: AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: carModelController,
                        decoration:
                            inputDecoration(context, label: language.carModel)),
                  ),
                ),
                Step(
                  isActive: currentIndex <= 4,
                  state: currentIndex <= 4
                      ? StepState.indexed
                      : StepState.complete,
                  title:
                      Text(language.carProductionYear, style: boldTextStyle()),
                  content: Form(
                    key: formKeys[4],
                    child: AppTextField(
                        textFieldType: TextFieldType.PHONE,
                        controller: carProductionController,
                        decoration: inputDecoration(context,
                            label: language.carProductionYear)),
                  ),
                ),
                Step(
                  isActive: currentIndex <= 5,
                  state: currentIndex <= 5
                      ? StepState.disabled
                      : StepState.complete,
                  title: Text(language.carPlateNumber, style: boldTextStyle()),
                  content: Form(
                    key: formKeys[5],
                    child: AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: carPlateController,
                        decoration: inputDecoration(context,
                            label: language.carPlateNumber)),
                  ),
                ),
                Step(
                  isActive: currentIndex <= 6,
                  state: currentIndex <= 6
                      ? StepState.disabled
                      : StepState.complete,
                  title: Text(language.carColor, style: boldTextStyle()),
                  content: Form(
                    key: formKeys[6],
                    child: Column(
                      children: [
                        AppTextField(
                            textFieldType: TextFieldType.NAME,
                            controller: carColorController,
                            decoration: inputDecoration(context,
                                label: language.carColor)),
                        SizedBox(height: 8),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: primaryColor,
                          title: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: '${language.agreeToThe} ',
                                  style: secondaryTextStyle()),
                              TextSpan(
                                text: language.termsConditions,
                                style: boldTextStyle(
                                    color: primaryColor, size: 14),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (widget.termsConditionUrl != null &&
                                        widget.termsConditionUrl!.isNotEmpty) {
                                      launchScreen(
                                          context,
                                          TermsConditionScreen(
                                              title: language.termsConditions,
                                              subtitle:
                                                  widget.termsConditionUrl),
                                          pageRouteAnimation:
                                              PageRouteAnimation.Slide);
                                    } else {
                                      toast(language.txtURLEmpty);
                                    }
                                  },
                              ),
                              TextSpan(
                                  text: ' & ', style: secondaryTextStyle()),
                              TextSpan(
                                text: language.privacyPolicy,
                                style: boldTextStyle(
                                    color: primaryColor, size: 14),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (widget.privacyPolicyUrl != null &&
                                        widget.privacyPolicyUrl!.isNotEmpty) {
                                      launchScreen(
                                          context,
                                          TermsConditionScreen(
                                              title: language.privacyPolicy,
                                              subtitle:
                                                  widget.privacyPolicyUrl),
                                          pageRouteAnimation:
                                              PageRouteAnimation.Slide);
                                    } else {
                                      toast(language.txtURLEmpty);
                                    }
                                  },
                              ),
                            ]),
                            textAlign: TextAlign.left,
                          ),
                          value: isAcceptedTc,
                          onChanged: (val) async {
                            isAcceptedTc = val!;
                            setState(() {});
                          },
                        ),
                      ],
                    ),
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

              ///print(selectedAdditional);
            });
          }),
    );
  }
}
