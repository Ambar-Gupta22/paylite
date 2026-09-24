import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/money.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/payment_tile.dart';
import '../domain/payment.dart';
import '../state/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final filter = ref.watch(historyFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(historyProvider),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, VPA or note',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(historyFilterProvider.notifier)
                        .state = HistoryFilter(
                      query: value.isEmpty ? null : value,
                      type: filter.type,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: filter.type == null,
                      onSelected: (_) {
                        ref.read(historyFilterProvider.notifier).state =
                            HistoryFilter(query: filter.query, type: null);
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Sent'),
                      selected: filter.type == 'sent',
                      onSelected: (_) {
                        ref.read(historyFilterProvider.notifier).state =
                            HistoryFilter(query: filter.query, type: 'sent');
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Received'),
                      selected: filter.type == 'received',
                      onSelected: (_) {
                        ref
                            .read(historyFilterProvider.notifier)
                            .state = HistoryFilter(
                          query: filter.query,
                          type: 'received',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: AsyncValueView(
        value: historyState,
        onRetry: () => ref.invalidate(historyProvider),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              return PaymentTile(payment: payments[index]);
            },
          );
        },
      ),
    );
  }
}
