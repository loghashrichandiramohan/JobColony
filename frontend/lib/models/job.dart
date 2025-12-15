class JobModel {
  final int jobId;
  final String title;
  final String? company;
  final String? location;
  final double score;
  final String? url;

  JobModel({
    required this.jobId,
    required this.title,
    this.company,
    this.location,
    required this.score,
    this.url,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      jobId: json['job_id'] as int,
      title: json['title'] as String,
      company: json['company'] as String?,
      location: json['location'] as String?,
      score: (json['score'] as num).toDouble(),
      url: json['url'] as String?,
    );
  }
}
