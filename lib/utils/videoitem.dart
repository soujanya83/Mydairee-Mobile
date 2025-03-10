import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoItem extends StatefulWidget {
  final double? width;
  final double? height;
  final String url;

  VideoItem({required this.url,  this.height,  this.width});
  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends   State<VideoItem> {
  VideoPlayerController? _controller;
  int play = 0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 150,
      width: widget.width ?? MediaQuery.of(context).size.width,
      child: Center(
        child: _controller?.value.isInitialized !=null
            ? Stack(children: [
                // AspectRatio(
                //   aspectRatio: _controller.value.aspectRatio,
                //   child: VideoPlayer(_controller),
                // ),
                VideoPlayer(_controller!),
                Center(
                    child: GestureDetector(
                        onTap: _playPause,
                        child: play == 1
                            ? Icon(
                                Icons.pause,
                                color: Colors.white,
                                size: 25,
                              )
                            : Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 25,
                              )))
              ])
            : Container(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  _playPause() {
    if (_controller?.value.isPlaying??false) {
      play = 0;
      _controller?.pause();
    } else {
      play = 1;
      _controller?.play();
    }
    setState(() {});
  }
}
