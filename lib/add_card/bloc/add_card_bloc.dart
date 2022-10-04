import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:paymentez_mobile/add_card/bloc/bloc.dart';
import 'package:paymentez_mobile/channel/paymentez_channel.dart';
import 'package:paymentez_mobile/repository/model/card_bin_model.dart';
import 'package:paymentez_mobile/repository/model/card_model.dart';
import 'package:paymentez_mobile/repository/model/error_model.dart';
import 'package:paymentez_mobile/repository/paymentez_repository.dart';
import 'package:paymentez_mobile/utils/validators.dart';

class AddCardBloc extends Bloc<AddCardEvent, AddCardState> {
  PaymentezRepository _paymentezRepository;

  AddCardBloc({
    @required PaymentezRepository paymentezRepository,
  })  : assert(paymentezRepository != null),
        _paymentezRepository = paymentezRepository,
        super(AddCardState.fromJson({}).empty()) {
    print('Log: ${_paymentezRepository.configState.isFlutterAppHost}');
    on<NumberChanged>(_mapNumberChangedToState);
    on<NameChanged>(_mapNameChangedToState);
    on<DateExpChanged>(_mapDateExpChangedToState);
    on<CvvChanged>(_mapCvvChangedToState);
    on<FiscalNumberChanged>(_mapFiscalNumberChangedToState);
    on<TuyaCodeChanged>(_mapTuyaCodeChangedToState);
    on<Submitted>(_mapSummitedToState);
  }

//  @override
//  Stream<AddCardState> transformEvents(
//    Stream<AddCardEvent> events,
//    Stream<AddCardState> Function(AddCardEvent event) next,
//  ) {
//    final nonDebounceStream = events.where((event) {
//      return (event is! NameChanged && event is! CvvChanged);
//    });
//    final debounceStream = events.where((event) {
//      return (event is NameChanged || event is CvvChanged);
//    }).debounceTime(Duration(milliseconds: 300));
//    return super.transformEvents(
//      nonDebounceStream.mergeWith([debounceStream]),
//      next,
//    );
//  }

  Future<void> _mapNameChangedToState(
      NameChanged event, Emitter<AddCardState> emit) async {
    emit(state.update(
      nameError: Validators.isValidName(event.context, event.name),
    ));
  }

  Future<void> _mapDateExpChangedToState(
      DateExpChanged event, Emitter<AddCardState> emit) async {
    emit(state.update(
      dateExpError: Validators.isValidDateExp(event.context, event.dateExp),
    ));
  }

  Future<void> _mapCvvChangedToState(
      CvvChanged event, Emitter<AddCardState> emit) async {
    emit(state.update(
      cvvError: Validators.isValidCVV(
          event.context, event.cvv, state.cardBin?.cvvLength),
    ));
  }

  Future<void> _mapFiscalNumberChangedToState(
      FiscalNumberChanged event, Emitter<AddCardState> emit) async {
    emit(state.update(
      fiscalNumberError:
          Validators.isValidFiscalNumber(event.context, event.fiscalNumber),
    ));
  }

  Future<void> _mapTuyaCodeChangedToState(
      TuyaCodeChanged event, Emitter<AddCardState> emit) async {
    emit(state.update(
      tuyaCodeError: Validators.isValidTuyaCode(event.context, event.tuyaCode),
    ));
  }

  Future<void> _mapNumberChangedToState(
      NumberChanged event, Emitter<AddCardState> emit) async {
    var cardBin =
        event.number.length < 6 ? CardBinModel.fromJson({}) : state.cardBin;
    if (event.number.length >= 6 && event.number.length < 11 ||
        event.number.length >= 6 && state.cardBin == CardBinModel.fromJson({}))
      cardBin = await _paymentezRepository.getCardBin(
          bin: event.number.substring(0, min(event.number.length, 10)));

    emit(state.updateNumber(
      number: event.number,
      cardBin: cardBin,
      numberError: Validators.isValidNumber(
          event.context,
          cardBin?.cardType ?? '',
          event.number ?? '',
          cardBin?.cardMask ?? AddCardState.numberDefaultMask,
          cardBin?.useLuhn ?? true),
    ));
  }

  Future<void> _mapSummitedToState(
      Submitted event, Emitter<AddCardState> emit) async {
    emit(state.loading());
    try {
      var response = await _paymentezRepository.createToken(event.context,
          sessionId: '', card: event.card);
      print('the request est returned');

      var result = CardModel.fromJson(response.data['card' ?? {}]);
      print('the request est ok');
      emit(state.success(result));
      Future.delayed(Duration(seconds: 2), () {
        if (_paymentezRepository.configState.isFlutterAppHost)
          _paymentezRepository.successAction(result);
        else
          Paymentez.getInstance.deliverAddCardResponse(event.context, result);
      });
    } on DioError catch (e) {
      var result = ErrorModel.fromJson(e.response.data['error']);
      emit(state.failure(result));
      Future.delayed(Duration(seconds: 2), () {
        if (_paymentezRepository.configState.isFlutterAppHost)
          _paymentezRepository.errorAction(result);
        else
          Paymentez.getInstance.deliverAddCardResponse(event.context, result);
      });
    }
  }
}
