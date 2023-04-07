import 'package:app/constants/constants.dart';
import 'package:app/models/models.dart';
import 'package:app/providers/providers.dart';
import 'package:app/router.dart';
import 'package:app/ui/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistsScreen extends StatefulWidget {
  static const routeName = '/playlists';
  final AppRouter router;

  const PlaylistsScreen({
    Key? key,
    this.router = const AppRouter(),
  }) : super(key: key);

  @override
  _PlaylistsScreenState createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoTheme(
        data: const CupertinoThemeData(primaryColor: Colors.white),
        child: GradientDecoratedContainer(
          child: Consumer<PlaylistProvider>(
            builder: (context, provider, navigationBar) {
              if (provider.playlists.isEmpty) {
                return NoPlaylistsScreen(
                  onTap: () => widget.router.showCreatePlaylistSheet(context),
                );
              }

              final playlists = provider.playlists
                ..sort((a, b) => a.name.compareTo(b.name));

              return CustomScrollView(
                slivers: <Widget>[
                  navigationBar!,
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        Playlist playlist = playlists[index];

                        return Card(
                          child: Dismissible(
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async => await confirmDelete(
                              context,
                              playlist: playlist,
                            ),
                            onDismissed: (_) => provider.remove(playlist),
                            background: Container(
                              alignment: AlignmentDirectional.centerEnd,
                              color: AppColors.red,
                              child: const Padding(
                                padding: EdgeInsets.only(right: 28),
                                child: Icon(CupertinoIcons.delete),
                              ),
                            ),
                            key: ValueKey(playlist),
                            child: PlaylistRow(playlist: playlist),
                          ),
                        );
                      },
                      childCount: playlists.length,
                    ),
                  ),
                  const BottomSpace(),
                ],
              );
            },
            child: CupertinoSliverNavigationBar(
              backgroundColor: AppColors.screenHeaderBackground,
              largeTitle: const LargeTitle(text: 'Playlists'),
              trailing: IconButton(
                onPressed: () => widget.router.showCreatePlaylistSheet(context),
                icon: const Icon(CupertinoIcons.add_circled),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> confirmDelete(
    BuildContext context, {
    required Playlist playlist,
  }) async {
    return await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: <InlineSpan>[
                const TextSpan(text: 'Delete the playlist '),
                TextSpan(
                  text: playlist.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          content: const Text('You cannot undo this action.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context, false),
            ),
            CupertinoDialogAction(
              child: const Text('Confirm'),
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
  }
}

class NoPlaylistsScreen extends StatelessWidget {
  final void Function() onTap;

  const NoPlaylistsScreen({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            CupertinoIcons.exclamationmark_square,
            size: 56.0,
          ),
          const SizedBox(height: 16.0),
          const Text('You have no playlists in your library.'),
          const SizedBox(height: 16.0),
          ElevatedButton(onPressed: onTap, child: Text('Create Playlist')),
        ],
      ),
    );
  }
}
