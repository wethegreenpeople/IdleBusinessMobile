class Message {
  int id;
  String messageBody;
  int receivingBusinessId;
  bool read;

  Message({int id, String messageBody, int receivingBusinessId, bool read}) {
    this.id = id;
    this.messageBody = messageBody;
    this.receivingBusinessId = receivingBusinessId;
    this.read = read;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    var message = Message(
      id: json["Id"],
      messageBody: json["MessageBody"],
      receivingBusinessId: json["ReceivingBusinessId"],
      read: json["ReadByBusiness"],
    );

    return message;
  }
}
