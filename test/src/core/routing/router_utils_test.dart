import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_laundry/src/core/routing/router_utils.dart';
import 'package:hzn_laundry/src/core/utils/slugify.dart';

void main() {
  group('slugify', () {
    test('lowercases and hyphenates', () {
      expect(slugify('Bacolod Branch'), 'bacolod-branch');
      expect(slugify('  HZN Laundry  '), 'hzn-laundry');
      expect(slugify('Main!!!'), 'main');
    });
  });

  group('RouterUtils.replaceScopeSegment', () {
    test('replaces org and branch segments', () {
      expect(
        RouterUtils.replaceScopeSegment(
          '/acme/downtown/products/abc',
          orgSlug: 'other',
          branchSlug: 'all',
        ),
        '/other/all/products/abc',
      );
    });

    test('leaves short paths unchanged', () {
      expect(
        RouterUtils.replaceScopeSegment('/login', branchSlug: 'all'),
        '/login',
      );
    });
  });

  group('RouterUtils.isEmptyRootPath', () {
    test('is true for empty and slash-only paths', () {
      expect(RouterUtils.isEmptyRootPath(''), isTrue);
      expect(RouterUtils.isEmptyRootPath('/'), isTrue);
      expect(RouterUtils.isEmptyRootPath('/dashboard'), isFalse);
      expect(RouterUtils.isEmptyRootPath('/login'), isFalse);
    });
  });
}
