import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/pin_pad.dart';
import '../state/payment_flow_notifier.dart';

class PinScreen extends ConsumerStatefulWidget {
  const PinScreen({super.key});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  String _pin = '';

  @override
  void initState() {
    super.initState();
    // In Phase 4, we will apply FLAG_SECURE here via platform channel or flutter_windowmanager
  }

  void _onNumberTapped(String number) {
    if (_pin.length < 6) {
      setState(() => _pin += number);
    }
  }

  void _onDeleteTapped() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  void _onSubmit() {
    if (_pin.length >= 4 && _pin.length <= 6) {
      // Hash PIN before sending
      final bytes = utf8.encode(_pin);
      final digest = sha256.convert(bytes);
      final pinHash = digest.toString();
      
      ref.read(paymentFlowProvider.notifier).pay(pinHash);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(paymentFlowProvider);

    // Listen to flow state to navigate to status screen when done or error
    ref.listen<PaymentFlowState>(paymentFlowProvider, (previous, next) {
      if (next.stage == FlowStage.completed && next.finalPayment != null) {
        context.pushReplacement('/pay/status/${next.finalPayment!.id}');
      } else if (next.stage == FlowStage.error && next.error != null) {
        // If there's an error in payment, we still go to status screen but it will show failed
        // Wait, if we want to show error directly, we could show a snackbar.
        // Actually, the status screen can fetch the status or we can just pass the error.
        // Let's show a snackbar and allow them to retry the PIN.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!.userMessage),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _pin = '');
        ref.read(paymentFlowProvider.notifier).cancelToReview();
      }
    });

    final isProcessing = flowState.stage == FlowStage.processing;

    return WillPopScope(
      onWillPop: () async {
        if (isProcessing) return false;
        ref.read(paymentFlowProvider.notifier).cancelToReview();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Enter UPI PIN'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (!isProcessing) {
                ref.read(paymentFlowProvider.notifier).cancelToReview();
                context.pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Text(
                'Enter 4-6 digit UPI PIN',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _pin.length 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300],
                    ),
                  );
                }),
              ),
              const Spacer(),
              if (isProcessing)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                )
              else
                PinPad(
                  currentLength: _pin.length,
                  onNumberTapped: _onNumberTapped,
                  onDeleteTapped: _onDeleteTapped,
                  onSubmitTapped: _onSubmit,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
