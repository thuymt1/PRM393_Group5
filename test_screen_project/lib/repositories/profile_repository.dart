import '../models/profile_model.dart';
import '../core/network/api_client.dart';

class ProfileRepository {
  final _api = ApiClient();

  Future<ProfileModel> getMyProfile() async {
    final json = await _api.get('/profiles/me');
    return ProfileModel.fromJson(json);
  }

  Future<ProfileModel> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final updates = <String, String>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    final json = await _api.put('/profiles/me', updates);
    return ProfileModel.fromJson(json);
  }
}
