import 'package:encryptor/encryptor.dart';
import 'package:just_chat_app/utils/constants.dart';

String encryptedAES(String text) {
  String encrypted = Encryptor.encrypt(key, text);
  return encrypted;
}

String decryptedAES(String text) {
  String decrypted = Encryptor.decrypt(key, text);
  return decrypted;
}
