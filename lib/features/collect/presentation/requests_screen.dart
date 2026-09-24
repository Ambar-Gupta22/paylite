import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/money.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/async_value_view.dart';
import '../domain/collect_request.dart';
import '../state/collect_provider.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsState = ref.watch(collectRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Requests'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(collectRequestsProvider),
          ),
        ],
      ),
      body: AsyncValueView(
        value: requestsState,
        onRetry: () => ref.invalidate(collectRequestsProvider),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (requests) {
          final pending = requests
              .where((r) => r.status == CollectStatus.pending)
              .toList();

          if (pending.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Requests you receive will appear here.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _RequestCard(request: pending[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRequestSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Request'),
      ),
    );
  }

  void _showCreateRequestSheet(BuildContext context, WidgetRef ref) {
    // A simple bottom sheet to create a request
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: const _CreateRequestForm(),
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  final CollectRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${request.requesterVpa} is requesting',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  AppDateFormat.format(request.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              MoneyFormatter.formatPaise(request.amountPaise),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (request.note != null && request.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '"${request.note}"',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    ref
                        .read(collectRequestsProvider.notifier)
                        .declineRequest(request.id);
                  },
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    context.push(
                      Uri(
                        path: '/pay',
                        queryParameters: {
                          'vpa': request.requesterVpa,
                          'amount': request.amountPaise.toString(),
                        },
                      ).toString(),
                    );
                  },
                  child: const Text('Pay'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateRequestForm extends ConsumerStatefulWidget {
  const _CreateRequestForm();

  @override
  ConsumerState<_CreateRequestForm> createState() => _CreateRequestFormState();
}

class _CreateRequestFormState extends ConsumerState<_CreateRequestForm> {
  final _vpa = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Request Money', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: _vpa,
          decoration: const InputDecoration(
            labelText: 'Payer VPA',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (₹)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _note,
          decoration: const InputDecoration(
            labelText: 'Note (Optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            final amt = double.tryParse(_amount.text);
            if (amt != null && _vpa.text.isNotEmpty) {
              ref
                  .read(collectRequestsProvider.notifier)
                  .createRequest(_vpa.text, (amt * 100).round(), _note.text);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Send Request'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
