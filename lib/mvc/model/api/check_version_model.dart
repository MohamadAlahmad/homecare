class CheckVersionModel {
  String latestVersion;
  String downloadUrl;

  CheckVersionModel({
    required this.latestVersion,
    required this.downloadUrl,
  });

  factory CheckVersionModel.fromJson(Map<String, dynamic> json) {
    return CheckVersionModel(
      latestVersion: json['latestVersion'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'latestVersion': latestVersion,
      'downloadUrl': downloadUrl,
    };
  }
}