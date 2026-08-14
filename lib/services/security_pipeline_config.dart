class SecurityPipelineConfig {
  const SecurityPipelineConfig({
    this.maxFileSizeBytes = 25 * 1024 * 1024,
    this.maxArchiveSizeBytes = 25 * 1024 * 1024,
    this.maxExtractedSizeBytes = 100 * 1024 * 1024,
    this.maxArchiveFiles = 1000,
    this.maxArchiveDepth = 1,
    this.maxImageDimension = 4096,
    this.maxImagePixels = 16 * 1024 * 1024,
    this.maxAnalysisTime = const Duration(seconds: 60),
    this.quarantineRetention = const Duration(minutes: 15),
  });

  final int maxFileSizeBytes;
  final int maxArchiveSizeBytes;
  final int maxExtractedSizeBytes;
  final int maxArchiveFiles;
  final int maxArchiveDepth;
  final int maxImageDimension;
  final int maxImagePixels;
  final Duration maxAnalysisTime;
  final Duration quarantineRetention;
}
