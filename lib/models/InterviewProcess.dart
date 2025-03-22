class InterviewProcess {
  final String process;

  InterviewProcess({required this.process});

  factory InterviewProcess.fromJson(Map<String, dynamic> json) {
    return InterviewProcess(process: json['process']);
  }
}
