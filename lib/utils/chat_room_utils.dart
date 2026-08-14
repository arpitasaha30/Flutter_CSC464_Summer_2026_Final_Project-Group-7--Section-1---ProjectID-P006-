class ChatRoomUtils {
  /// Deterministically generates the same chat room id regardless of the
  /// order the two user ids are passed in, e.g.:
  ///   generateChatRoomId('abc123', 'xyz789') == 'abc123_xyz789'
  ///   generateChatRoomId('xyz789', 'abc123') == 'abc123_xyz789'
  static String generateChatRoomId(String userIdA, String userIdB) {
    final ids = [userIdA, userIdB]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
