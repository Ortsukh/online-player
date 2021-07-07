import 'dart:async';
import 'dart:ui';

import 'package:app/extensions/assets_audio_player.dart';
import 'package:app/models/song.dart';
import 'package:app/providers/audio_player_provider.dart';
import 'package:app/providers/song_provider.dart';
import 'package:app/ui/screens/info.dart';
import 'package:app/ui/screens/queue.dart';
import 'package:app/ui/screens/song_action_sheet.dart';
import 'package:app/ui/widgets/now_playing/audio_controls.dart';
import 'package:app/ui/widgets/now_playing/loop_mode_button.dart';
import 'package:app/ui/widgets/now_playing/progress_bar.dart';
import 'package:app/ui/widgets/now_playing/song_info.dart';
import 'package:app/ui/widgets/now_playing/volume_slider.dart';
import 'package:app/ui/widgets/song_cache_icon.dart';
import 'package:app/ui/widgets/song_thumbnail.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NowPlayingScreen extends StatelessWidget {
  late final AudioPlayerProvider audio;
  late final SongProvider songProvider;

  @override
  Widget build(BuildContext context) {
    audio = context.watch();
    songProvider = context.watch();

    Color bottomIconColor = Colors.white.withOpacity(.5);

    return StreamBuilder<Playing?>(
      stream: audio.player.current,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        String? songId = audio.player.songId;
        if (songId == null) return const SizedBox.shrink();
        Song song = songProvider.byId(songId);

        final Widget frostGlassBackground = SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: song.image,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
        );

        final Widget thumbnail = Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Hero(
            tag: 'hero-now-playing-thumbnail',
            child: SongThumbnail(song: song, size: ThumbnailSize.xl),
          ),
        );

        final Widget infoPane = Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(child: SongInfo(song: song)),
                const SizedBox(width: 8),
                SongCacheIcon(song: song),
                IconButton(
                  onPressed: () =>
                      showActionSheet(context: context, song: song),
                  icon: const Icon(CupertinoIcons.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ProgressBar(),
          ],
        );

        return Stack(
          children: <Widget>[
            Container(color: Colors.black),
            frostGlassBackground,
            Container(color: Colors.black.withOpacity(.7)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  thumbnail,
                  infoPane,
                  AudioControls(),
                  Column(
                    children: <Widget>[
                      VolumeSlider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          LoopModeButton(),
                          IconButton(
                            onPressed: () => showInfoSheet(context, song: song),
                            icon: Icon(
                              CupertinoIcons.text_quote,
                              color: bottomIconColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (_) => QueueScreen()),
                              );
                            },
                            icon: Icon(
                              CupertinoIcons.list_number,
                              color: bottomIconColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<void> openNowPlayingScreen(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: NowPlayingScreen(),
      );
    },
  );
}
