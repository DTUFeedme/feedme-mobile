class UserModel {
  String email;
  String authToken;

  UserModel(
    this.email,
    this.authToken,
  );

  void setAuthToken(String token) {
    authToken = token;
  }
}