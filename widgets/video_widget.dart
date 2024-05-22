import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/material.dart';

class VideoWidget extends StatefulWidget {
  final String videoUrl;
  final String? posterUrl;

  const VideoWidget({Key? key, required this.videoUrl, this.posterUrl})
      : super(key: key);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  CustomVideoPlayerController? _customVideoPlayerController;

  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();
  }

  @override
  void dispose() {
    _customVideoPlayerController?.dispose(); // Use safe access to dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'packages/houzi_package/lib/buddypress/assets/video_placeholder.jpg',
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          )
        : _customVideoPlayerController !=
                null // Check if controller is not null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CustomVideoPlayer(
                  customVideoPlayerController: _customVideoPlayerController!,
                ),
              )
            : const SizedBox();
  }

  void initializeVideoPlayer() {
    setState(() {
      isLoading = true;
    });

    final videoUri = Uri.parse(widget.videoUrl);

    final videoPlayerController = VideoPlayerController.networkUrl(videoUri);

    videoPlayerController.initialize().then((_) {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _customVideoPlayerController = CustomVideoPlayerController(
            context: context,
            videoPlayerController: videoPlayerController,
          );
          isLoading = false;
        });
      }
    }).catchError((error) {
      print('Error initializing video player: $error');
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          isLoading = false;
        });
      }
    });
  }
}
