import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/secure_screen.dart';
import '../state/vpa_lookup_provider.dart';
import '../state/payment_flow_notifier.dart';

class PayScreen extends ConsumerStatefulWidget {
  final String? initialVpa;
  final String? initialName;
  final String? initialAmount;

  const PayScreen({
    super.key,
    this.initialVpa,
    this.initialName,
    this.initialAmount,
  });

  @override
  ConsumerState<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends ConsumerState<PayScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _vpaController;
  late final TextEditingController _amountController;
  final _noteController = TextEditingController();

  bool _isVpaVerified = false;

  @override
  void initState() {
    super.initState();
    _vpaController = TextEditingController(text: widget.initialVpa);

    // If QR provided an amount in paise, convert it to rupees for the text field
    String displayAmount = '';
    if (widget.initialAmount != null) {
      final paise = int.tryParse(widget.initialAmount!);
      if (paise != null) {
        displayAmount = (paise / 100).toStringAsFixed(0);
      }
    }
    _amountController = TextEditingController(text: displayAmount);

    // If we have an initial VPA from QR, we should verify it immediately
    if (widget.initialVpa != null && widget.initialVpa!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _verifyVpa();
      });
    }
  }

  @override
  void dispose() {
    _vpaController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _verifyVpa() async {
    if (Validators.validateVpa(_vpaController.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid UPI ID')),
      );
      return;
    }

    // Unfocus keyboard
    FocusScope.of(context).unfocus();

    // Read the provider asynchronously
    try {
      await ref.read(vpaLookupProvider(_vpaController.text).future);
      setState(() => _isVpaVerified = true);
    } catch (e) {
      setState(() => _isVpaVerified = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No account found for this UPI ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;

    final vpa = ref.read(vpaLookupProvider(_vpaController.text)).valueOrNull;
    if (vpa == null) return;

    final amountRupees = double.parse(
      _amountController.text.replaceAll(',', ''),
    );
    final amountPaise = (amountRupees * 100).round();

    ref
        .read(paymentFlowProvider.notifier)
        .initFlow(_vpaController.text, amountPaise, _noteController.text, vpa);

    context.push('/pay/review');
  }

  @override
  Widget build(BuildContext context) {
    final vpaState = ref.watch(vpaLookupProvider(_vpaController.text));

    // Lock amount field if it was provided by a fixed QR code
    final isAmountLocked =
        widget.initialAmount != null && widget.initialAmount!.isNotEmpty;

    return SecureScreen(
      child: Scaffold(
        appBar: AppBar(title: const Text('Pay Contact')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _vpaController,
                  decoration: InputDecoration(
                    labelText: 'UPI ID / VPA',
                    border: const OutlineInputBorder(),
                    suffixIcon: vpaState.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : TextButton(
                            onPressed: _verifyVpa,
                            child: const Text('Verify'),
                          ),
                  ),
                  validator: Validators.validateVpa,
                  onChanged: (_) {
                    if (_isVpaVerified) setState(() => _isVpaVerified = false);
                  },
                  enabled: !vpaState.isLoading,
                ),
                if (_isVpaVerified && vpaState.valueOrNull != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        vpaState.valueOrNull!.verifiedName,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.validateAmount,
                  readOnly: isAmountLocked,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Add a note (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isVpaVerified ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
