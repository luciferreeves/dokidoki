import 'package:github/github.dart';

class GithubProfile {
  GithubProfile(this.token);

  final String token;

  Future<User> getProfile() async {
    final github = GitHub(auth: Authentication.withToken(token));
    try {
      final user = await github.users.getCurrentUser();
      return user;
    } catch (e) {
      rethrow;
    }
  }
}
