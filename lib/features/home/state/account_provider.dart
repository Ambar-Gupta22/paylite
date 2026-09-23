import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../domain/account.dart';

final accountProvider = AsyncNotifierProvider<AccountNotifier, Account>(() {
  return AccountNotifier();
});

class AccountNotifier extends AsyncNotifier<Account> {
  @override
  Future<Account> build() async {
    final repo = ref.watch(accountRepositoryProvider);
    return repo.getPrimaryAccount();
  }
}
