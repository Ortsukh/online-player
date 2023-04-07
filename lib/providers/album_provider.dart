import 'package:app/models/models.dart';
import 'package:app/utils/api_request.dart';
import 'package:flutter/foundation.dart';

class AlbumProvider with ChangeNotifier {
  var albums = <Album>[];
  final _vault = <int, Album>{};
  var _page = 1;

  Album? byId(int id) => _vault[id];

  List<Album> byIds(List<int> ids) {
    final albums = <Album>[];

    ids.forEach((id) {
      if (_vault.containsKey(id)) {
        albums.add(_vault[id]!);
      }
    });

    return albums;
  }

  Future<Album> resolve(int id, {bool forceRefresh = false}) async {
    if (!_vault.containsKey(id) || forceRefresh) {
      _vault[id] = Album.fromJson(await get('albums/$id'));
    }

    return _vault[id]!;
  }

  List<Album> syncWithVault(dynamic _albums) {
    assert(_albums is List<Album> || _albums is Album);

    if (_albums is Album) {
      _albums = [_albums];
    }

    List<Album> synced = (_albums as List<Album>).map<Album>((remote) {
      final local = byId(remote.id);

      if (local == null) {
        _vault[remote.id] = remote;
        return remote;
      } else {
        return local.merge(remote);
      }
    }).toList();

    notifyListeners();

    return synced;
  }

  Future<void> paginate() async {
    final res = await get('albums?page=$_page');

    final List<Album> _albums = (res['data'] as List)
        .map<Album>((album) => Album.fromJson(album))
        .toList();

    final List<Album> synced = syncWithVault(_albums);
    albums = [...albums, ...synced].toSet().toList();

    _page = res['links']['next'] == null ? 1 : ++res['meta']['current_page'];

    notifyListeners();
  }

  Future<void> refresh() {
    albums.clear();
    _page = 1;

    return paginate();
  }
}
