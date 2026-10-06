// Models for Gemini AI Business Assistant (Phase 8).

class AiRecommendation {
  final String id;
  final String category;
  final String title;
  final String description;
  final String actionLabel;
  final String route;

  const AiRecommendation({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.route,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      id: json['id'] as String? ?? 'rec_gen',
      category: (json['category'] as String? ?? 'OPERATIONS').toUpperCase(),
      title: json['title'] as String? ?? 'Review Store Operations',
      description: json['description'] as String? ?? '',
      actionLabel: json['actionLabel'] as String? ?? 'View Details',
      route: json['route'] as String? ?? '/dashboard',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'description': description,
        'actionLabel': actionLabel,
        'route': route,
      };
}

class AiCoachResponse {
  final String summary;
  final List<String> insights;
  final List<AiRecommendation> recommendations;
  final List<String> warnings;
  final String confidence;
  final String disclaimer;
  final DateTime timestamp;

  const AiCoachResponse({
    required this.summary,
    required this.insights,
    required this.recommendations,
    required this.warnings,
    required this.confidence,
    required this.disclaimer,
    required this.timestamp,
  });

  factory AiCoachResponse.fromJson(Map<String, dynamic> json) {
    return AiCoachResponse(
      summary: json['summary'] as String? ?? '',
      insights: (json['insights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => AiRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      confidence: json['confidence'] as String? ?? 'HIGH',
      disclaimer: json['disclaimer'] as String? ??
          'Decision-support guidance only. Not financial or business guarantees.',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'insights': insights,
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
        'warnings': warnings,
        'confidence': confidence,
        'disclaimer': disclaimer,
        'timestamp': timestamp.toIso8601String(),
      };
}

class AiDailyBrief {
  final String businessId;
  final String businessName;
  final DateTime generatedAt;
  final String summary;
  final List<String> observations;
  final List<String> opportunities;
  final List<String> warnings;
  final List<AiRecommendation> recommendations;
  final String confidence;
  final String disclaimer;

  const AiDailyBrief({
    required this.businessId,
    required this.businessName,
    required this.generatedAt,
    required this.summary,
    required this.observations,
    required this.opportunities,
    required this.warnings,
    required this.recommendations,
    required this.confidence,
    required this.disclaimer,
  });

  factory AiDailyBrief.fromJson(Map<String, dynamic> json) {
    return AiDailyBrief(
      businessId: json['businessId'] as String? ?? '',
      businessName: json['businessName'] as String? ?? 'Nirmaan Business',
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      summary: json['summary'] as String? ?? '',
      observations: (json['observations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      opportunities: (json['opportunities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => AiRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      confidence: json['confidence'] as String? ?? 'HIGH',
      disclaimer: json['disclaimer'] as String? ??
          'Decision-support guidance only. Not financial or business guarantees.',
    );
  }

  Map<String, dynamic> toJson() => {
        'businessId': businessId,
        'businessName': businessName,
        'generatedAt': generatedAt.toIso8601String(),
        'summary': summary,
        'observations': observations,
        'opportunities': opportunities,
        'warnings': warnings,
        'recommendations': recommendations.map((r) => r.toJson()).toList(),
        'confidence': confidence,
        'disclaimer': disclaimer,
      };
}

class AiChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final AiCoachResponse? structuredResponse;

  const AiChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.structuredResponse,
  });
}
