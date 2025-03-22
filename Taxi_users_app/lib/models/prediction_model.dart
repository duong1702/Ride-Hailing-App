class PredictionModel {
  String? place_id;
  String? description;


  PredictionModel({this.place_id, this.description});

  // Hàm khởi tạo từ JSON, dựa trên cấu trúc của Goong Places API
  PredictionModel.fromJson(Map<String, dynamic> json) {
    place_id = json["place_id"];
    description = json["description"];
  }


}