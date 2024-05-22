import 'package:flutter/material.dart';
import 'package:houzi_package/buddypress/providers/activity_provider.dart';
import 'package:houzi_package/common/constants.dart';
import 'package:houzi_package/files/generic_methods/utility_methods.dart';
import 'package:houzi_package/pages/home_screen_drawer_menu_pages/user_related/user_signin.dart';
import '../../files/hive_storage_files/hive_storage_manager.dart';
import '../models/activity.dart';
import '../views/new_comment.dart';
import '../../files/hive_storage_files/hive_storage_manager.dart';
import 'package:provider/provider.dart';

class ActivityComments extends StatefulWidget {
  final int? commentCount;
  final ValueChanged<int> onCommentCountUpdated;
  final List<Comment>? comments;
  final int activityId;
  final bool isLiked;

  const ActivityComments({
    Key? key,
    this.commentCount,
    required this.onCommentCountUpdated,
    required this.comments,
    required this.activityId,
    required this.isLiked,
  }) : super(key: key);

  @override
  _ActivityCommentsState createState() => _ActivityCommentsState();
}

class _ActivityCommentsState extends State<ActivityComments> {
  var likeColor;
  late bool isLikedLocally;

  @override
  void initState() {
    super.initState();
    likeColor = widget.isLiked ? Colors.blue : null;
    isLikedLocally = !widget.isLiked;
  }

  void _openAddCommentOverlay(BuildContext context) {
    showModalBottomSheet(
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 15.0,
        ),
        child: NewComment(
            comments: widget.comments, activityId: widget.activityId),
      ),
    );
  }

  void _openAddCommentOverlayOpenKbd(BuildContext context,
      {bool openKbd = false}) {
    showModalBottomSheet(
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 15.0,
        ),
        child: NewComment(
            comments: widget.comments,
            activityId: widget.activityId,
            openKbd: openKbd),
      ),
    );
  }

  void navigateToRoute(BuildContext context, WidgetBuilder builder) {
    UtilityMethods.navigateToRoute(context: context, builder: builder);
  }

  Future<bool> _likeActivity() async {
    final likeProvider = Provider.of<ActivityProvider>(context, listen: false);
    return await likeProvider.likeActivity(widget.activityId);
  }

  Future<bool> _dislikeActivity() async {
    final likeProvider = Provider.of<ActivityProvider>(context, listen: false);

    return await likeProvider.likeActivity(widget.activityId, isLiked: false);
  }

  @override
  Widget build(BuildContext context) {
    final int displayedCommentCount = widget.commentCount ?? 0;

    // Rest of your code...
    return GestureDetector(
      onTap: () {
        if (HiveStorageManager.isUserLoggedIn()) {
          _openAddCommentOverlay(context);
        } else {
          navigateToRoute(
            context,
            (context) => UserSignIn(
              (String closeOption) {
                if (closeOption == CLOSE) {
                  Navigator.pop(context);
                }
              },
            ),
          );
        }
      },
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: IconButton(
                  onPressed: () {
                    if (HiveStorageManager.isUserLoggedIn()) {
                      _openAddCommentOverlay(context);
                    } else {
                      navigateToRoute(
                        context,
                        (context) => UserSignIn(
                          (String closeOption) {
                            if (closeOption == CLOSE) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.comment),
                  iconSize: 20,
                ),
              ),
              Text(
                '$displayedCommentCount',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color.fromRGBO(112, 112, 112, 1),
                ),
              ),
              const Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: Text(
                  displayedCommentCount != 0
                      ? 'Ver comentarios'
                      : 'Hacer un comentario',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color.fromRGBO(112, 112, 112, 1),
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: 360,
            height: 1,
            color: const Color.fromRGBO(208, 208, 208, 1),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                      color: const Color.fromRGBO(208, 208, 208, 1),
                    ),
                    color: Colors.white,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (HiveStorageManager.isUserLoggedIn()) {
                        _openAddCommentOverlay(context);
                      } else {
                        navigateToRoute(
                          context,
                          (context) => UserSignIn(
                            (String closeOption) {
                              if (closeOption == CLOSE) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        );
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Comentar...',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color.fromRGBO(112, 112, 112, 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20.0, left: 8.0),
                child: IconButton(
                  onPressed: () async {
                    if (HiveStorageManager.isUserLoggedIn()) {
                      setState(() {
                        likeColor = isLikedLocally ? Colors.blue : null;
                        isLikedLocally = !isLikedLocally;
                      });

                      bool success;
                      if (isLikedLocally) {
                        success = await _likeActivity();
                        setState(() {
                          final likeProvider = Provider.of<ActivityProvider>(
                              context,
                              listen: false);
                          likeProvider.fetchActivitiesForTab('favorites');
                          likeProvider.fetchActivitiesForTab('');
                          likeProvider.fetchActivitiesForTab('mentions');
                        });
                      } else {
                        success = await _dislikeActivity();
                        setState(() {
                          final likeProvider = Provider.of<ActivityProvider>(
                              context,
                              listen: false);
                          likeProvider.fetchActivitiesForTab('favorites');
                          likeProvider.fetchActivitiesForTab('');
                          likeProvider.fetchActivitiesForTab('mentions');
                        });
                      }

                      if (!success) {
                        // If the request fails, revert the UI changes
                        setState(() {
                          likeColor = widget.isLiked ? Colors.blue : null;
                        });
                        // Show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Failed to perform action. Please try again later.'),
                          ),
                        );
                      }
                    } else {
                      navigateToRoute(
                        context,
                        (context) => UserSignIn(
                          (String closeOption) {
                            if (closeOption == CLOSE) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.thumb_up),
                  color: likeColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
