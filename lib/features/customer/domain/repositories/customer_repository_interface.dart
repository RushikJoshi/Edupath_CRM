import 'package:gtcrm/features/customer/data/models/customer_model.dart';

abstract class CustomerRepositoryInterface {
  Future<List<CustomerModel>> getCustomers({int page = 1, int limit = 10, String? search});
  Future<CustomerModel> getCustomer(String id);
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
  });
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
  });
  Future<void> deleteCustomer(String id);
}
