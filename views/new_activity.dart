import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/hive_storage_files/hive_storage_manager.dart';
import 'package:houzi_package/interfaces/api_provider_interface.dart';
import 'package:houzi_package/models/api_response.dart';
import 'package:houzi_package/providers/api_providers/houzez_api_provider.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import the dart:io package
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:houzi_package/providers/api_providers/property_api_provider.dart';
import 'package:provider/provider.dart';
import '../../files/hive_storage_files/hive_storage_manager.dart';

import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../providers/activity_provider.dart';
import '../utils/get_media_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class NewActivity extends StatefulWidget {
  const NewActivity({Key? key}) : super(key: key);

  @override
  NewActivityState createState() => NewActivityState();
}

class NewActivityState extends State<NewActivity> {
  final _focusNode = FocusNode();
  final _textFieldController = TextEditingController();
  final _imagePicker = ImagePicker();
  late List<XFile> _selectedImages = [];

  double get keyboardSpace {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.viewInsets.bottom;
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
    print(HiveStorageManager.getUserId().toString());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textFieldController.dispose();
    super.dispose();
  }

  // Future<void> sendActivity(String content) async {
  //   final url = Uri.parse('https://arqospv.com/wp-json/buddypress/v1/activity');
  //   final response = await http.post(
  //     url,
  //     body: {
  //       'component': 'activity',
  //       'type': 'activity_update',
  //       'content': content,
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     // Handle success
  //   } else {
  //     // Handle failure
  //   }
  // }

  String generateHtmlContent(List<String?> mediaUrls, String content) {
    // Construct the media section HTML
    String mediaHtml = '';
    for (String? url in mediaUrls) {
      if (url != null) {
        var cleanUrl = url.split('?')[0];
        if (cleanUrl.endsWith('.mp4') ||
            cleanUrl.endsWith('.mov') ||
            cleanUrl.endsWith('.avi')) {
          mediaHtml += '''
          <ul class="rtmedia-list rtm-activity-media-list rtmedia-activity-media-length-1 rtm-activity-video-list">
            <li class="rtmedia-list-item media-type-video">
              <div class="rtmedia-item-thumbnail">
                <video poster="$cleanUrl.jpg" src="$url" class="wp-video-shortcode" id="rt_media_video" controls="controls" preload="metadata"></video>
              </div>
            </li>
          </ul>
        ''';
        } else {
          mediaHtml += '<img src="$url" alt="Image">';
        }
      }
    }

    // Construct the complete HTML structure
    String htmlContent = '''
    <div class="rtmedia-activity-container">
      <div class="rtmedia-activity-text">
        <span>$content</span>
      </div>
      $mediaHtml
    </div>
  ''';

    return htmlContent;
  }

