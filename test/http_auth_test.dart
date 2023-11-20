// Copyright (c) 2018, Marco Esposito (marcoesposito1988@gmail.com).
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:http/http.dart' as http;
import 'package:http_auth/http_auth.dart';
import 'package:http_auth/src/http_auth_utils.dart';
import 'package:test/test.dart';

void main() async {
  group('Basic Auth', () {
    http.BaseClient client;

//    setUp(() {
//
//    });

    test('httpbin HTTP', () async {
      final url = 'http://eu.httpbin.org/basic-auth/user/passwd';
      client = BasicAuthClient('user', 'passwd');

      var response = await client.get(Uri.parse(url));
      expect(response.statusCode == 200, isTrue);
    });

    test('httpbin HTTPS', () async {
      final url = 'https://eu.httpbin.org/basic-auth/user/passwd';
      client = BasicAuthClient('user', 'passwd');

      var response = await client.get(Uri.parse(url));
      expect(response.statusCode == 200, isTrue);
    });

    test('jigsaw HTTP', () async {
      final url = 'http://jigsaw.w3.org/HTTP/Basic/';
      client = BasicAuthClient('guest', 'guest');

      var response = await client.get(Uri.parse(url));
      expect(response.statusCode, 200);
    });

    test('jigsaw HTTPS', () async {
      final url = 'https://jigsaw.w3.org/HTTP/Basic/';
      client = BasicAuthClient('guest', 'guest');

      var response = await client.get(Uri.parse(url));
      expect(response.statusCode, 200);
    });
  });

  group('Digest Auth', () {
    http.BaseClient client;

//    setUp(() {
//
//    });

    test('httpbin HTTP', () async {
      final url = 'http://eu.httpbin.org/digest-auth/auth/user/passwd';
      client = DigestAuthClient('user', 'passwd');

      var response = await client.get(Uri.parse(url));
      expect(response.statusCode == 200, isTrue);
    });

    test('httpbin HTTPS', () async {
      final url = 'https://eu.httpbin.org/digest-auth/auth/user/passwd';
      client = DigestAuthClient('user', 'passwd');

      var response = await client.get(Uri.parse(url));
      expect(response.statusCode == 200, isTrue);
    });

    test('jigsaw HTTP', () async {
      final url = 'http://jigsaw.w3.org/HTTP/Digest/';
      client = DigestAuthClient('guest', 'guest');

      var response = await client.get(Uri.parse(url));
      expect(response.statusCode, 200);
    });

    test('jigsaw HTTPS', () async {
      final url = 'https://jigsaw.w3.org/HTTP/Digest/';
      client = DigestAuthClient('guest', 'guest');

      var response = await client.get(Uri.parse(url));
      expect(response.statusCode, 200);
    });
  });

  group('Automatic negotiation', () {
//    setUp(() {
//
//    });

    test('httpbin HTTPS Basic', () async {
      final url = 'https://eu.httpbin.org/basic-auth/user/passwd';
      final client = NegotiateAuthClient('user', 'passwd');
      final response = await client.get(Uri.parse(url));
      expect(response.statusCode, 200);
    });

    test('httpbin HTTPS Digest', () async {
      final url = 'https://eu.httpbin.org/digest-auth/auth/user/passwd';
      final client = NegotiateAuthClient('user', 'passwd');
      final response = await client.get(Uri.parse(url));
      expect(response.statusCode, 200);
    });

    test('jigsaw HTTP Basic', () async {
      final url = 'http://jigsaw.w3.org/HTTP/Basic/';
      final client = NegotiateAuthClient('guest', 'guest');
      final response = await client.get(Uri.parse(url));
      expect(response.statusCode, 200);
    });

    test('jigsaw HTTP Digest', () async {
      final url = 'http://jigsaw.w3.org/HTTP/Digest/';
      final client = NegotiateAuthClient('guest', 'guest');
      final response = await client.get(Uri.parse(url + rand));
      expect(response.statusCode, 200);
    });
  });

  group('Automatic negotiation, multiple requests', () {
//    setUp(() {
//
//    });

    test('httpbin HTTP Digest', () async {
      final url = 'http://httpbin.org/digest-auth/auth/foo/bar';
      final count = _CountingHttpClient();
      final client = NegotiateAuthClient('foo', 'bar', inner: count);
      final response = await client.get(Uri.parse(url));
      expect(response.statusCode, 200);
      expect(count.requestCount, 2);
      // lets try a second request.
      final response2 = await client.get(Uri.parse(url));
      expect(response2.statusCode, 200);
      expect(count.requestCount, 3);
    });
  });

  group('Automatic negotiation, scheme picking', () {
    test('Basic', () {
      expect(pickSchemeFromAuthenticateHeader('Basic'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('Basic,Basic'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('basic'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('basic,Basic'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('Basic,somenoise'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('Basic,somenoise=randomstuff'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('Basic,,somenoise=randomstuff'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('Basic somenoise=randomstuff'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('somenoise=randomstuff,Basic'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('somenoise=randomstuff,,Basic'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('somenoise=randomstuff, ,Basic'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('somenoise=randomstuff Basic'),
          AuthenticationScheme.basic);
      expect(pickSchemeFromAuthenticateHeader('negotiate,basic'),
          AuthenticationScheme.basic);
      expect(
          pickSchemeFromAuthenticateHeader(
              'Negotiate,Basic realm="Keepass DAV data"'),
          AuthenticationScheme.basic);
    });

    test('Digest', () {
      expect(pickSchemeFromAuthenticateHeader('Digest'),
          AuthenticationScheme.digest);
      expect(pickSchemeFromAuthenticateHeader('Digest,somenoise'),
          AuthenticationScheme.digest);
      expect(pickSchemeFromAuthenticateHeader('Digest,somenoise=randomstuff'),
          AuthenticationScheme.digest);
      expect(pickSchemeFromAuthenticateHeader('Digest,,somenoise=randomstuff'),
          AuthenticationScheme.digest);
      expect(pickSchemeFromAuthenticateHeader('Digest somenoise=randomstuff'),
          AuthenticationScheme.digest);
      expect(pickSchemeFromAuthenticateHeader('negotiate,digest'),
          AuthenticationScheme.digest);
    });

    test('Digest over Basic', () {
      expect(pickSchemeFromAuthenticateHeader('Digest,Basic'),
          AuthenticationScheme.digest);
      expect(pickSchemeFromAuthenticateHeader('Basic,Digest'),
          AuthenticationScheme.digest);
      expect(pickSchemeFromAuthenticateHeader('Digest,somenoise'),
          AuthenticationScheme.digest);
      expect(pickSchemeFromAuthenticateHeader('Digest,somenoise=randomstuff'),
          AuthenticationScheme.digest);
      expect(pickSchemeFromAuthenticateHeader('Digest,,somenoise=randomstuff'),
          AuthenticationScheme.digest);
      expect(pickSchemeFromAuthenticateHeader('Digest somenoise=randomstuff'),
          AuthenticationScheme.digest);
      expect(pickSchemeFromAuthenticateHeader('Digest,somenoise,Basic'),
          AuthenticationScheme.digest);
      expect(
          pickSchemeFromAuthenticateHeader(
              'Digest,somenoise=randomstuff,Basic'),
          AuthenticationScheme.digest);
      expect(
          pickSchemeFromAuthenticateHeader(
              'Digest,,somenoise=randomstuff,Basic'),
          AuthenticationScheme.digest);
      expect(
          pickSchemeFromAuthenticateHeader(
              'Digest somenoise=randomstuff,,Basic'),
          AuthenticationScheme.digest);
    });

    test('None', () {
      expect(pickSchemeFromAuthenticateHeader('Something'), null);
      expect(pickSchemeFromAuthenticateHeader('Something,somenoise'), null);
      expect(
          pickSchemeFromAuthenticateHeader('Something,somenoise=randomstuff'),
          null);
      expect(
          pickSchemeFromAuthenticateHeader('Something,,somenoise=randomstuff'),
          null);
      expect(
          pickSchemeFromAuthenticateHeader('Something somenoise=randomstuff'),
          null);
    });
  });
}

String get rand => '?t=${DateTime.now().millisecondsSinceEpoch}';

class _CountingHttpClient extends http.BaseClient {
  final _inner = http.Client();
  int requestCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requestCount++;
    return _inner.send(request);
  }
}
