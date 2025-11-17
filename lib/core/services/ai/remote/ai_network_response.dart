import '../ai_response.dart';

class AIRemoteResponse implements AIResponse {
  @override
  final bool isDone = true;
  final List<Candidate> candidates;
  final UsageMetadata usageMetadata;
  final String modelVersion;
  final String responseId;

  @override
  String get responseText => candidates.first.content.parts.first.text;

  AIRemoteResponse({
    required this.candidates,
    required this.usageMetadata,
    required this.modelVersion,
    required this.responseId,
  });

  factory AIRemoteResponse.fromJson(Map<String, dynamic> json) =>
      AIRemoteResponse(
        candidates: (json['candidates'] as List)
            .map((e) => Candidate.fromJson(e))
            .toList(),
        usageMetadata: UsageMetadata.fromJson(json['usageMetadata']),
        modelVersion: json['modelVersion'] ?? '',
        responseId: json['responseId'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'candidates': candidates.map((e) => e.toJson()).toList(),
    'usageMetadata': usageMetadata.toJson(),
    'modelVersion': modelVersion,
    'responseId': responseId,
  };

  static AIRemoteResponse dummyAIResponse() {
    return AIRemoteResponse(
      candidates: [
        Candidate(
          content: Content(
            parts: [
              ContentPart(
                text: "AI learns from data to make decisions or predictions.",
              ),
            ],
            role: "model",
          ),
          finishReason: "STOP",
          avgLogprobs: -0.0865,
        ),
      ],
      usageMetadata: UsageMetadata(
        promptTokenCount: 8,
        candidatesTokenCount: 11,
        totalTokenCount: 19,
        promptTokensDetails: [TokenDetail(modality: "TEXT", tokenCount: 8)],
        candidatesTokensDetails: [
          TokenDetail(modality: "TEXT", tokenCount: 11),
        ],
      ),
      modelVersion: "gemini-2.0-flash",
      responseId: "dummy-response-id",
    );
  }

  @override
  bool get isThinking => false;

  @override
  String get thinkingText => '';

  @override
  bool get shouldShowThink => false;
}

class Candidate {
  final Content content;
  final String finishReason;
  final double? avgLogprobs;

  Candidate({
    required this.content,
    required this.finishReason,
    this.avgLogprobs,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) => Candidate(
    content: Content.fromJson(json['content']),
    finishReason: json['finishReason'] ?? '',
    avgLogprobs: (json['avgLogprobs'] != null)
        ? (json['avgLogprobs'] as num).toDouble()
        : null,
  );

  Map<String, dynamic> toJson() => {
    'content': content.toJson(),
    'finishReason': finishReason,
    'avgLogprobs': avgLogprobs,
  };
}

class Content {
  final List<ContentPart> parts;
  final String role;

  Content({required this.parts, required this.role});

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    parts: (json['parts'] as List).map((e) => ContentPart.fromJson(e)).toList(),
    role: json['role'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'parts': parts.map((e) => e.toJson()).toList(),
    'role': role,
  };
}

class ContentPart {
  final String text;

  ContentPart({required this.text});

  factory ContentPart.fromJson(Map<String, dynamic> json) =>
      ContentPart(text: json['text'] ?? '');

  Map<String, dynamic> toJson() => {'text': text};
}

class UsageMetadata {
  final int promptTokenCount;
  final int candidatesTokenCount;
  final int totalTokenCount;
  final List<TokenDetail> promptTokensDetails;
  final List<TokenDetail> candidatesTokensDetails;

  UsageMetadata({
    required this.promptTokenCount,
    required this.candidatesTokenCount,
    required this.totalTokenCount,
    required this.promptTokensDetails,
    required this.candidatesTokensDetails,
  });

  factory UsageMetadata.fromJson(Map<String, dynamic> json) => UsageMetadata(
    promptTokenCount: json['promptTokenCount'] ?? 0,
    candidatesTokenCount: json['candidatesTokenCount'] ?? 0,
    totalTokenCount: json['totalTokenCount'] ?? 0,
    promptTokensDetails: (json['promptTokensDetails'] as List)
        .map((e) => TokenDetail.fromJson(e))
        .toList(),
    candidatesTokensDetails: (json['candidatesTokensDetails'] as List)
        .map((e) => TokenDetail.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'promptTokenCount': promptTokenCount,
    'candidatesTokenCount': candidatesTokenCount,
    'totalTokenCount': totalTokenCount,
    'promptTokensDetails': promptTokensDetails.map((e) => e.toJson()).toList(),
    'candidatesTokensDetails': candidatesTokensDetails
        .map((e) => e.toJson())
        .toList(),
  };
}

class TokenDetail {
  final String modality;
  final int tokenCount;

  TokenDetail({required this.modality, required this.tokenCount});

  factory TokenDetail.fromJson(Map<String, dynamic> json) => TokenDetail(
    modality: json['modality'] ?? '',
    tokenCount: json['tokenCount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'modality': modality,
    'tokenCount': tokenCount,
  };
}
