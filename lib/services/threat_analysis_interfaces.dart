import '../models/threat_analysis.dart';

class ThreatMLPrediction {
  const ThreatMLPrediction({required this.label, required this.confidence});

  final String label;
  final double confidence;
}

/// Future model boundary. No trained model is bundled or claimed today.
abstract interface class ThreatMLModel {
  Future<ThreatMLPrediction> predict(ThreatFeatures features);
}

class ThreatIntelligenceResult {
  const ThreatIntelligenceResult({
    required this.knownThreat,
    required this.evidence,
  });

  final bool knownThreat;
  final List<String> evidence;
}

/// Future reputation/hash provider boundary for approved intelligence sources.
abstract interface class ThreatIntelligenceProvider {
  Future<ThreatIntelligenceResult> lookupHash(String sha256);

  Future<ThreatIntelligenceResult> lookupDomain(String domain);

  Future<ThreatIntelligenceResult> lookupUrl(String url);
}

class DeepAnalysisResult {
  const DeepAnalysisResult({required this.status, required this.evidence});

  final String status;
  final List<String> evidence;
}

/// Future isolated-worker boundary. The current app never executes submitted
/// files and has no dynamic sandbox implementation.
abstract interface class DeepAnalysisProvider {
  Future<DeepAnalysisResult> analyze(ThreatAnalysisRequest request);
}

abstract interface class AnalysisAbuseGuard {
  Future<bool> allow(ThreatAnalysisRequest request);

  void record(ThreatAnalysisRequest request);
}
