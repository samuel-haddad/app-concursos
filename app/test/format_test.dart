import 'package:flutter_test/flutter_test.dart';
import 'package:app_estudo_tcdf/core/format.dart';

void main() {
  group('Fmt.minutos', () {
    test('formata horas e minutos', () {
      expect(Fmt.minutos(0), '0 min');
      expect(Fmt.minutos(30), '30 min');
      expect(Fmt.minutos(60), '1h');
      expect(Fmt.minutos(90), '1h 30min');
    });
  });

  test('Fmt.iso gera yyyy-MM-dd', () {
    expect(Fmt.iso(DateTime(2026, 7, 5)), '2026-07-05');
    expect(Fmt.iso(DateTime(2026, 11, 22)), '2026-11-22');
  });
}
