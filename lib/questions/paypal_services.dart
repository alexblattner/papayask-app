import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

class PaypalServices {
  String orderId = '';

  // for creating the payment request with Paypal
  Future<Map<String, dynamic>?> createPaypalPayment(double payment) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      return null;
    }
    var response = await http.post(
        Uri.parse('${FlutterConfig.get('API_URL')}/questions/pay'),
        body: {
          'cost': '$payment'
        },
        headers: {
          'Authorization': 'Bearer $token',
        });
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['result'] != null) {
        orderId = data['result']['id'];
        if (data['result']["links"] != null &&
            data['result']["links"].length > 0) {
          List links = data['result']["links"];

          String executeUrl = "";
          String approvalUrl = "";
          final item = links.firstWhere((o) => o["rel"] == "approve",
              orElse: () => null);
          if (item != null) {
            approvalUrl = item["href"];
          }
          final item1 =
              links.firstWhere((o) => o["rel"] == "cpture", orElse: () => null);
          if (item1 != null) {
            executeUrl = item1["href"];
          }
          return {"executeUrl": executeUrl, "approvalUrl": approvalUrl};
        }
        return null;
      } else {
        return {'created': true};
      }
    } else {
      throw Exception('failed to create payment');
    }
  }

  // for executing the payment transaction
  Future<String?> executePayment(double payment) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      return null;
    }
    await http.post(Uri.parse('${FlutterConfig.get('API_URL')}/questions/pay'),
        body: {
          'cost': '$payment',
          'capture': orderId
        },
        headers: {
          'Authorization': 'Bearer $token',
        });
    orderId = "";

    return null;
  }
}
