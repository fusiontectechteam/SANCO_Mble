// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<bool> login(String username, String password) async {
    final String apiUrl =
        "https://fusiontecsoftware.com/sancowebapi/sancoapi/employeeloginDetails?ids=$username~$password";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['myRoot'] != null && data['myRoot'].isNotEmpty) {
          final user = data['myRoot'][0];
          if (user['UserName'] == username &&
              user['NPassword'] == password) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }
   static Future<List<dynamic>> fetchReceiptDetails(String date) async {
    final url =
        "http://fusiontecsoftware.com/sancowebapi/sancoapi/LoadReceiptDetails?dates=$date";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['myRoot'] ?? [];
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("API error: $e");
      return [];
    }
  }
}