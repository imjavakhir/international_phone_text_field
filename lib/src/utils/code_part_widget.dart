import 'package:flutter/material.dart';
import 'package:international_phone_text_field/international_phone_field.dart';
import 'package:international_phone_text_field/src/controller/phone_controller_bloc.dart';

class CodePartWidget extends StatelessWidget {
  const CodePartWidget({
    super.key,
    required this.widget,
    required this.codeController,
    required FocusNode codeFocusNode,
    required this.controllerBloc,
  }) : _codeFocusNode = codeFocusNode;

  final InternationalPhoneTextField widget;
  final TextEditingController codeController;
  final FocusNode _codeFocusNode;
  final PhoneControllerBloc controllerBloc;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
