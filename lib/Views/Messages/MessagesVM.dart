import 'package:idlebusiness_mobile/Models/Message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:idlebusiness_mobile/Stores/BusinessStore.dart';

class MessagesVM {
  Future<List<Message>> getMessagesForCurrentBusiness() async {
    final prefs = await SharedPreferences.getInstance();
    final businessId = prefs.getString('businessId');

    return await Business().getBusinessMessages(businessId);
  }
}
