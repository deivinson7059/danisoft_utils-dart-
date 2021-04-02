import 'package:danisoft_utils/danisoft_utils.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/services.dart';

const String sharedSecret = 's3cr3t';

void main() {
  final jwt = senderCreatesJwt();
  receiverProcessesJwt(jwt);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

class Page2 extends StatefulWidget {
  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  String contentdo = 'Undefined';
  String qrBase64Content = 'Undefined';
  Image? qrImg;
  String? errorD;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TextEditingController _qrTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page 2'),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: Column(
          children: [
            Text('Page2'),
            SizedBox(
              height: 24.0,
            ),
            TextButton(
              onPressed: _scanQR,
              child: Text(
                'Scan QR',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            Text(
              "Generate QR: ",
              style: TextStyle(
                fontSize: 24.0,
              ),
            ),
            SizedBox(
              height: 12.0,
            ),
            TextFormField(
              controller: _qrTextEditingController,
              decoration: InputDecoration(
                  hintText: 'QR Content',
                  labelText: 'QR Content',
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 12.0,
            ),
            qrImg != null
                ? Container(
                    child: qrImg,
                    width: 120.0,
                    height: 120.0,
                  )
                : Image.asset(
                    'assets/images/ic_no_image.png',
                    width: 120.0,
                    height: 120.0,
                    fit: BoxFit.cover,
                  ),
            SizedBox(
              height: 16.0,
            ),
            TextButton(
              onPressed: () => _generateQR(_qrTextEditingController.text),
              child: Text(
                'Generate QR',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scanQR() async {
    String result;
    try {
      result = await QrUtils.scanQR;
    } on PlatformException {
      result = 'Process Failed!';
    }

    setState(() {
      contentdo = result;
    });
  }

  void _generateQR(String content) async {
    if (content.trim().length == 0) {
      if (_scaffoldKey.currentState != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter qr content'),
          ),
        );
      }
      setState(() {
        qrImg = null;
      });
      return;
    }
    Image? image;
    try {
      image = await QrUtils.generateQR(content);
    } on PlatformException {
      image = null;
    }
    setState(() {
      qrImg = image;
    });
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
