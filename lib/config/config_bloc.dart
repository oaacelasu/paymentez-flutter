import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:paymentez_mobile/config/bloc.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  ConfigBloc() : super(StgModeState("JVA-CO-CLIENT", "v3Ew8H8csSXxaf2IvvmuLnnB0nPmT0", false)) {
    on<SetEnvironment>(_mapSetEnvironmentToState);
  }

  Future<void> _mapSetEnvironmentToState(
      SetEnvironment event,
      Emitter<ConfigState> emit,
      ) async {
    switch (event.testMode.toLowerCase()) {
      case 'prod':
        emit(ProdModeState(
          event.paymentezClientAppCode,
          event.paymentezClientAppKey,
          event.isFlutterAppHost,
          initiated: true,
        ));
        break;
      case 'qa':
        emit( QaModeState(
          event.paymentezClientAppCode,
          event.paymentezClientAppKey,
          event.isFlutterAppHost,
          initiated: true,
        ));
        break;
      case 'stg':
        emit( StgModeState(
          event.paymentezClientAppCode,
          event.paymentezClientAppKey,
          event.isFlutterAppHost,
          initiated: true,
        ));
        break;
      case 'dev':
        emit( DevModeState(
          event.paymentezClientAppCode,
          event.paymentezClientAppKey,
          event.isFlutterAppHost,
          initiated: true,
        ));
        break;
      default:
        emit( DevModeState(
          event.paymentezClientAppCode,
          event.paymentezClientAppKey,
          event.isFlutterAppHost,
          initiated: true,
        ));
    }
  }
}
