import 'package:flutter/material.dart';

class PinPad extends StatelessWidget {
  final Function(String) onNumberTapped;
  final VoidCallback onDeleteTapped;
  final VoidCallback onSubmitTapped;
  final int currentLength;
  final int minLength;
  final int maxLength;

  const PinPad({
    super.key,
    required this.onNumberTapped,
    required this.onDeleteTapped,
    required this.onSubmitTapped,
    required this.currentLength,
    this.minLength = 4,
    this.maxLength = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(context, (i * 3 + 1).toString()),
              _buildButton(context, (i * 3 + 2).toString()),
              _buildButton(context, (i * 3 + 3).toString()),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              Icons.backspace_outlined,
              onDeleteTapped,
            ),
            _buildButton(context, '0'),
            _buildSubmitButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String number) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: TextButton(
          onPressed: () {
            if (currentLength < maxLength) {
              onNumberTapped(number);
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16),
            shape: const CircleBorder(),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              number,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 32,
          tooltip: 'Delete',
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final isEnabled = currentLength >= minLength && currentLength <= maxLength;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: IconButton(
          onPressed: isEnabled ? onSubmitTapped : null,
          icon: const Icon(Icons.check_circle),
          color: Theme.of(context).colorScheme.primary,
          iconSize: 48,
          tooltip: 'Submit PIN',
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
