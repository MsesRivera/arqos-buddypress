import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/activity.dart';

class RemoteService {
  final String _baseUrl = 'https://arqospv.com/wp-json';
  String? _token; // Store the access token here

  Future<void> initializeToken() async {
    _token = await fetchToken('msesrivera', 'arqos2237');
  }

  Future<String?> fetchToken(String username, String password) async {
    var uri = Uri.parse('$_baseUrl/jwt-auth/v1/token');
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      var token = jsonDecode(response.body)['token'];
      return token;
    } else {
      throw Exception('Failed to fetch token');
    }
  }

  // Future<List<Activity>?> getActivity() async {
  //   var client = http.Client();

  //   var uri =
  //       Uri.parse('$_baseUrl/buddypress/v1/activity?display_comments=threaded');
  //   var response =
  //       await client.get(uri, headers: {'Authorization': 'Bearer $_token'});
  //   if (response.statusCode == 200) {
  //     var json = response.body;
  //     return activityFromJson(json);
  //   }
  //   return null;
  // }

  Future<bool> postComment(
      {required String content, required int activityId}) async {
    // Ensure token and nonce are initialized before making the request
    await initializeToken();
    // var nonce = await fetchNonce();  Fetch nonce

    if (_token == null /*|| nonce == null*/) {
      throw Exception('Token or nonce not available');
    }

    var uri = Uri.parse('$_baseUrl/buddypress/v1/activity?display_comments=threaded');

    // Adjust the content structure
    var adjustedContent = {
      'context': 'edit',
      'user_id': 27,
      'type': 'activity_comment',
      'content': content,
      'primary_item_id': activityId,
      'component': 'activity',
      // Add other required parameters if necessary, such as user_id, component, etc.
    };

    var response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(adjustedContent),
    );

    // Check the status code of the response
    if (response.statusCode == 200) {
      return true; // Return true if the request was successful
    } else {
      return false; // Return false if the request failed
    }
  }

  Future<List<Activity>?> getActivity({int? activityId}) async {
    await initializeToken();
    var client = http.Client();

    var uri =
        Uri.parse('$_baseUrl/buddypress/v1/activity');
    if (activityId != null) {
      uri = Uri.parse(
          '$_baseUrl/buddypress/v1/activity?display_comments=threaded&include=$activityId');
    }

    var response =
        await client.get(uri, headers: {'Authorization': 'Bearer $_token'});
    if (response.statusCode == 200) {
      var json = response.body;
      return activityFromJson(json);
    }
    return null;
  }
}
