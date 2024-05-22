import 'package:flutter/material.dart';
import '../helpers/html_parse_helper.dart';
import 'package:share_plus/share_plus.dart';

class ProfileInfo extends StatelessWidget {
  final String htmlData;
  final String? userAvatarUrl;
  final String shareUrl;
  final DateTime date;

  const ProfileInfo({
    Key? key,
    required this.htmlData,
    required this.userAvatarUrl,
    required this.shareUrl,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Container(
          width: 2,
          height: 40,
          color: Colors.blue,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 8, 8, 8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                image: NetworkImage('https:${userAvatarUrl ?? ""}'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HtmlParserHelper.extractProfile(htmlData) ?? "",
                  style: const TextStyle(
                      fontSize: 15.0, color: Color.fromRGBO(112, 112, 112, 1)),
                ),
                Text(
                  'Compartido ${HtmlParserHelper.getTimeAgo(date)}',
                  style: const TextStyle(
                    fontSize: 10.0,
                    color: Color.fromRGBO(112, 112, 112, 1),
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            //Use share_plus package to share the post
            Share.share(shareUrl);
            
            
          },
        ),
      ],
    );
  }
}
