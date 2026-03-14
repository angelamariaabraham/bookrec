import 'package:flutter/material.dart';
import 'package:bookrec/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Starting search test...');
  try {
    final results = await DatabaseService.instance.searchBooks("harry");
    print('Found ${results.length} results');
    for (var r in results) {
      print('- ${r.title}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
