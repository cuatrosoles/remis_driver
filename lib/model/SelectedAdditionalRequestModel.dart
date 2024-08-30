class SelectedAdditionalRequestModel {
  String? key;
  num? value;
  String? valueType;

  SelectedAdditionalRequestModel({this.key, this.value, this.valueType});

  SelectedAdditionalRequestModel.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
    valueType = json['value_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    data['value_type'] = this.valueType;
    return data;
  }
}
