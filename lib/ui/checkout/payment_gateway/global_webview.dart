import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterrestaurant/api/ps_url.dart';
import 'package:flutterrestaurant/config/ps_colors.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:webview_flutter/webview_flutter.dart';



class GlobalWebView extends StatefulWidget {
  const GlobalWebView({
    required this.token,
    required this.onHppResponse
  });
  final String token;
  final Function(String)? onHppResponse;
  @override
  _GlobalWebViewState createState() => _GlobalWebViewState();
}

class _GlobalWebViewState extends State<GlobalWebView> {
  late final  WebViewController? _controller;
  HttpServer? _httpServer;
  late String deviceIp;
  @override
  void initState() {
    super.initState();

    // Get the IP address of the development machine
    _getIpAddress().then((String ipAddress) {
      // Start the HTTP server
      final shelf.Handler handler = const shelf.Pipeline()
          .addMiddleware(shelf.logRequests())
          .addHandler(_receiveHandler);
      deviceIp = ipAddress;
      io.serve(handler, ipAddress, 8080).then((HttpServer server) {
        setState(() {
          _httpServer = server;
        });
      });
    });
  }
  Future<String> _getIpAddress() async {
    // Get the IP address of the first non-loopback network interface
    for (NetworkInterface interface in await NetworkInterface.list()) {
      for (InternetAddress addr in interface.addresses) {
        if (!addr.isLoopback) {
          return addr.address;
        }
      }
    }
    // If no non-loopback address is found, fallback to localhost
    return 'localhost';
  }
  @override
  void dispose() {
    // Close the HTTP server when the widget is disposed
    _httpServer?.close();
    super.dispose();
  }


  Future<shelf.Response> _receiveHandler(shelf.Request request) async {
    if (request.method == 'POST') {
      // Handle the incoming POST data
      final String body = await request.readAsString();
      // Decode the JSON data into a Dart object
      String decodedData = Uri.decodeFull(body);

      // Remove the "hppResponse=" prefix from the string
      decodedData = decodedData.replaceFirst('hppResponse=', '');
      if (widget.onHppResponse != null) {
        widget.onHppResponse!(decodedData);
      }
      Navigator.pop(context);
      return shelf.Response.ok('Data received successfully!');
    } else {
      // Respond with a method not allowed message for other request methods
      return shelf.Response(HttpStatus.methodNotAllowed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: PsColors.mainColor,
      ),
      body: Stack(
        children: <Widget>[
              WebView(
            initialUrl: PsUrl.ps_global_payment_hpp_url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
            },
            onPageFinished: (String url) {
              if (_controller != null) {
                // Call a JavaScript function on the hosted page to establish communication
                _controller!.evaluateJavascript('''
                \$(document).ready(function() {
            RealexHpp.setHppUrl("${PsUrl.ps_global_payment_url}");
            var jsonObject = JSON.parse(${widget.token});
            RealexHpp.embedded.init("payButtonId", "iframeId", "http://$deviceIp:8080/", jsonObject );
            \$("#payButtonId").click();
        });
                ''');
              }
            },
                onPageStarted: (String url) {
                },
          ),
        ],
      ),
    );
  }
}
