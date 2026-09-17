// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SetlistPad';

  @override
  String get homeTitle => 'SetlistPad';

  @override
  String get coreInitialized => 'Núcleo de SetlistPad inicializado';

  @override
  String get hiveRiverpodReady =>
      'Hive DB y Riverpod listos para Playlists y Canciones';

  @override
  String get navPlaylists => 'Listas';

  @override
  String get navSongLibrary => 'Biblioteca';

  @override
  String get playlistsTitle => 'Listas de reproducción';

  @override
  String get createNewPlaylist => 'Crear nueva lista';

  @override
  String get playlistName => 'Nombre de la lista';

  @override
  String get playlistNameHint => 'ej. Concierto del sábado';

  @override
  String get playlistNameRequired => 'Por favor ingrese un nombre';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Crear';

  @override
  String get noPlaylistsYet => 'No hay listas todavía';

  @override
  String get tapToCreatePlaylist => 'Toca + para crear una lista';

  @override
  String get newPlaylist => 'Nueva lista';

  @override
  String songsCount(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString Canciones',
      one: '1 Canción',
    );
    return '$_temp0';
  }

  @override
  String get addSong => 'Agregar canción';

  @override
  String get addSongToPlaylist => 'Agregar canción a la lista';

  @override
  String get noMoreSongsToAdd =>
      'No hay más canciones disponibles para agregar.\nImporta más canciones en la pestaña Biblioteca.';

  @override
  String get noSongsInPlaylist =>
      'No hay canciones en esta lista todavía.\nToca \"Agregar canción\" para añadir canciones de tu biblioteca.';

  @override
  String get deletePlaylistTooltip => 'Eliminar lista';

  @override
  String get songLibraryTitle => 'Biblioteca de canciones';

  @override
  String get searchHint => 'Buscar título o artista...';

  @override
  String get noSongsFound => 'No se encontraron canciones en la biblioteca';

  @override
  String get tapToImport => 'Toca + para importar de YouTube';

  @override
  String get importYoutube => 'Importar YouTube';

  @override
  String get importFromYoutube => 'Importar de YouTube';

  @override
  String get importYoutubeDescription =>
      'Pega un enlace de YouTube. El título, artista y letra (vía LRCLIB) se obtendrán automáticamente.';

  @override
  String get youtubeUrl => 'URL de YouTube';

  @override
  String get youtubeUrlHint => 'https://www.youtube.com/watch?v=...';

  @override
  String get pleaseEnterUrl => 'Por favor ingrese una URL';

  @override
  String get invalidYoutubeUrl => 'Debe ser una URL de YouTube válida';

  @override
  String get fetchingMetadata => 'Obteniendo metadatos y letra...';

  @override
  String get importButton => 'Importar';

  @override
  String songImportedSuccess(String title, String artist) {
    return 'Se importó \"$title\" de $artist';
  }

  @override
  String get editLyrics => 'Editar letra';

  @override
  String get saveLyrics => 'Guardar letra';

  @override
  String get lyricsUpdatedSuccess => '¡Letra actualizada con éxito!';

  @override
  String get textSize => 'Tamaño del texto:';

  @override
  String get lyricsHint => 'Ingresa o edita la letra aquí...';

  @override
  String get noLyricsAvailable =>
      'No hay letra disponible para esta canción. Toca el ícono de editar para agregarla.';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get errorImportingSong =>
      'No se pudo importar la canción. Verifica el enlace y tu conexión.';

  @override
  String get errorInvalidYoutubeUrlFormat =>
      'Formato de URL de YouTube no válido.';
}
