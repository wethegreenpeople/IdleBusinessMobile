class Message {
  int id;
  String messageBody;
  int receivingBusinessId;

  Message({int id, String messageBody, int receivingBusinessId}) {
    this.id = id;
    this.messageBody = messageBody;
    this.receivingBusinessId = receivingBusinessId;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    var message = Message(
      id: json["Id"],
      messageBody: json["MessageBody"],
      receivingBusinessId: json["ReceivingBusinessId"],
    );

    return message;
  }
}
