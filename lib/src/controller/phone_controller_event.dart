part of 'phone_controller_bloc.dart';

abstract class PhoneControllerEvent {}

class LoadCountryCodesEvent extends PhoneControllerEvent {}

class SearchCountryCodesEvent extends PhoneControllerEvent {
  final String searchQuery;

  SearchCountryCodesEvent(this.searchQuery);
}

class SelectCountryCodeEvent extends PhoneControllerEvent {
  final CountryCodes selectedCountryCode;

  SelectCountryCodeEvent(this.selectedCountryCode);
}

class FindCountryCode extends PhoneControllerEvent {
  final String code;

  FindCountryCode({required this.code});
}

class AdditionalFinder extends PhoneControllerEvent {
  final String code;

  AdditionalFinder({required this.code});
}