  Future<List<XFile>> pickImages(BuildContext context) async {
    List<XFile> images = [];

    List<XFile>? pickedFiles = await _imagePicker.pickMultipleMedia(
      imageQuality: 80, // Adjust image quality as needed
    );

    if (pickedFiles != null) {
      // Filter selected files to include only images and videos
      List<XFile> supportedFiles = pickedFiles
          .where((file) =>
              file.path.toLowerCase().endsWith('.jpg') ||
              file.path.toLowerCase().endsWith('.jpeg') ||
              file.path.toLowerCase().endsWith('.png') ||
              file.path.toLowerCase().endsWith('.mp4'))
          .toList();

      // Check if any unsupported files were selected
      if (pickedFiles.length > supportedFiles.length) {
        // Show a message for unsupported files
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                'Algunos archivos seleccionados no son compatibles por el momento.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      images.addAll(supportedFiles);
    }

    return images;
  }

  // Crear la funcion addImages para cuando ya hay imagenes seleccionadas de la galeria
  Future<List<XFile>> addImages() async {
    const List<XFile> emptyList = [];

    List<XFile> images = [];

    List<XFile>? pickedFiles = await _imagePicker.pickMultipleMedia(
      imageQuality: 80, // Adjust image quality as needed
    );

    if (pickedFiles != null) {
      // Filter selected files to include only images and videos
      List<XFile> supportedFiles = pickedFiles
          .where((file) =>
              file.path.toLowerCase().endsWith('.jpg') ||
              file.path.toLowerCase().endsWith('.jpeg') ||
              file.path.toLowerCase().endsWith('.png') ||
              file.path.toLowerCase().endsWith('.mp4'))
          .toList();

      // Check if any unsupported files were selected
      if (pickedFiles.length > supportedFiles.length) {
        // Show a message for unsupported files
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Algunos archivos seleccionados no son compatibles por el momento.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }

      images = [...images, ...supportedFiles];
    }

    return images.isNotEmpty ? images : emptyList;
  }

  Future<List<String>> getImagePaths(List<XFile> images) async {
    List<String> imagePaths = [];
    for (var image in images) {
      final String path = image.path;
      imagePaths.add(path);
    }
    return imagePaths;
  }

  Future<List<File>> getImageFiles(List<XFile> images) async {
    List<File> imageFiles = [];
    for (var image in images) {
      final File pickedFile = File(image.path);
      imageFiles.add(pickedFile);
    }
    return imageFiles;
  }

  String getImageType(String imagePath) {
    if (imagePath.toLowerCase().endsWith('.jpg') ||
        imagePath.toLowerCase().endsWith('.jpeg')) {
      return 'jpeg';
    } else if (imagePath.toLowerCase().endsWith('.png')) {
      return 'png';
    } else {
      throw ArgumentError('Unsupported image type');
    }
  }

  //función que devuelve la duración en un int total del video si el tipo de archivo es video
  Future<int> getVideoDuration(String videoPath) async {
    final file = File(videoPath);
    final videoPlayerController = VideoPlayerController.file(file);
    await videoPlayerController.initialize();
    final duration = videoPlayerController.value.duration;
    return duration.inSeconds;
  }

  //funcion que devuelve la imagen thumbnail del video si el tipo de archivo es video
  Future<Image> getVideoThumbnail(String videoPath) async {
    final file = File(videoPath);
    final videoPlayerController = VideoPlayerController.file(file);
    await videoPlayerController.initialize();
    final image = Image.file(
      file,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
    return image;
  }

  Future<void> preloadImages() async {
    for (var image in _selectedImages) {
      final url = 'https://arqospv.com/wp-admin/admin-ajax.php';
      final imagePath = image.path;

      // Check if file exists
      if (!await File(imagePath).exists()) {
        print('Error: Image file not found: $imagePath');
        continue;
      }

      final file = File(imagePath);
      final imageBytes = await file.readAsBytes();
      final base64Image = base64Encode(imageBytes); // Encode as Base64

      FormData formData = FormData();
      formData.fields.addAll([
        MapEntry('action', 'rtmedia_api'),
        MapEntry('context', 'profile'),
        MapEntry('method', 'rtmedia_upload_media'),
        MapEntry('token',
            '75d50d03cc5a4979291ff61f4d261a6c3fa52268'), // Replace with your token
        MapEntry('image_type', getImageType(imagePath)),
        MapEntry('title', imagePath.split('/').last),
        MapEntry('rtmedia_file', base64Image), // Include Base64-encoded data
      ]);

      try {
        var response = await Dio().post(
          url,
          data: formData,
          // options: Options(contentType: 'multipart/form-data'), // Not needed for Base64
        );

        if (response.statusCode == 200) {
          // Handle successful response
          print(response.data);
        } else {
          // Handle error response
          print(
              'Failed to preload image: $imagePath (status code: ${response.statusCode})');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  bool isImageFile(String filePath) {
    final imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp'
    ]; // List of supported image extensions
    String extension = filePath.toLowerCase();
    return imageExtensions.any((ext) => extension.endsWith(ext));
  }

  Future<List<String?>> uploadMedia(
      {required List<XFile> selectedMedia}) async {
    List<String> mediaUrls = [];
    final _firestore = FirebaseFirestore.instance;
    final _storage = FirebaseStorage.instance;

    // For each selected media
    for (var media in selectedMedia) {
      print('File path: ${media.path}'); // Debug line

      try {
        if (File(media.path).existsSync()) {
          // Get the temporary directory of the device.
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;

          // Create a new file in the temporary directory.
          File file = File('$tempPath/${media.path.split('/').last}');

          // Copy the media file to the new file.
          await file.writeAsBytes(await File(media.path).readAsBytes());

          // Generate a unique ID for the file.
          final fileUid = const Uuid().v1();

          // Create a reference to the file in Firebase Storage.
          final Reference path =
              _storage.ref('media/$fileUid/${file.path.split('/').last}');
          print('Storage reference: ${path}'); // Debug line

          // Upload the file to Firebase Storage.
          await path.putFile(file);

          // Get the download URL of the uploaded file.
          String downloadUrl = await path.getDownloadURL();

          // Add the download URL to the list.
          mediaUrls.add(downloadUrl);
        } else {
          print('The file does not exist');
        }
      } catch (e) {
        print('An error occurred: $e');
      }
    }

    return mediaUrls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + keyboardSpace),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 15),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey,
                            image: DecorationImage(
                              image: NetworkImage(
                                  HiveStorageManager.getUserAvatar() ?? ''),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            HiveStorageManager.getUserName() ?? 'Usuario',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _textFieldController,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color.fromRGBO(112, 112, 112, 1),
                      ),
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: '¿Qué compartirás hoy?',
                        hintStyle: TextStyle(
                          fontSize: 20,
                          color: Color.fromRGBO(112, 112, 112, 1),
                        ),
                        border: InputBorder.none,
                      ),
                      focusNode: _focusNode,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          _selectedImages.isNotEmpty
              ? SizedBox(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        final XFile file = _selectedImages[index];
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: Stack(
                                  children: [
                                    // Display the media (image or video)
                                    if (isImageFile(file.path))
                                      Image.file(
                                        File(file.path),
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    else
                                      FutureBuilder<Uint8List>(
                                        future: () async {
                                          print(
                                              'Video file path: ${file.path}');
                                          try {
                                            final thumbnailBytes =
                                                await VideoThumbnail
                                                    .thumbnailData(
                                              video: file.path,
                                              imageFormat: ImageFormat.JPEG,
                                              maxWidth: 100,
                                              quality: 25,
                                            );
                                            if (thumbnailBytes == null) {
                                              print('Thumbnail bytes is null');
                                              return Uint8List(
                                                  0); // Return an empty Uint8List if thumbnailBytes is null
                                            } else {
                                              print(
                                                  'Thumbnail bytes length: ${thumbnailBytes.length}');
                                              return thumbnailBytes;
                                            }
                                          } catch (e) {
                                            print(
                                                'Error generating thumbnail: $e');
                                            return Uint8List(
                                                0); // Return an empty Uint8List if an error occurs
                                          }
                                        }(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            if (snapshot.hasError) {
                                              print(
                                                  'FutureBuilder error: ${snapshot.error}');
                                            }
                                            if (snapshot.hasData &&
                                                snapshot.data != null &&
                                                snapshot.data!.isNotEmpty) {
                                              return Image.memory(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              );
                                            }
                                          }
                                          return Container(
                                            color: Colors
                                                .grey, // Placeholder color for videos
                                            child: const Center(
                                              child: Icon(Icons.videocam,
                                                  size: 50,
                                                  color: Colors.white),
                                            ),
                                          );
                                        },
                                      ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedImages.removeAt(index);
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withOpacity(
                                                0.5), // Transparent color
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _selectedImages.isNotEmpty
                    ? Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            List<XFile> selectedImages = await addImages();
                            setState(() {
                              _selectedImages =
                                  _selectedImages + selectedImages;
                            });
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Galeria'),
                        ),
                      )
                    : Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            List<XFile> selectedImages =
                                await pickImages(context);
                            setState(() {
                              _selectedImages = selectedImages;
                              _selectedImages.forEach((file) {
                                final filePath = file.path;
                                print('File path: $filePath');
                                if (File(filePath).existsSync()) {
                                  print('The file exists at this path');
                                } else {
                                  print('No file exists at this path');
                                }
                              });
                            });
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Galería'),
                        ),
                      ),
                const SizedBox(width: 15.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final houzezApiProvider = HOUZEZApiProvider();

                      // Send the activity
                      var mediaUrls =
                          await uploadMedia(selectedMedia: _selectedImages);
                      var cleanUrls = mediaUrls.map((url) {
                        if (url != null) {
                          return url.split('?')[0];
                        }
                      }).toList();
                      for (var mediaUrl in mediaUrls) {
                        print('Media URL: $mediaUrl');
                      }

                      // Create a new activity
                      // generateHtmlContent(mediaUrls, _textFieldController.text);
                      try {
                        // Get the nonce
                        final nonce = await houzezApiProvider
                            .provideCreateNonceApi()
                            .toString();
                        if (nonce == null) {
                          // Handle error
                          return;
                        }

                        final content = generateHtmlContent(
                            mediaUrls, _textFieldController.text);

                        final success = await Provider.of<ActivityProvider>(
                                context,
                                listen: false)
                            .postActivity(content: content, nonce: nonce);

                        if (success) {
                          // Clear the text field and selected images
                          _textFieldController.clear();
                          setState(() {
                            _selectedImages = [];
                            Provider.of<ActivityProvider>(context, listen: false)
                                .fetchActivitiesForTab('');
                          });

                          // Show a success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Actividad publicada'),
                            ),
                          );

                          // Close the activity view
                          Navigator.of(context).pop();
                        } else {
                          // Handle error
                        }
                      } catch (e) {
                        // Handle error
                        print('Error: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Publicar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
