import '../../../core/errors/bank_error.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/error_mapper.dart';
import '../domain/account.dart';

class AccountRepository {
  final ApiClient _apiClient;

  AccountRepository(this._apiClient);

  Future<Account> getPrimaryAccount() async {
    try {
      final response = await _apiClient.dio.get('/accounts/primary');
      return Account.fromJson(response.data);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
