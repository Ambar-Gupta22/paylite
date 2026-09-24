import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/bank_error.dart';

class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function() loading;
  final VoidCallback onRetry;

  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    required this.loading,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: value.when(
        data: data,
        loading: loading,
        error: (err, stack) {
          String message = 'An unexpected error occurred';
          if (err is BankError) {
            message = err.userMessage;
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
