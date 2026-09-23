import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../domain/payment.dart';

class HistoryFilter {
  final String? query;
  final String? type; // null for all, 'sent', 'received'

  const HistoryFilter({this.query, this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryFilter &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          type == other.type;

  @override
  int get hashCode => query.hashCode ^ type.hashCode;
}

final historyFilterProvider = StateProvider<HistoryFilter>((ref) {
  return const HistoryFilter();
});

final historyProvider = AsyncNotifierProvider<HistoryNotifier, List<Payment>>(() {
  return HistoryNotifier();
});

class HistoryNotifier extends AsyncNotifier<List<Payment>> {
  @override
  Future<List<Payment>> build() async {
    final filter = ref.watch(historyFilterProvider);
    final repo = ref.watch(paymentRepositoryProvider);
    
    // In a real app we'd handle pagination (infinite scroll), but for mock we'll just fetch the first page
    final result = await repo.getHistory(
      limit: 50,
      query: filter.query,
      filter: filter.type,
    );
    
    return result.items;
  }
}
