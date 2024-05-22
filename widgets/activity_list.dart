import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import 'activity_comments.dart';
import 'activity_content_widget.dart';
import 'package:houzi_package/buddypress/widgets/profile_info.dart';

class ActivityListWidget extends StatelessWidget {
  final ValueChanged<int> onCommentCountUpdated;
  final String scope;

  const ActivityListWidget({
    Key? key,
    required this.onCommentCountUpdated,
    required this.scope,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        if (!activityProvider.isLoaded) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Activity>? activities;
        if (scope.isEmpty) {
          activities = activityProvider.activitiesByTab[''];
        } else {
          activities = activityProvider.activitiesByTab[scope];
        }

        if (activities == null || activities.isEmpty) {
          return Center(
            child: Text("No se encontraron actividades"),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.maxScrollExtent ==
                scrollInfo.metrics.pixels) {
              // Reached the bottom of the list
              if (scope.isEmpty) {
                // Reload activities for the default scope
                activityProvider.loadMoreActivitiesForTab('');
              } else {
                // Load more activities for the specified scope
                activityProvider.loadMoreActivitiesForTab(scope);
              }
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () async {
              if (scope.isEmpty) {
                await activityProvider.fetchActivitiesForTab('');
              } else {
                await activityProvider.fetchActivitiesForTab(scope);
              }
            },
            child: ListView.builder(
              itemCount:
                  activities.length + 1, // Add 1 for the loading indicator
              itemBuilder: (context, index) {
                if (index < activities!.length) {
                  // Display activity item
                  String htmlData = activities[index].title;
                  String userAvatarUrl = activities[index].userAvatar.full;
                  String shareUrl = activities[index].link;
                  DateTime date = activities[index].dateGmt;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileInfo(
                        htmlData: htmlData,
                        userAvatarUrl: userAvatarUrl,
                        shareUrl: shareUrl,
                        date: date,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20.0,
                          top: 10.0,
                          right: 20.0,
                          bottom: 10.0,
                        ),
                        child: ActivityContentWidget(
                          htmlContent: activities[index].content.rendered,
                        ),
                      ),
                      ActivityComments(
                        activityId: activities[index].id,
                        commentCount: activities[index].commentCount,
                        onCommentCountUpdated: onCommentCountUpdated,
                        comments: activities[index].comments,
                        isLiked: activities[index].favorited ?? false,
                      ),
                    ],
                  );
                } else {
                  // Display loading indicator at the bottom
                  return _buildLoadingIndicator();
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
