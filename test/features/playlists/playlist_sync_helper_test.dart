import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setlist_pad/features/playlists/domain/models/playlist_sync_result.dart';
import 'package:setlist_pad/features/playlists/presentation/utils/playlist_sync_helper.dart';
import 'package:setlist_pad/l10n/app_localizations.dart';

void main() {
  group('PlaylistSyncHelper Tests', () {
    test('formats Spanish messages properly for all diff variants', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));

      // Both added and removed (Scenario 1)
      const resBothSingle = PlaylistSyncResult(
        addedCount: 1,
        removedCount: 1,
        totalCount: 2,
      );
      expect(
        PlaylistSyncHelper.formatMessage(l10n, resBothSingle),
        '+1 añadida, -1 removida',
      );

      const resBothPlural = PlaylistSyncResult(
        addedCount: 3,
        removedCount: 2,
        totalCount: 5,
      );
      expect(
        PlaylistSyncHelper.formatMessage(l10n, resBothPlural),
        '+3 añadidas, -2 removidas',
      );

      // Only added
      const resOnlyAddedSingle = PlaylistSyncResult(
        addedCount: 1,
        removedCount: 0,
        totalCount: 3,
      );
      expect(
        PlaylistSyncHelper.formatMessage(l10n, resOnlyAddedSingle),
        '+1 añadida',
      );

      const resOnlyAddedPlural = PlaylistSyncResult(
        addedCount: 4,
        removedCount: 0,
        totalCount: 4,
      );
      expect(
        PlaylistSyncHelper.formatMessage(l10n, resOnlyAddedPlural),
        '+4 añadidas',
      );

      // Only removed
      const resOnlyRemovedSingle = PlaylistSyncResult(
        addedCount: 0,
        removedCount: 1,
        totalCount: 1,
      );
      expect(
        PlaylistSyncHelper.formatMessage(l10n, resOnlyRemovedSingle),
        '-1 removida',
      );

      const resOnlyRemovedPlural = PlaylistSyncResult(
        addedCount: 0,
        removedCount: 3,
        totalCount: 0,
      );
      expect(
        PlaylistSyncHelper.formatMessage(l10n, resOnlyRemovedPlural),
        '-3 removidas',
      );

      // No changes
      const resNoChanges = PlaylistSyncResult(
        addedCount: 0,
        removedCount: 0,
        totalCount: 2,
      );
      expect(
        PlaylistSyncHelper.formatMessage(l10n, resNoChanges),
        'La lista ya está actualizada',
      );
    });

    test('formats English messages properly for all diff variants', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      const resBoth = PlaylistSyncResult(
        addedCount: 1,
        removedCount: 1,
        totalCount: 2,
      );
      expect(
        PlaylistSyncHelper.formatMessage(l10n, resBoth),
        '+1 added, -1 removed',
      );

      const resNoChanges = PlaylistSyncResult(
        addedCount: 0,
        removedCount: 0,
        totalCount: 2,
      );
      expect(
        PlaylistSyncHelper.formatMessage(l10n, resNoChanges),
        'Playlist is already up to date',
      );
    });
  });
}

