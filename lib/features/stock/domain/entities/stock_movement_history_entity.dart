class StockMovementHistoryEntity {
  final String id;
  final String type;
  final int quantity;
  final String? note;
  final String? warehouseName;
  final DateTime createdAt;

  const StockMovementHistoryEntity({
    required this.id,
    required this.type,
    required this.quantity,
    this.note,
    this.warehouseName,
    required this.createdAt,
  });

  bool get isIncoming => type == 'in';
}