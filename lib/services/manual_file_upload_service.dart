import 'package:file_picker/file_picker.dart';

import '../models/incoming_share_payload.dart';
import 'file_hash_service.dart';
import 'security_pipeline_config.dart';

/// Opens the platform file chooser after an explicit user action.
///
/// This service only creates a normalized intake request. It does not upload,
/// execute, or open the selected files. A future secure upload gateway can use
/// the references without changing the scanner UI.
class ManualFileUploadService {
  const ManualFileUploadService();

  static const SecurityPipelineConfig pipelineConfig = SecurityPipelineConfig();

  Future<IncomingSharePayload?> pickFiles({bool apkOnly = false}) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: !apkOnly,
      type: apkOnly ? FileType.custom : FileType.any,
      allowedExtensions: apkOnly ? <String>['apk'] : null,
      withData: false,
      withReadStream: false,
      dialogTitle: apkOnly ? 'Choose an APK to check' : 'Choose files to check',
    );
    if (result == null || result.files.isEmpty) return null;

    final List<IncomingShareAttachment> attachments = await Future.wait(
      result.files.map(_toAttachment),
    );
    return IncomingSharePayload.fromManualFiles(attachments);
  }

  Future<IncomingShareAttachment> _toAttachment(PlatformFile file) async {
    final bool tooLarge = file.size > pipelineConfig.maxFileSizeBytes;
    final String reference =
        file.path ?? 'picker://${Uri.encodeComponent(file.name)}';
    return IncomingShareAttachment.fromFileReference(
      reference: reference,
      fileName: file.name,
      sizeBytes: file.size,
      isAccessible: !tooLarge,
      error: tooLarge
          ? 'This file is larger than the safe review limit.'
          : null,
      sha256: tooLarge
          ? null
          : await sha256ForReference(
              reference,
              maxBytes: pipelineConfig.maxFileSizeBytes,
            ),
    );
  }
}
