// ignore_for_file: avoid_print
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('====================================================');
  print('🧪 Starting Real E2E Live Backend Authentication Test');
  print('====================================================');

  const baseUrl = 'http://localhost:5001/api/v1';

  // 1. Check health
  print('\nStep 1: Checking Live Backend Health...');
  final healthRes = await http.get(Uri.parse('$baseUrl/health'));
  print('Status: ${healthRes.statusCode}, Body: ${healthRes.body}');
  assert(healthRes.statusCode == 200, 'Backend is not healthy');

  // 2. Register real user
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testEmail = 'live_owner_$timestamp@nirmaan.local';
  print('\nStep 2: Registering user: $testEmail');

  final registerRes = await http.post(
    Uri.parse('$baseUrl/auth/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'name': 'Rajesh Sharma',
      'email': testEmail,
      'password': 'Password@123',
      'role': 'BUSINESS_OWNER',
      'phone': '+91 98765 43210',
      'businessName': 'Live E2E Kirana Store',
    }),
  );
  print('Register Status: ${registerRes.statusCode}');
  print('Register Body: ${registerRes.body}');
  assert(registerRes.statusCode == 201, 'Registration failed');

  final regJson = jsonDecode(registerRes.body) as Map<String, dynamic>;
  final token = regJson['data']['token'] as String;
  final user = regJson['data']['user'] as Map<String, dynamic>;
  assert(token.isNotEmpty, 'Token must not be empty');
  assert(user['email'] == testEmail, 'User email mismatch');
  assert(user['role'] == 'BUSINESS_OWNER', 'User role mismatch');
  print('✅ Registration Succeeded! Token issued: ${token.substring(0, 20)}...');

  // 3. Login with credentials
  print('\nStep 3: Logging in with registered credentials...');
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': testEmail,
      'password': 'Password@123',
    }),
  );
  print('Login Status: ${loginRes.statusCode}');
  assert(loginRes.statusCode == 200, 'Login failed');
  final loginJson = jsonDecode(loginRes.body) as Map<String, dynamic>;
  final loginToken = loginJson['data']['token'] as String;
  assert(loginToken.isNotEmpty, 'Login token must not be empty');
  print('✅ Login Succeeded!');

  // 4. Test protected endpoint /auth/me with Bearer token
  print('\nStep 4: Calling Protected Endpoint /auth/me with Bearer token...');
  final meRes = await http.get(
    Uri.parse('$baseUrl/auth/me'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $loginToken',
    },
  );
  print('Protected Endpoint Status: ${meRes.statusCode}');
  print('Protected Endpoint Body: ${meRes.body}');
  assert(meRes.statusCode == 200, 'Protected endpoint failed');
  print('✅ Protected Endpoint Accepted Valid Bearer Token!');

  // 5. Test RBAC: Call Owner-only endpoint with Business Owner token
  print('\nStep 5: Testing Server-side RBAC on Owner Endpoint...');
  final rbacRes = await http.get(
    Uri.parse('$baseUrl/auth/owner-dashboard'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $loginToken',
    },
  );
  print('Owner Endpoint Status: ${rbacRes.statusCode}');
  assert(rbacRes.statusCode == 200, 'Owner endpoint access failed');
  print('✅ RBAC Allowed Authorized Role!');

  // 6. Test RBAC: Call Admin-only endpoint with Business Owner token (Must be REJECTED 403)
  print('\nStep 6: Testing Server-side RBAC Rejection for Unauthorized Role...');
  final adminRes = await http.get(
    Uri.parse('$baseUrl/auth/admin-governance'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $loginToken',
    },
  );
  print('Admin Endpoint Status: ${adminRes.statusCode} (Expected 403)');
  assert(adminRes.statusCode == 403, 'RBAC did not reject unauthorized role');
  print('✅ Server-side RBAC Strictly Blocked Unauthorized Role with 403!');

  // 7. Test Fail-Closed: Call protected endpoint without token (Must be REJECTED 401)
  print('\nStep 7: Testing Fail-Closed Security without Token...');
  final unauthRes = await http.get(
    Uri.parse('$baseUrl/auth/me'),
    headers: {'Content-Type': 'application/json'},
  );
  print('Unauthenticated Request Status: ${unauthRes.statusCode} (Expected 401)');
  assert(unauthRes.statusCode == 401, 'Fail-closed failed');
  print('✅ Unauthenticated Request Successfully Failed-Closed with 401!');

  print('\n====================================================');
  print('🎉 ALL LIVE E2E AUTHENTICATION TESTS PASSED 100%!');
  print('====================================================');
  exit(0);
}
