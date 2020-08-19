class UserModel {
  String email;
  String authToken;
  String refreshToken;

  UserModel(this.email, this.authToken, {this.refreshToken});

  void setAuthToken(String token) {
    authToken = token;
  }
}
