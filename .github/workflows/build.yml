import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../core/theme/premium_glass.dart';

class ProVideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  const ProVideoPlayerScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<ProVideoPlayerScreen> createState() => _ProVideoPlayerScreenState();
}

class _ProVideoPlayerScreenState extends State<ProVideoPlayerScreen> {
  late final Player player;
  late final VideoController controller;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    player.open(Media(widget.videoPath));
    
    player.stream.playing.listen((playing) {
      setState(() { isPlaying = playing; });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void _togglePlay() {
    isPlaying ? player.pause() : player.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Layer
          Video(controller: controller, controls: NoVideoControls),

          // Top Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const _GlassIconButton(icon: CupertinoIcons.xmark),
                ),
                const PremiumGlass(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  borderRadius: 20,
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.tv, color: Colors.white, size: 22),
                      SizedBox(width: 20),
                      Icon(CupertinoIcons.share, color: Colors.white, size: 22),
                    ],
                  ),
                ),
                _VolumeIndicator(),
              ],
            ),
          ),

          // Center Controls
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _GlassIconButton(icon: CupertinoIcons.gobackward_15, size: 60, iconSize: 28),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: _togglePlay,
                  child: _GlassIconButton(
                    icon: isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill, 
                    size: 85, 
                    iconSize: 45
                  ),
                ),
                const SizedBox(width: 40),
                const _GlassIconButton(icon: CupertinoIcons.goforward_15, size: 60, iconSize: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;

  const _GlassIconButton({required this.icon, this.size = 50, this.iconSize = 24});

  @override
  Widget build(BuildContext context) {
    return PremiumGlass(
      borderRadius: size / 2,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}

class _VolumeIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PremiumGlass(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 4,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          const Icon(CupertinoIcons.headphones, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}
