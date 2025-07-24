import 'mediator_data.dart';

abstract class IMediator {
  MediatorData getMediatorData();
  Future<void> notify(String event);
}
