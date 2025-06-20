class ChatMessage {
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false, // Default to unread
  });

  // Convert Dart object to Firestore-compatible map
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  // Factory constructor to create a ChatMessage from Firestore data
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false, // Default to false if field doesn't exist
    );
  }

  // Helper method to create a copy with updated fields
  ChatMessage copyWith({
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return ChatMessage(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  // Helper method to mark message as read
  ChatMessage markAsRead() {
    return copyWith(isRead: true);
  }

  // Helper method to mark message as unread
  ChatMessage markAsUnread() {
    return copyWith(isRead: false);
  }
}