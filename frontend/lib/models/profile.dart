class ProfileModel {
  final int id;
  final String rawText;

  ProfileModel({
    required this.id,
    required this.rawText,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      rawText: json['raw_text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'raw_text': rawText,
    };
  }
}
