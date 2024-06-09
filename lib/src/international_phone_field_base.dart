import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:international_phone_field/src/controller/phone_controller_bloc.dart';
import 'package:international_phone_field/src/entity/country_code_entity.dart';
import 'package:international_phone_field/src/utils/bottomsheet.dart';
import 'package:international_phone_field/src/utils/format_util.dart';

class InternationalPhoneField extends StatefulWidget {
  InternationalPhoneField({
    Key? key,
    this.autoFocus = false,
    this.style = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
    this.hintStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black26),
    required this.onChanged,
    this.onCountrySelected,
    this.cursorColor = Colors.black,
    this.notFoundCountryMessage = "Country",
    this.notFoundNumberMessage = "Your phone number",
    this.dividerColor = Colors.black12,
    this.inOneLine = false,
  }) : super(key: key);

  final Color dividerColor;
  final Color cursorColor;
  final String notFoundCountryMessage;
  final String notFoundNumberMessage;
  final bool autoFocus;
  final TextStyle style;
  final TextStyle hintStyle;
  final Function(String text) onChanged;
  final Function(CountryCodes selectedCountryCode)? onCountrySelected;
  final bool inOneLine;

  @override
  State<InternationalPhoneField> createState() => _InternationalPhoneFieldState();
}

class _InternationalPhoneFieldState extends State<InternationalPhoneField> {
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
          return Column(
            children: [
              CountryTitle(
                state: state,
                onTap: () {
                  showCountryList(
                    controllerBloc,
                  );
                },
                notFoundCountryMessage: widget.notFoundCountryMessage,
              ),
              SizedBox(height: 12),
              Divider(
                color: widget.dividerColor,
                height: 0,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("+", style: widget.style),
                        Flexible(
                          fit: FlexFit.loose,
                          child: IntrinsicWidth(
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: codeController,
                              maxLines: 1,
                              maxLength: 4,
                              focusNode: _codeFocusNode,
                              style: widget.style,
                              decoration: InputDecoration(
                                counterText: "",
                                border: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                              ),
                              cursorColor: widget.cursorColor,
                              onChanged: (String text) {
                                controllerBloc.add(FindCountryCode(code: text));
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    height: 30,
                    color: widget.dividerColor,
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

                                var finalMaskText = phoneFormatter(mask: state.selectedCountryCode.phoneMask).maskText(
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

class CountryTitle extends StatelessWidget {
  CountryTitle({
    super.key,
    required this.state,
    this.style = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
    required this.onTap,
    required String notFoundCountryMessage,
    this.countryTextStyle,
  });

  final PhoneControllerState state;
  final TextStyle style;
  final TextStyle? countryTextStyle;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AnimatedCrossFade(
          firstChild: Row(
            children: [
              if (state.selectedCountryCode.countryCode.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Image.asset(
                    'assets/flags/${state.selectedCountryCode.countryCode.toLowerCase()}.png',
                    height: 18,
                    width: 34,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      height: 18,
                      width: 34,
                    ),
                  ),
                )
              else
                Container(
                  color: Colors.grey.shade200,
                  height: 18,
                  width: 34,
                ),
              SizedBox(width: 8),
              Text(
                state.selectedCountryCode.country,
                style: countryTextStyle ??
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
              ),
            ],
          ),
          secondChild: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Country",
              style: countryTextStyle ??
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
            ),
          ),
          crossFadeState: state.selectedCountryCode.isNotEmpty() ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: Duration(milliseconds: 400),
        ),
      ),
    );
  }
}
