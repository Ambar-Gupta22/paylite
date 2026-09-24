import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/vpa.dart';

// Use a family to lookup a specific VPA
final vpaLookupProvider =
    AsyncNotifierProviderFamily<VpaLookupNotifier, Vpa, String>(
      () => VpaLookupNotifier(),
    );

class VpaLookupNotifier extends FamilyAsyncNotifier<Vpa, String> {
  @override
  Future<Vpa> build(String arg) async {
    final repo = ref.watch(vpaRepositoryProvider);
    return repo.verifyVpa(arg);
  }
}
