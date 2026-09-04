import '../../domain/entities/balance_entity.dart';

class BalanceModel {
  final double total;
  final double paid;
  final double balance;

  BalanceModel({required this.total, required this.paid, required this.balance});

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      total: double.parse((json['total'] ?? 0).toString()),
      paid: double.parse((json['paid'] ?? 0).toString()),
      balance: double.parse((json['balance'] ?? 0).toString()),
    );
  }

  BalanceEntity toEntity() => BalanceEntity(total: total, paid: paid, balance: balance);
}