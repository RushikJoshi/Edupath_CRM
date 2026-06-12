import '../api/customer_api.dart';
import '../models/customer_model.dart';
import '../services/storage_service.dart';

class CustomerRepository {
  CustomerRepository(this._api, this._storage);

  final CustomerApi _api;
  final StorageService _storage;

  Future<List<CustomerModel>> fetchAll({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final list = await _api.getCustomers(
      page: page,
      limit: limit,
      search: search,
    );
    // Apply branch filter for non-admin users
    final role = await _storage.getRole();
    final branchId = await _storage.getBranchId();

    if (role == null || role.toLowerCase().contains('admin')) return list;
    if (branchId == null || branchId.isEmpty) return list;

    return list.where((customer) => customer.branchId == branchId).toList();
  }

  Future<CustomerModel> getCustomer(String id) {
    return _api.getCustomer(id);
  }

  Future<CustomerModel> createCustomer({
    required String name,
    required String email,
    required String phone,
    required String companyName,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
  }) => _api.createCustomer(
    name: name,
    email: email,
    phone: phone,
    companyName: companyName,
    address: address,
    city: city,
    state: state,
    country: country,
    pincode: pincode,
  );

  Future<CustomerModel> updateCustomer(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
  }) => _api.updateCustomer(
    id,
    name: name,
    email: email,
    phone: phone,
    companyName: companyName,
    address: address,
    city: city,
    state: state,
    country: country,
    pincode: pincode,
  );

  Future<void> deleteCustomer(String id) => _api.deleteCustomer(id);
}
