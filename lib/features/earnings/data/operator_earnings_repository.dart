import '../domain/operator_earning.dart';

abstract interface class OperatorEarningsRepository {
  Future<List<OperatorEarning>> getEarnings();
}
