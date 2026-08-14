import 'quarantine_storage_base.dart';

/// Web fallback: raw file paths are not exposed by the current picker flow.
/// It retains no bytes and leaves file analysis inconclusive.
class TemporaryQuarantineStorage extends InMemoryQuarantineStorage {
  const TemporaryQuarantineStorage();
}
