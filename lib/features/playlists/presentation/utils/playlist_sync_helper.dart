import '../../../../l10n/app_localizations.dart';
import '../../domain/models/playlist_sync_result.dart';

class PlaylistSyncHelper {
  const PlaylistSyncHelper._();

  static String formatMessage(
    AppLocalizations l10n,
    PlaylistSyncResult result,
  ) {
    if (result.addedCount > 0 && result.removedCount > 0) {
      return l10n.syncResultAddedAndRemoved(
        result.addedCount,
        result.removedCount,
      );
    } else if (result.addedCount > 0) {
      return l10n.syncResultAdded(result.addedCount);
    } else if (result.removedCount > 0) {
      return l10n.syncResultRemoved(result.removedCount);
    } else {
      return l10n.syncResultNoChanges;
    }
  }
}

