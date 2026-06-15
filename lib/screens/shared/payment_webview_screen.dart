import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:aerocrew/constants.dart';
import 'package:aerocrew/screens/shared/payment_success_screen.dart';

class PaymentWebviewScreen extends StatefulWidget {
  final String checkoutUrl;
  final double amount;
  final String plan;
  final String transactionId;

  const PaymentWebviewScreen({
    super.key,
    required this.checkoutUrl,
    required this.amount,
    required this.plan,
    required this.transactionId,
  });

  @override
  State<PaymentWebviewScreen> createState() =>
      _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState
    extends State<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
          onNavigationRequest: (request) {
            // Detect success redirect
            if (request.url.contains('payment-success')) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentSuccessScreen(
                    amount: widget.amount,
                    plan: widget.plan,
                    transactionId: widget.transactionId,
                  ),
                ),
              );
              return NavigationDecision.prevent;
            }
            // Detect cancel/failure
            if (request.url.contains('payment-failed') ||
                request.url.contains('payment-cancelled')) {
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AeroColors.navy,
      appBar: AppBar(
        backgroundColor: AeroColors.navyCard,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AeroColors.navy,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AeroColors.divider, width: 0.5),
            ),
            child: const Icon(Icons.close,
                color: Colors.white, size: 18),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Secure payment',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            Text('Powered by CHIP',
                style: TextStyle(
                    fontSize: 11,
                    color: AeroColors.grey)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AeroColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: AeroColors.success.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Row(
              children: const [
                Icon(Icons.lock, size: 10, color: AeroColors.success),
                SizedBox(width: 4),
                Text('SSL secured',
                    style: TextStyle(
                        fontSize: 10,
                        color: AeroColors.success,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            Container(
              color: AeroColors.navy,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AeroColors.amber),
                    SizedBox(height: 16),
                    Text('Loading secure payment...',
                        style: TextStyle(
                            color: AeroColors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}