import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hiredev/services/apiServices.dart';

class CompanyServices {
  static Future<dynamic> getCompanies(
    String companyName,
    String idRoleEmployer,
    int current,
    int pageSize,
  ) async {
    final response = await ApiService().get(
      dotenv.env['API_URL']! +
          'users/company?current=$current&pageSize=$pageSize&query[role]=$idRoleEmployer&query[company_name]=$companyName',
    );
    return response;
  }

  static Future<dynamic> getRoleEmployer() async {
    final response = await ApiService().get(
      dotenv.env['API_URL']! + 'role/employer',
    );
    return response;
  }
}
