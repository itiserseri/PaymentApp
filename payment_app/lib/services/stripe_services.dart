import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/stripe_config.dart';

class StripeService {
  static const Map<String, String> _testTokens = {
    '4789632578963241': 'tok_visa',
    '1478963254789632': 'tok_visa_debit',
    '1257963257896354': 'tok_mastercard',
    '1257896325478963': 'tok_visa_mastercard_debit',
    '4587963257896324': 'tok_visa_chargeDeclined',
    '5632478951235789': 'tok_chargeDeclinedInsufficientFunds'
  };

  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    final amountInCentavos = (amount * 100).round().toString();
    final cleanCard = cardNumber.replaceAll(' ', '');
    final token = _testTokens[cleanCard];

    if (token == null) {
      return {
        'success': false,
        'error': 'Unknown test card.',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('${StripeConfig.apiUrl}/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${StripeConfig.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInCentavos,
          'currency': 'php',
          'payment_method_types[]': 'card',
          'payment_method_data[type]': 'card',
          'payment_method_data[card][token]': token,
          'confirm': 'true',
          'return_url': 'https://example.com/return',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': data['status'] == 'succeeded',
          'amount': (data['amount'] as num?)?.toDouble(),
          'id': data['id'],
          'data': data,
          'error': data['status'] == 'succeeded'
              ? null
              : 'Payment status: ${data['status']}',
        };
      } else {
        return {
          'success': false,
          'error': data['error']?['message'] ??
              'Payment failed (${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
