import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../state/session_provider.dart';
import '../../../core/errors/bank_error.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _pinController = TextEditingController();
  bool _obscurePin = true;

  @override
  void dispose() {
    _customerIdController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Clear keyboard
    FocusScope.of(context).unfocus();

    await ref.read(sessionProvider.notifier).login(
      _customerIdController.text.trim(),
      _pinController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes (success or error)
    ref.listen<AsyncValue<Session?>>(sessionProvider, (previous, next) {
      next.whenOrNull(
        error: (err, stack) {
          String message = 'Login failed';
          if (err is BankError) {
            message = err.userMessage;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        data: (session) {
          if (session != null) {
            // Login success, router will automatically redirect because it listens to sessionProvider
            context.go('/home'); 
          }
        },
      );
    });

    final sessionState = ref.watch(sessionProvider);
    final isLoading = sessionState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to PayLite',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage your money securely',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _customerIdController,
                    decoration: const InputDecoration(
                      labelText: 'Customer ID',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.validateCustomerId,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pinController,
                    obscureText: _obscurePin,
                    decoration: InputDecoration(
                      labelText: '4-6 Digit PIN',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePin = !_obscurePin),
                        tooltip: _obscurePin ? 'Show PIN' : 'Hide PIN',
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validatePin,
                    onFieldSubmitted: (_) => _submit(),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading 
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign In', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),
                  if (sessionState.hasError && !isLoading) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Failed to connect to server. Please try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    )
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
