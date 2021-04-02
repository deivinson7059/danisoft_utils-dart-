import 'package:danisoft_utils/danisoft_utils.dart';
import 'package:flutter/material.dart';
import 'dart:math';

const String sharedSecret = 's3cr3t';

void main() {
  final jwt = senderCreatesJwt();
  receiverProcessesJwt(jwt);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      initialRoute: 'page1',
      routes: {
        'page1': (_) => Page1(),
        'page2': (_) => Page2(),
      },
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page 1'),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.blue,
      body: Center(
        child: MaterialButton(
          child: Text('Go to page2'),
          color: Colors.white,
          onPressed: () {
            PageRouteTransition(
              context: context,
              page: Page2(),
              animation: AnimationType.fadeIn,
              duration: Duration(milliseconds: 100),
              replacement: true,
            );
          },
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page 2'),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Text('Page2'),
      ),
    );
  }
}

String senderCreatesJwt() {
  // Create a JwtClient

  final claimSet = new JwtClient(
      issuer: 'ds+',
      subject: 'Ds+',
      audience: <String>['danisoft.com.co', 'www.danisoft.com.co'],
      jwtId: _randomString(32),
      otherClaims: <String, dynamic>{
        "IdUsuario": "prueba 1",
        "nombre": "My name",
        "apellidos": "My Apellidos",
        "direccion": "My direccion",
        "tel": "My tel",
        "typ": "authnresponse",
        "pld": {"k": "v"}
      },
      maxAge: const Duration(minutes: 5));

  // Generate a JWT from the claim set

  final token = issueJwtHS256(claimSet, sharedSecret);

  print('JWT: "$token"\n');

  return token;
}

void receiverProcessesJwt(String token) {
  try {
    // Verify the signature in the JWT and extract its claim set
    final decClaimSet = verifyJwtHS256Signature(token, sharedSecret);
    print('JwtClaim: $decClaimSet\n');

    // Validate the claim set

    decClaimSet.validate(issuer: 'ds+', audience: 'danisoft.com.co');

    // Use values from claim set

    if (decClaimSet.subject != null) {
      print('JWT ID: "${decClaimSet.jwtId}"');
    }
    if (decClaimSet.jwtId != null) {
      print('Subject: "${decClaimSet.subject}"');
    }
    if (decClaimSet.issuedAt != null) {
      print('Issued At: ${decClaimSet.issuedAt}');
    }
    if (decClaimSet.containsKey('typ')) {
      final dynamic v = decClaimSet['typ'];
      if (v is String) {
        print('typ: "$v"');
      } else {
        print('Error: unexpected type for "typ" claim');
      }
    }
  } on JwtException catch (e) {
    print('Error: bad JWT: $e');
  }
}

String _randomString(int length) {
  const chars =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  final rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
  final buf = new StringBuffer();

  for (var x = 0; x < length; x++) {
    buf.write(chars[rnd.nextInt(chars.length)]);
  }
  return buf.toString();
}
