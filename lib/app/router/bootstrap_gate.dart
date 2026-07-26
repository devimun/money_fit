import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BootstrapGateState {
  checkingUpdate,
  initializing,
  needsSetup,
  ready,
  recoverableFailure,
  forceUpdate,
}

class BootstrapGateController extends StateNotifier<BootstrapGateState> {
  BootstrapGateController() : super(BootstrapGateState.checkingUpdate);

  void set(BootstrapGateState next) => state = next;
}

final bootstrapGateProvider =
    StateNotifierProvider<BootstrapGateController, BootstrapGateState>(
      (ref) => BootstrapGateController(),
    );
