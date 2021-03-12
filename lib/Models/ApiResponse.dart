class ApiResponse {
  bool success;
  String returnValue;

  ApiResponse(bool success, String returnValue) {
    this.success = success;
    this.returnValue = returnValue;
  }
}
