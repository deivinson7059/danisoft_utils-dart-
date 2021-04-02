# danisoft_utils

This package helps to manage the transitions between screens in an elegant and simple way, it also helps the creation of jwt ...!

# Available ** Master Class **

- PageRouteTransition (manage transitions between screens in an elegant and easy way)
- JwtClient (generate un Jwt)
- scan QR (Leer Qr Code)  
   `final content = await QrUtils.scanQR;`
- Generate QR
  `Image image = await QrUtils.generateQR(content);`
  Note:
  Requires at least SDK 21 (Android 5.0). Requires at least iOS 9.
  iOS Integration
  ```<key>io.flutter.embedded_views_preview</key>
  <true/>
  <key>NSCameraUsageDescription</key>
  <string>This app needs camera access to scan QR codes</string>
  ```
