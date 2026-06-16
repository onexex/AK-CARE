class CommunityPost {
  final int id;
  final dynamic userId;
  final String content;
  final String status;
  final String createdAt;
  final int likeCount;
  final bool likedByMe;
  final int commentCount;
  final CommunityUser user;
  final List<String> images;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.likeCount,
    required this.likedByMe,
    required this.commentCount,
    required this.user,
    required this.images,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      content: json['content'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] ?? '',
      likeCount: json['like_count'] ?? 0,
      likedByMe: json['liked_by_me'] ?? false,
      commentCount: json['comment_count'] ?? 0,
      user: CommunityUser.fromJson(json['user'] ?? {}),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  CommunityPost copyWith({
    int? likeCount,
    bool? likedByMe,
    int? commentCount,
  }) {
    return CommunityPost(
      id: id,
      userId: userId,
      content: content,
      status: status,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
      commentCount: commentCount ?? this.commentCount,
      user: user,
      images: images,
    );
  }
}

class CommunityUser {
  final dynamic id;
  final String contact;
  final String fullName;

  CommunityUser({
    required this.id,
    required this.contact,
    required this.fullName,
  });

  factory CommunityUser.fromJson(Map<String, dynamic> json) {
    return CommunityUser(
      id: json['id'] ?? '',
      contact: json['contact'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }
}

class CommunityComment {
  final int id;
  final int postId;
  final dynamic userId;
  final String comment;
  final String createdAt;
  final CommunityUser user;
  final List<CommunityReply> replies;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    required this.user,
    required this.replies,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] ?? 0,
      postId: json['post_id'] ?? 0,
      userId: json['user_id'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] ?? '',
      user: CommunityUser.fromJson(json['user'] ?? {}),
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((r) => CommunityReply.fromJson(r))
          .toList(),
    );
  }
}

class CommunityReply {
  final int id;
  final int commentId;
  final dynamic userId;
  final String reply;
  final String createdAt;
  final CommunityUser user;

  CommunityReply({
    required this.id,
    required this.commentId,
    required this.userId,
    required this.reply,
    required this.createdAt,
    required this.user,
  });

  factory CommunityReply.fromJson(Map<String, dynamic> json) {
    return CommunityReply(
      id: json['id'] ?? 0,
      commentId: json['comment_id'] ?? 0,
      userId: json['user_id'] ?? '',
      reply: json['reply'] ?? '',
      createdAt: json['created_at'] ?? '',
      user: CommunityUser.fromJson(json['user'] ?? {}),
    );
  }
}

class CommunityNotification {
  final int id;
  final String type;
  final int postId;
  final int? commentId;
  final bool isRead;
  final String createdAt;
  final CommunityUser fromUser;
  final String postPreview;

  CommunityNotification({
    required this.id,
    required this.type,
    required this.postId,
    this.commentId,
    required this.isRead,
    required this.createdAt,
    required this.fromUser,
    required this.postPreview,
  });

  factory CommunityNotification.fromJson(Map<String, dynamic> json) {
    return CommunityNotification(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      postId: json['post_id'] ?? 0,
      commentId: json['comment_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
      fromUser: CommunityUser.fromJson(json['from_user'] ?? {}),
      postPreview: json['post_preview'] ?? '',
    );
  }
}