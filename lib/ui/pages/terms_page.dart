import 'package:flutter/material.dart';
import 'package:flutter_onboarding/ui/pages/widgets/loading_component.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsPage extends StatefulWidget {
  final String url;
  final String title;

  const TermsPage({Key? key, required this.url, required this.title})
      : super(key: key);

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool isLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
            Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url)).then((_) {
        setState(() {
          isLoading = false;
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading
          ? const LoadingComponent()
          : WebViewWidget(controller: _controller),
    );
  }
}
