import 'package:flutter/material.dart';
import 'package:international_phone_text_field/src/controller/phone_controller_bloc.dart';
import 'package:international_phone_text_field/src/utils/wrong_flag_container.dart';

class CountryTitle extends StatelessWidget {
  CountryTitle({
    super.key,
    required this.state,
    this.style = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
    required this.onTap,
    required this.notFoundCountryMessage,
    this.countryTextStyle,
    required this.inOneLine,
  });

  final PhoneControllerState state;
  final TextStyle style;
  final TextStyle? countryTextStyle;
  final Function() onTap;
  final bool inOneLine;
  final String notFoundCountryMessage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: inOneLine ? 0 : 16).copyWith(
          left: inOneLine ? 8 : 0,
        ),
        child: AnimatedCrossFade(
          firstChild: Row(
            children: [
              if (state.selectedCountryCode.countryCode.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    'assets/flags/${state.selectedCountryCode.countryCode.toLowerCase()}.png',
                    height: 20,
                    width: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => WrongFlagContainer(),
                  ),
                )
              else
                WrongFlagContainer(),
              if (!inOneLine) ...[
                SizedBox(width: 8),
                Text(
                  state.selectedCountryCode.country,
                  style: countryTextStyle ??
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                ),
              ]
            ],
          ),
          secondChild: inOneLine
              ? WrongFlagContainer()
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    notFoundCountryMessage,
                    style: countryTextStyle ??
                        TextStyle(
                          fontSize: 14,
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
