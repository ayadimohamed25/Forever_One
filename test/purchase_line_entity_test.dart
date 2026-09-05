import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/features/purchases/domain/entities/purchase_line_entity.dart';

void main() {
  group('PurchaseLineEntity', () {
    test('calcule correctement le total de ligne', () {
      const line = PurchaseLineEntity(
        productId: 'p1',
        productName: 'Produit test',
        quantity: 20,
        unitCost: 10.0,
      );

      expect(line.lineTotal, 200.0);
    });

    test('gère un coût unitaire décimal', () {
      const line = PurchaseLineEntity(
        productId: 'p1',
        productName: 'Produit test',
        quantity: 4,
        unitCost: 12.75,
      );

      expect(line.lineTotal, closeTo(51.0, 0.001));
    });
  });
}