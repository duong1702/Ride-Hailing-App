//thay vì xử lý JSON từ API mỗi lần, chỉ cần xử lý một lần và lưu trữ vào đối tượng DirectionDetails để dễ quản lý và tái sử dụng

class DirectionDetails
{
  String? distanceTextString; //khoảng cách của chuyến đi
  String? durationTextString;  //thời gian dự kiến di chuyển
  int? distanceValueDigits;  //Khoảng cách của chuyến đi tính theo mét (số liệu thực tế dùng để tính toán or so sánh chi tiết và tính xác)
  int? durationValueDigits;  //Thời gian dự kiến tính theo giây
  String? encodedPoints;  //Chuỗi ký tự chứa mã hóa của các điểm đường đi theo định dạng polyline

  DirectionDetails({
    this.distanceTextString,
    this.durationTextString,
    this.distanceValueDigits,
    this.durationValueDigits,
    this.encodedPoints,
  });
}
