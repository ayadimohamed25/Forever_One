import '../../domain/entities/warehouse_entity.dart';

class WarehouseModel {
  final String id;
  final String name;
  final String? location;

  WarehouseModel({required this.id, required this.name, this.location});

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }

  WarehouseEntity toEntity() {
    return WarehouseEntity(id: id, name: name, location: location);
  }
}