import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';

final referenceApiServiceProvider = Provider<ReferenceApiService>((ref) {
  return ReferenceApiService(dioClient: ref.watch(dioClientProvider));
});

class ReferenceApiService {
  ReferenceApiService({required DioClient dioClient}) : _dioClient = dioClient;
  final DioClient _dioClient;

  Future<List<String>> getCities({String? q}) async {
    final response = await _dioClient.get<List<dynamic>>(
      '/api/v2/reference/serbia-cities',
      queryParameters: {if (q != null) 'q': q},
    );
    return response.data!.cast<String>();
  }
}
