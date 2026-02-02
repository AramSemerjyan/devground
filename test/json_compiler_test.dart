import 'package:dartpad_lite/core/services/compiler/languages/json_compiler.dart';

void main() async {
  final compiler = JSONCompiler();
  int passed = 0;
  int failed = 0;

  print('=' * 70);
  print('JSON COMPILER TEST SUITE');
  print('=' * 70);

  // Helper function to run tests
  Future<void> runTest(
    String name,
    String input,
    List<String> expectedContains,
  ) async {
    print('\n📝 Test: $name');
    print(
      '   Input: ${input.length > 100 ? input.substring(0, 100) + "..." : input}',
    );

    try {
      final result = await compiler.formatCode(input);

      if (result.error != null) {
        print('   ❌ FAILED: ${result.error}');
        failed++;
        return;
      }

      bool allMatch = true;
      for (final expected in expectedContains) {
        if (!result.data!.contains(expected)) {
          print('   ❌ FAILED: Output does not contain "$expected"');
          allMatch = false;
        }
      }

      if (allMatch) {
        print('   ✅ PASSED');
        passed++;
      } else {
        print('   Output: ${result.data}');
        failed++;
      }
    } catch (e) {
      print('   ❌ FAILED with exception: $e');
      failed++;
    }
  }

  // ===== VALID JSON TESTS (should not modify, only format) =====
  print('\n' + '=' * 70);
  print('VALID JSON TESTS (should not modify, only format)');
  print('=' * 70);

  await runTest(
    'Valid JSON with URLs and timestamps',
    '{"info":{"_postman_id":"1766829529087-979811144","name":"Network Tracker Export - jsonplaceholder.typicode.com","description":"Exported from Network Tracker on 2025-12-27T13:58:49.088024","schema":"https://schema.getpostman.com/json/collection/v2.1.0/collection.json"},"item":[]}',
    [
      '"schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"',
      '"description": "Exported from Network Tracker on 2025-12-27T13:58:49.088024"',
    ],
  );

  await runTest(
    'Valid JSON with URL and port',
    '{"url":"https://example.com:8080/path?param=value","protocol":"https://"}',
    [
      '"url": "https://example.com:8080/path?param=value"',
      '"protocol": "https://"',
    ],
  );

  // ===== INVALID JSON TESTS (should fix) =====
  print('\n' + '=' * 70);
  print('INVALID JSON TESTS (should fix)');
  print('=' * 70);

  await runTest(
    'Simple unquoted keys and values',
    '{name: John, age: 30, city: New York}',
    ['"name": "John"', '"age": 30', '"city": "New York"'],
  );

  await runTest(
    'Complex nested structure with UUIDs',
    '{list: {97d8d3de-45ae-46ed-b72d-a2a52c3643e2: {items: {Placement: {rules: [{list: false, task: brand-block-m78uwtmk4w9amcycmsb, metric: field_metrics_bb, option: MUST, weight: 100.0, kpi_type: {id: 191, name: Placement, percent: 100, criterias: {}}, intervals: [], item_type: rule, selected_name: Igor-Rule-1, replace_results: false, intervals_enabled: false, success: false, data: {id: brand-block-m78uwtmk4w9amcycmsb, field: field_metric, is_valid: false, name: Igor-Rule-1}, total: 0}], total: 0.0, order: 1, success: false}}, total: 0.0, name: Test-bb, revision: 10, error: null, error_link: null}}}',
    [
      '"list"',
      '"97d8d3de-45ae-46ed-b72d-a2a52c3643e2"',
      '"Placement"',
      '"task": "brand-block-m78uwtmk4w9amcycmsb"',
      '"Igor-Rule-1"',
    ],
  );

  await runTest(
    'Unquoted keys with numbers and underscores',
    '{user_id: 123, item_name: test, active: true}',
    ['"user_id": 123', '"item_name": "test"', '"active": true'],
  );

  await runTest(
    'Mixed valid and invalid JSON',
    '{name: "John", age: 30, "city": NewYork}',
    ['"name": "John"', '"age": 30', '"city": "NewYork"'],
  );

  await runTest(
    'Array with unquoted values',
    '{items: [apple, banana, cherry], count: 3}',
    ['"items": [', '"apple"', '"banana"', '"cherry"'],
  );

  await runTest(
    'Boolean and null values',
    '{active: true, inactive: false, value: null, count: 0}',
    ['"active": true', '"inactive": false', '"value": null', '"count": 0'],
  );

  await runTest(
    'Decimal numbers',
    '{price: 19.99, weight: 100.0, discount: 0.15}',
    ['"price": 19.99', '"weight": 100.0', '"discount": 0.15'],
  );

  await runTest(
    'Keys with hyphens',
    '{user-id: 123, item-name: test, is-active: true}',
    ['"user-id": 123', '"item-name": "test"', '"is-active": true'],
  );

  await runTest(
    'Empty objects and arrays',
    '{items: [], config: {}, count: 0}',
    ['"items": []', '"config": {}', '"count": 0'],
  );

  await runTest(
    'Nested objects with multiple levels',
    '{user: {profile: {name: John, age: 30}, settings: {theme: dark}}}',
    ['"user"', '"profile"', '"name": "John"', '"settings"', '"theme": "dark"'],
  );

  // ===== EDGE CASES =====
  print('\n' + '=' * 70);
  print('EDGE CASES');
  print('=' * 70);

  await runTest('Single key-value pair', '{name: test}', ['"name": "test"']);

  await runTest('Values with spaces', '{name: John Doe, city: New York City}', [
    '"name": "John Doe"',
    '"city": "New York City"',
  ]);

  await runTest(
    'Very long UUID-like keys',
    '{abc123-def456-ghi789: value1, xyz987-uvw654-rst321: value2}',
    ['"abc123-def456-ghi789"', '"xyz987-uvw654-rst321"'],
  );

  // ===== SUMMARY =====
  print('\n' + '=' * 70);
  print('TEST SUMMARY');
  print('=' * 70);
  print('✅ Passed: $passed');
  print('❌ Failed: $failed');
  print('Total: ${passed + failed}');
  print('=' * 70);

  if (failed > 0) {
    print('\n⚠️  Some tests failed!');
  } else {
    print('\n🎉 All tests passed!');
  }
}
