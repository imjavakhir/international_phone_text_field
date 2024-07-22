import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:international_phone_text_field/src/controller/phone_controller_bloc.dart';
import 'package:international_phone_text_field/src/entity/country_code_entity.dart';
import 'package:international_phone_text_field/src/utils/bottomsheet.dart';
import 'package:international_phone_text_field/src/utils/code_part_widget.dart';
import 'package:international_phone_text_field/src/utils/country_title_widget.dart';
import 'package:international_phone_text_field/src/utils/format_util.dart';

class InternationalPhoneTextField extends StatefulWidget {
  /// Divider color between code and phone number
  /// Default is Colors.black12
  final Color dividerColor;

  /// Cursor color of the phone number field
  /// Default is Colors.black
  final Color cursorColor;

  /// Not found country message to show when country is not selected
  /// Default is "Country"
  final String notFoundCountryMessage;

  /// Not found number message to show when phone number is not selected
  /// Default is "Your phone number"
  final String notFoundNumberMessage;

  /// Auto focus for the phone number field
  /// Default is false
  final bool autoFocus;

  /// Text style for the phone number field
  /// Default is TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black)
  final TextStyle style;

  /// Hint text style for the phone number field
  /// Default is TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black26)
  final TextStyle hintStyle;

  /// On change callback for the phone number field
  /// Required
  /// It will return the full phone number with country code
  final Function(String number) onChanged;

  /// On country selected callback
  /// It will return the selected country code
  final Function(CountryCodes selectedCountryCode)? onCountrySelected;

  /// There is two type of view for the phone number field
  /// If inOneLine is true, it will show in one line phone number field
  /// If inOneLine is false, it will show in two lines phone number field
  /// Default is false
  final bool inOneLine;

  /// Decoration for the phone number field
  final BoxDecoration? decoration;

  InternationalPhoneTextField({
    Key? key,
    this.autoFocus = false,
    this.style = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
    this.hintStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black26),
    required this.onChanged,
    this.onCountrySelected,
    this.cursorColor = Colors.black,
    this.notFoundCountryMessage = "Country",
    this.notFoundNumberMessage = "__-___-__-__",
    this.dividerColor = Colors.black12,
    this.inOneLine = false,
    this.decoration,
  }) : super(key: key);

  @override
  State<InternationalPhoneTextField> createState() => _InternationalPhoneTextFieldState();
}

class _InternationalPhoneTextFieldState extends State<InternationalPhoneTextField> {
  final TextEditingController phoneController = TextEditingController(text: nonWidthSpace);
  final TextEditingController codeController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();
  List<TextInputFormatter> formatter = [];
  late final PhoneControllerBloc controllerBloc;

