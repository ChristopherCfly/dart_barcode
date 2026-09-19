/*
 * Copyright (C) 2020, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:barcode/barcode.dart';
import 'package:barcode/src/barcode_2d.dart';
import 'package:test/test.dart';

import 'golden_utils.dart';

void main() {
  qrMatrixParity();

  test('Barcode QR', () {
    final bc = Barcode.qrCode();
    if (bc is! Barcode2D) {
      throw Exception('${bc.name} is not a Barcode2D');
    }

    expect(bc.toSvg('0'), matchesGoldenString('qr/0.svg'));
    expect(
      bc.toSvg(String.fromCharCodes(Iterable.generate(256))),
      matchesGoldenString('qr/256.svg'),
    );
  });

  test('Barcode QR High error correction level', () {
    final bc = Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.high);
    if (bc is! Barcode2D) {
      throw Exception('bc is not a Barcode2D');
    }

    expect(bc.toSvg('0'), matchesGoldenString('qr/0_high_error_level.svg'));
  });

  test('Barcode QR manual type', () {
    final bc = Barcode.qrCode(typeNumber: 2);
    if (bc is! Barcode2D) {
      throw Exception('bc is not a Barcode2D');
    }

    expect(bc.toSvg('0'), matchesGoldenString('qr/0_manual.svg'));
  });

  test('Barcode QR limits', () {
    final bc = Barcode.qrCode();
    if (bc is! Barcode2D) {
      throw Exception('bc is not a Barcode2D');
    }

    expect(bc.charSet, equals(List<int>.generate(256, (e) => e)));
    expect(bc.minLength, equals(1));
    expect(bc.maxLength, greaterThan(1024));
  });
}

/// Every correction level, auto and manual version, over payloads that
/// exercise numeric, alphanumeric, byte and multi-byte UTF-8 content. The
/// goldens were captured on qr 3.0.2, so any change of the encoder that moves
/// a single module fails here.
void qrMatrixParity() {
  const payloads = <String, String>{
    'numeric': '0123456789',
    'alnum': 'HELLO WORLD 42',
    'url': 'https://cinefly.example/s/AbC123?x=1',
    'utf8': 'Café — 日本',
  };
  for (final level in BarcodeQRCorrectionLevel.values) {
    for (final typeNumber in <int?>[null, 6]) {
      for (final entry in payloads.entries) {
        final label = '${level.name}_${typeNumber ?? 'auto'}_${entry.key}';
        test('Barcode QR parity $label', () {
          final bc = Barcode.qrCode(
            errorCorrectLevel: level,
            typeNumber: typeNumber,
          );
          expect(
            bc.toSvg(entry.value),
            matchesGoldenString('qr/parity/$label.svg'),
          );
        });
      }
    }
  }
}
