import 'package:equatable/equatable.dart';

/// Portfolio Link Model
class PortfolioLink extends Equatable {
  final String id;
  final String platform; // 'github', 'linkedin', 'behance', 'website', etc.
  final String url;
  final String? username;
  final String? description;

  const PortfolioLink({
    required this.id,
    required this.platform,
    required this.url,
    this.username,
    this.description,
  });

  PortfolioLink copyWith({
    String? id,
    String? platform,
    String? url,
    String? username,
    String? description,
  }) {
    return PortfolioLink(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      url: url ?? this.url,
      username: username ?? this.username,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'url': url,
      'username': username,
      'description': description,
    };
  }

  factory PortfolioLink.fromJson(Map<String, dynamic> json) {
    return PortfolioLink(
      id: json['id'] as String,
      platform: json['platform'] as String,
      url: json['url'] as String,
      username: json['username'] as String?,
      description: json['description'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, platform, url, username, description];
}

/// Location Preference Enum
enum LocationPreference {
  remote,
  onsite,
  hybrid;

  String get displayName {
    switch (this) {
      case LocationPreference.remote:
        return 'Remote';
      case LocationPreference.onsite:
        return 'Onsite';
      case LocationPreference.hybrid:
        return 'Hybrid';
    }
  }
}

/// CV Parse Status Enum
enum CVParseStatus {
  pending,
  processing,
  complete,
  failed;

  String get displayName {
    switch (this) {
      case CVParseStatus.pending:
        return 'Pending';
      case CVParseStatus.processing:
        return 'Processing';
      case CVParseStatus.complete:
        return 'Complete';
      case CVParseStatus.failed:
        return 'Failed';
    }
  }
}
