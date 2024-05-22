
import 'package:flutter/material.dart';
import 'package:houzi_package/buddypress/models/activity.dart';
import 'package:houzi_package/buddypress/widgets/activity_content_widget.dart';
import '../helpers/html_parse_helper.dart'; // Import the helpers file where the methods are defined

class CommentWidget extends StatelessWidget {
  final Comment comment;

  const CommentWidget({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String htmlData = comment.title;
    String userAvatar = comment.userAvatar.thumb;
    DateTime date = comment.date;
    String htmlContent = comment.content.rendered;
    String? username = HtmlParserHelper.extractProfile(htmlData);
    String timeAgo = HtmlParserHelper.getTimeAgo(date);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  image: NetworkImage('https:$userAvatar'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: 2,
              margin: const EdgeInsets.symmetric(horizontal: 15.0),
              color: Colors.blue,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username ?? "Unknown User",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(112, 112, 112, 1),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ActivityContentWidget(htmlContent: htmlContent),
                  Row(
                    children: [
                      // IconButton(
                      //   iconSize: 15.0,
                      //   icon: Icon(Icons.favorite,),
                      //   onPressed: () {
                      //     // Handle like button press
                      //   },
                      // ),
                      Text(timeAgo),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
