import 'package:flutter/material.dart';
import 'package:houzi_package/buddypress/widgets/video_widget.dart';
import 'package:html/parser.dart';
import 'package:photo_view/photo_view.dart';

class ActivityContentWidget extends StatefulWidget {
  final String htmlContent;

  const ActivityContentWidget({Key? key, required this.htmlContent})
      : super(key: key);

  @override
  State<ActivityContentWidget> createState() => _ActivityContentWidgetState();
}

class _ActivityContentWidgetState extends State<ActivityContentWidget> {
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final videoUrls = _extractVideoUrls(widget.htmlContent);
    // if (videoUrl != null && posterUrl != null) {
    //   return VideoWidget(
    //     videoUrl: videoUrl,
    //     posterUrl: posterUrl,
    //   ); // Show VideoWidget directly
    // } else {
    //   return _buildHtmlContent(widget.htmlContent);
    // }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHtmlContent(widget.htmlContent),
        ...videoUrls.asMap().entries.map((entry) {
          final videoUrl = entry.value;
          return VideoWidget(
            videoUrl: videoUrl,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHtmlContent(String html) {
    var document = parse(html);
    var spans = document.getElementsByTagName('span');
    var images = document.getElementsByTagName('img');

    var textWidgets = spans
        .map((span) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                span.text,
                style: const TextStyle(color: Color.fromRGBO(112, 112, 112, 1)),
              ),
            ))
        .toList();

    var imageUrls = images.map((image) => image.attributes['src']).toList();

    var widgets = <Widget>[];
    for (var i = 0; i < textWidgets.length; i++) {
      widgets.add(textWidgets[i]);
      if (i < imageUrls.length) {
        if (imageUrls.length > 1) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Change as needed
                ),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhotoView(
                              imageProvider: NetworkImage(imageUrls[index]!),
                            ),
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: _buildImage(imageUrls[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
          break;
        } else {
          widgets.add(
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      body: Center(
                        child: PhotoView(
                          imageProvider: NetworkImage(imageUrls[i]!),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: _buildImage(imageUrls[i]),
                ),
              ),
            ),
          );
        }
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildImage(String? imageUrl) {
    
    if (imageUrl != null) {
      return FadeInImage.assetNetwork(
        placeholder:
            'packages/houzi_package/lib/buddypress/assets/gray_square_placeholder.jpg', // Placeholder image
        image: imageUrl,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        // Add other parameters as needed for customization
      );
    } else {
      // Return a gray square placeholder if imageUrl is null
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[300], // Gray color for the placeholder
        child: Center(
          child: Icon(
            Icons.image_not_supported, // Icon to indicate no image available
            color: Colors.grey[600], // Color of the icon
          ),
        ),
      );
    }
  }

  List<String> _extractVideoUrls(String html) {
    var document = parse(html);
    var videoElements = document.querySelectorAll('video, video source');
    return videoElements
        .map((videoElement) {
          var src = videoElement.attributes['src'];
          var cleanUrl = src?.split('?')[0];
          if (src != null && cleanUrl!.endsWith('.mp4')) {
            return src;
          }
          return null;
        })
        .where((src) => src != null)
        .toList()
        .cast<String>();
  }

  List<String?> _extractVideoPosters(String html) {
    var document = parse(html);
    var videoElements = document.querySelectorAll('video');
    return videoElements
        .map((videoElement) {
          var src = videoElement.attributes['poster'];
          if (src != null && src.endsWith('.jpg')) {
            return src;
          }
          return null;
        })
        .where((src) => src != null)
        .toList()
        .cast<String>();
  }
}