  @override
  void initState() {
    super.initState();
    codeController.text = "998";
    controllerBloc = PhoneControllerBloc()..add(LoadCountryCodesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: controllerBloc,
      child: BlocConsumer<PhoneControllerBloc, PhoneControllerState>(
        listener: (context, state) {
          /// change state for phone code finder
          if (state.findStatus.isSuccess) {
            if (state.selectedCountryCode.isNotEmpty()) {
              phoneController.text = nonWidthSpace;
              _phoneFocusNode.requestFocus();
              codeController.text = state.selectedCountryCode.internalPhoneCode;
              if (widget.onCountrySelected != null) {
                widget.onCountrySelected!(state.selectedCountryCode);
              }
            }
          }

          /// change state for country selection
          if (state.selectionStatus.isSuccess) {
            codeController.text = state.selectedCountryCode.internalPhoneCode;
            phoneController.text = nonWidthSpace;
            _phoneFocusNode.requestFocus();
            if (widget.onCountrySelected != null) {
              widget.onCountrySelected!(state.selectedCountryCode);
            }
          }

          /// Clear cached formatter
          if (state.selectedCountryCode.isNotEmpty()) {
            if (state.selectedCountryCode.isNotEmpty()) {
              formatter = [
                LengthLimitingTextInputFormatter(state.selectedCountryCode.phoneMask.length),
                phoneFormatter(mask: state.selectedCountryCode.phoneMask),
              ];
            }
          } else {
            formatter = [];
          }
        },
        builder: (_, state) {
          return Container(
            decoration: widget.inOneLine
                ? widget.decoration ??
                    BoxDecoration(
                      color: (_phoneFocusNode.hasFocus || _codeFocusNode.hasFocus) ? Colors.white : Color(0xffF5F9FA),
                      border: Border.all(
                        color: (_phoneFocusNode.hasFocus || _codeFocusNode.hasFocus)
                            ? Color(0xff077E94)
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    )
                : null,
            child: Column(
              children: [
                /// If inOneLine is true, show only phone field
                // if (!widget.inOneLine) ...[
                //   CountryTitle(
                //     state: state,
                //     onTap: () {
                //       showCountryList(
                //         controllerBloc,
                //       );
                //     },
                //     inOneLine: widget.inOneLine,
                //     notFoundCountryMessage: widget.notFoundCountryMessage,
                //   ),
                //   SizedBox(height: 12),
                //   Divider(
                //     color: widget.dividerColor,
                //     height: 0,
                //   )
                // ],
                Row(
                  children: [
                    if (widget.inOneLine) ...[
                      CountryTitle(
                        state: state,
                        onTap: () {
                          // showCountryList(
                          //   controllerBloc,
                          // );
                        },
                        inOneLine: widget.inOneLine,
                        notFoundCountryMessage: widget.notFoundCountryMessage,
                      ),
                    ],
                    CodePartWidget(
                      widget: widget,
                      codeController: codeController,
                      codeFocusNode: _codeFocusNode,
                      controllerBloc: controllerBloc,
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.phone,
                            controller: phoneController,
                            focusNode: _phoneFocusNode,
                            maxLines: 1,
                            maxLength: 20,
                            autofocus: true,
                            inputFormatters: formatter,
                            style: widget.style,
                            cursorColor: widget.cursorColor,
                            cursorHeight: 18,
                            decoration: InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                            ),
                            onChanged: (String text) {
                              if (text.isEmpty) {
                                _codeFocusNode.requestFocus();
                              } else if (!state.selectedCountryCode.isNotEmpty()) {
                                controllerBloc.add(FindCountryCode(code: text));
                              } else {
                                controllerBloc.add(AdditionalFinder(code: text));
                              }

                              var actualText = phoneFormatter(mask: state.selectedCountryCode.phoneMask)
                                  .unmaskText(text.replaceAll(nonWidthSpace, ""));
                              widget.onChanged("+${state.selectedCountryCode.internalPhoneCode}${actualText}");
                            },
                            onTap: () {
                              if (phoneController.text.isEmpty) {
                                phoneController.text = nonWidthSpace;
                              }
                            },
                          ),

                          /// This is a hint text field to show the mask of the phone number
                          IgnorePointer(
                            child: ValueListenableBuilder(
                              valueListenable: phoneController,
                              builder: (_, value, child) {
                                final hintController = TextEditingController();
                                if (state.selectedCountryCode.isNotEmpty()) {
                                  var phoneLength = value.text.replaceAll(nonWidthSpace, "").length;
                                  var actualText = phoneFormatter(mask: state.selectedCountryCode.phoneMask)
                                      .unmaskText(value.text.replaceAll(nonWidthSpace, ""));
                                  String maskFull = List.generate(
                                          state.selectedCountryCode.phoneMask.length - phoneLength, (index) => "0")
                                      .toString()
                                      .replaceAll("[", "")
                                      .replaceAll("]", "")
                                      .replaceAll(",", "")
                                      .replaceAll(" ", "");

                                  final actualMaskText = actualText + maskFull;

                                  var finalMaskText =
                                      phoneFormatter(mask: state.selectedCountryCode.phoneMask).maskText(
                                    actualMaskText,
                                  );
                                  hintController.text = finalMaskText;
                                } else if (value.text.replaceAll(nonWidthSpace, "").isNotEmpty) {
                                  hintController.text = value.text;
                                }
                                return TextField(
                                  style: widget.hintStyle,
                                  controller: hintController,
                                  decoration: InputDecoration(
                                    enabled: false,
                                    counterText: "",
                                    hintText: widget.notFoundNumberMessage,
                                    hintStyle: widget.hintStyle,
                                    border: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  dispose() {
    phoneController.dispose();
    codeController.dispose();
    _phoneFocusNode.dispose();
    _codeFocusNode.dispose();
    controllerBloc.close();
    super.dispose();
  }

  void showCountryList(PhoneControllerBloc bloc) async {
    return await showModalBottomSheet(
      isDismissible: true,
      enableDrag: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (ctx) => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BlocProvider.value(
          value: bloc,
          child: CountriesBottomSheet(),
        ),
      ),
    );
  }
}
