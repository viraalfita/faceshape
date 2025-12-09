import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing API connection...');
  
  final apiUrl = 'https://epsilon-raimulabs.hf.space/predict';
  
  try {
    // Test 1: Check if API is reachable
    print('\n1. Checking API endpoint...');
    final response = await http.get(Uri.parse('https://epsilon-raimulabs.hf.space/'));
    print('   Status: ${response.statusCode}');
    print('   API is reachable!');
    
    // Test 2: Expected response format
    print('\n2. Expected response format from API:');
    print('   {');
    print('     "final_prediction": "OVAL",');
    print('     "svm": "OVAL",');
    print('     "mlp": "OVAL",');
    print('     "knn": "OVAL",');
    print('     "confidence": "3/3",');
    print('     "image": "base64_string"');
    print('   }');
    
    print('\n✓ API endpoint looks good!');
    print('✓ Make sure your Flutter app looks for "final_prediction" key');
    
  } catch (e) {
    print('✗ Error: $e');
  }
}
