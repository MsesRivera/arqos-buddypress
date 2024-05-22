import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../files/hive_storage_files/hive_storage_manager.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../services/remote_service.dart';
import '../widgets/comment_widget.dart';
import 'package:houzi_package/providers/api_providers/houzez_api_provider.dart'; // Import the HouzezApiProvider
import 'package:http/http.dart' as http;

class NewComment extends StatefulWidget {
  final List<Comment>? comments;
  final int activityId;
  final bool openKbd;

  const NewComment(
      {Key? key, this.comments, required this.activityId, this.openKbd = false})
      : super(key: key);

  @override
  _NewCommentState createState() => _NewCommentState();
}

class _NewCommentState extends State<NewComment> {
  final ScrollController _scrollController = ScrollController();
  List<Comment>? _loadedComments;
  final TextEditingController _commentController = TextEditingController();
  bool _isPostingComment = false;

  final houzezApiProvider = HOUZEZApiProvider();

  @override
  void initState() {
    super.initState();
    _loadedComments = widget.comments?.take(5).toList();
    _scrollController.addListener(_onScroll);

    // Initialize token when the widget is initialized
    Provider.of<ActivityProvider>(context, listen: false).initializeToken();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> printUserInfo() async {
    final userCredentials = HiveStorageManager.readUserCredentials();
    print("User credentials: $userCredentials");
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _loadedComments!.addAll(
            widget.comments!.skip(_loadedComments!.length).take(5).toList());
      });
    }
  }

  Future<void> _postComment() async {
    setState(() {
      _isPostingComment = true;
      printUserInfo();
    });

    try {
      // Get the nonce
      final nonce = await houzezApiProvider.provideCreateNonceApi().toString();
      if (nonce == null) {
        // Handle error
        return;
      }
      // Construct HTML content with tags
      final htmlContent = '''
<div class="rtmedia-activity-container">
  <div class="rtmedia-activity-text">
    <span>${_commentController.text}<br /></span>
  </div>
  <ul class="rtmedia-list rtm-activity-media-list rtmedia-activity-media-length-0 rtm-activity-mixed-list"></ul>
</div>
''';

      // Send HTML content as 'rendered' in the map
      final content = htmlContent;

      final success =
          await Provider.of<ActivityProvider>(context, listen: false)
              .postComment(
                  content: content,
                  activityId: widget.activityId,
                  nonce: nonce);
      if (success) {
        _commentController.clear();

        // Reload comments after posting
        await _reloadComments();
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
    }

    setState(() {
      _isPostingComment = false;
    });
  }

  Future<void> _reloadComments() async {
    try {
      final List<Activity>? updatedComments =
          await Provider.of<ActivityProvider>(context, listen: false)
              .getActivity(activityId: widget.activityId);
      if (updatedComments != null && updatedComments.isNotEmpty) {
        // Actualizar el estado con los comentarios recién cargados
        setState(() {
          _loadedComments = updatedComments[0].comments;
        });
      } else {
        // Manejar el caso en que no se encontraron comentarios
      }
    } catch (e) {
      // Manejar errores de conexión u otros errores
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final _commentFocusNode = FocusNode();

    if (widget.openKbd) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_commentFocusNode);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentar...'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
                child: Column(
                  children: [
                    Consumer<ActivityProvider>(
                      builder: (context, activityProvider, child) {
                        if (activityProvider.isLoaded) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: _loadedComments?.length ?? 0,
                            itemBuilder: (context, index) {
                              final comment = _loadedComments![index];
                              return CommentWidget(comment: comment);
                            },
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          _isPostingComment
              ? const CircularProgressIndicator() // Show loading indicator while posting comment
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey,
                            image: HiveStorageManager.getUserAvatar() != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                        HiveStorageManager.getUserAvatar()!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: _commentController,
                            focusNode: _commentFocusNode,
                            decoration: const InputDecoration(
                              hintText: 'Comentar...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Color.fromRGBO(112, 112, 112, 1),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: IconButton(
                          onPressed: _postComment,
                          icon: const Icon(Icons.send_outlined),
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
