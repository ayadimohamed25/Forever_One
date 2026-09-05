import 'package:flutter_test/flutter_test.dart';
import 'package:foreverone/features/sales/domain/entities/sale_line_entity.dart';

void main() {
  group('SaleLineEntity', () {
    test('calcule correctement le total de ligne', () {
      const line = SaleLineEntity(
        productId: 'p1',
        productName: 'Produit test',
        quantity: 3,
        unitPrice: 19.99,
      );

      expect(line.lineTotal, closeTo(59.97, 0.001));
    });

    test('retourne 0 quand la quantité est nulle', () {
      const line = SaleLineEntity(
        productId: 'p1',
        productName: 'Produit test',
        quantity: 0,
        unitPrice: 19.99,
      );

      expect(line.lineTotal, 0);
    });

    test('gère les prix décimaux sans erreur d\'arrondi visible', () {
      const line = SaleLineEntity(
        productId: 'p1',
        productName: 'Produit test',
        quantity: 7,
        unitPrice: 0.1,
      );

      expect(line.lineTotal, closeTo(0.7, 0.0001));
    });
  });
}