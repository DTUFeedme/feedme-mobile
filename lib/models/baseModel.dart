class BaseModel {
  const BaseModel();

  factory BaseModel.fromJson(json) => BaseModel();
  Map<String, dynamic> toJson() => {};
}
