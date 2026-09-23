import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../domain/collect_request.dart';
import '../../pay/domain/payment.dart';

final collectRequestsProvider = AsyncNotifierProvider<CollectRequestsNotifier, List<CollectRequest>>(() {
  return CollectRequestsNotifier();
});

class CollectRequestsNotifier extends AsyncNotifier<List<CollectRequest>> {
  @override
  Future<List<CollectRequest>> build() async {
    final repo = ref.watch(collectRepositoryProvider);
    return repo.getRequests();
  }

  Future<void> declineRequest(String id) async {
    final repo = ref.read(collectRepositoryProvider);
    await repo.declineRequest(id);
    // Optimistic update
    state = state.whenData((requests) => 
      requests.where((r) => r.id != id).toList()
    );
  }

  Future<void> createRequest(String vpa, int amountPaise, String? note) async {
    final repo = ref.read(collectRepositoryProvider);
    await repo.createRequest(payeeVpa: vpa, amountPaise: amountPaise, note: note);
    // Refresh list
    ref.invalidateSelf();
  }
}
