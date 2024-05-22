import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../files/hive_storage_files/hive_storage_manager.dart';
import '../models/activity.dart';
import '../utils/get_media_type.dart';

class ActivityProvider with ChangeNotifier {
  final _storage = FirebaseStorage.instance;

  List<Activity>? activities;
  bool isLoaded = false; // Add this line
  final String baseUrl = 'https://arqospv.com/wp-json';
  String? token0; // Store the access token here
  bool isUserLoggedIn = false;
  String? scope; // Add this line

  List<String> _mediaUrls = [];
  List<String> get mediaUrls => _mediaUrls;

  Map<String, List<Activity>> activitiesByTab = {};
  Map<String, int> _currentPageMap =
      {}; // Track current page number for each tab
  int _perPage = 10; // Number of activities per page
  // Boolean flag to track whether a load more operation is in progress
  bool _isLoadingMore = false;

  Future<void> uploadMedia(List<XFile> selectedMedia) async {
    for (var media in selectedMedia) {
      final mediaPath = media.path;

      // Check if file exists
      if (!await File(mediaPath).exists()) {
        print('Error: File not found: $mediaPath');
        continue;
      }

      final file = File(mediaPath);

      try {
        // Create a Firebase Storage reference
        final ref = FirebaseStorage.instance
            .ref()
            .child(getMediaType(mediaPath))
            .child(mediaPath.split('/').last);

        // Upload the file to Firebase Storage
        final uploadTask = ref.putFile(file);

        // Wait for the upload to complete
        final taskSnapshot = await uploadTask;

        // Get the download URL of the uploaded file
        final downloadUrl = await taskSnapshot.ref.getDownloadURL();

        _mediaUrls.add(downloadUrl);
      } catch (e) {
        print('Error: $e');
      }
    }

    notifyListeners();
  }

  Future<String?> fetchToken(String username, String password) async {
    var uri = Uri.parse('$baseUrl/jwt-auth/v1/token');
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

  Future<void> initializeToken() async {
    isUserLoggedIn = HiveStorageManager.isUserLoggedIn();
    if (!isUserLoggedIn) {
      return;
    } else {
      token0 = await HiveStorageManager.getUserToken();
    }
  }

  Future<List<Activity>?> getActivity({int? activityId, String? scope}) async {
    await initializeToken();
    isLoaded = false; // Reset isLoaded before fetching activities
    var client = http.Client();
    activities = [];

    var uri =
        Uri.parse('$baseUrl/buddypress/v1/activity?display_comments=threaded');

    // Include activityId if provided
    if (activityId != null) {
      uri = uri.replace(queryParameters: {
        'display_comments': 'threaded',
        'include': '$activityId',
      });
    }

    // Include scope if provided
    if (scope != null) {
      uri = uri.replace(queryParameters: {
        'display_comments': 'threaded',
        'scope': scope,
      });
    }

    // Modify headers based on whether the token is null or not
    Map<String, String> headers =
        isUserLoggedIn != false ? {'Authorization': 'Bearer $token0'} : {};

    var response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      print(scope);
      var json = response.body;
      activities = activityFromJson(json);
      isLoaded = true; // Update isLoaded when activities are fetched
      notifyListeners();
      return activities;
    } else {
      print('Failed to fetch activities: ${response.statusCode}');
      isLoaded = false; // Update isLoaded when fetching activities fails
      notifyListeners();
      return null;
    }
  }

  Future<bool> postComment(
      {required String content,
      required int activityId,
      required String nonce}) async {
    // Ensure token and nonce are initialized before making the request
    await initializeToken();
    // var nonce = await fetchNonce();  Fetch nonce

    if (token0 == null /*|| nonce == null*/) {
      throw Exception('Token or nonce not available');
    }

    var uri = Uri.parse('$baseUrl/buddypress/v1/activity');

    // Adjust the content structure
    var adjustedContent = {
      'context': 'edit',
      'user_id': HiveStorageManager.getUserId(),
      'type': 'activity_comment',
      'content': content,
      'primary_item_id': activityId,
    };

    var response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token0',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(adjustedContent),
    );

    if (response.statusCode == 200) {
      notifyListeners();
      return true; // Return true if the request was successful
    } else {
      return false; // Return false if the request failed
    }
  }

  Future<bool> postActivity({
    required String content,
    required String nonce,
  }) async {
    // Ensure token and nonce are initialized before making the request
    await initializeToken();

    if (token0 == null) {
      throw Exception('Token not available');
    }

    var uri = Uri.parse('$baseUrl/buddypress/v1/activity');

    // Adjust the content structure
    var adjustedContent = {
      'context': 'edit',
      'user_id': HiveStorageManager.getUserId(),
      'type': 'activity_update',
      'content': content,
    };

    var response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token0',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(adjustedContent),
    );

    if (response.statusCode == 200) {
      notifyListeners();
      return true; // Return true if the request was successful
    } else {
      return false; // Return false if the request failed
    }
  }

  Future<bool> likeActivity(int activityId, {bool isLiked = true}) async {
    await initializeToken();

    if (token0 == null) {
      throw Exception('Token not available');
    }

    var uri = Uri.parse('$baseUrl/buddypress/v1/activity/$activityId/favorite');

    try {
      var response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token0',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'context': 'edit', 'is_liked': isLiked}),
      );

      if (response.statusCode == 200) {
        notifyListeners();

        return true; // Return true if the request was successful
      } else {
        return false; // Return false if the request failed
      }
    } catch (e) {
      print('Error performing activity action: $e');
      return false; // Return false if there's an error
    }
  }

  Future<List<Activity>?> loadMoreActivities({
    int page = 1,
    int perPage = 10,
    String? scope,
  }) async {
    // Ensure token is initialized before making the request
    await initializeToken();

    var client = http.Client();

    var uri = Uri.parse('$baseUrl/buddypress/v1/activity');

    // Modify headers based on whether the token is null or not
    Map<String, String> headers =
        isUserLoggedIn ? {'Authorization': 'Bearer $token0'} : {};

    // Add query parameters for pagination
    uri = uri.replace(queryParameters: {
      'page': '$page',
      'per_page': '$perPage',
    });

    // Add scope parameter if provided
    if (scope != null) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'scope': scope,
      });
    }

    var response = await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      var json = response.body;
      List<Activity> newActivities = activityFromJson(json);

      // Filter out duplicate activities
      newActivities.removeWhere((newActivity) => activities!
          .any((existingActivity) => newActivity.id == existingActivity.id));

      if (newActivities.isNotEmpty) {
        // Append new activities to the existing list
        activities!.addAll(newActivities);
        // Update the scope only if it's different
        if (this.scope != scope) {
          this.scope = scope;
        }
      } else {
        // Notify the user that there are no more activities to load
        print('No more activities to load');
      }
      notifyListeners();
      return newActivities;
    } else {
      throw Exception('Failed to load more activities: ${response.statusCode}');
    }
  }

  Future<void> fetchActivitiesForTab(String tab) async {
    await initializeToken();
    var client = http.Client();
    print(tab);
    var uri = Uri.parse('$baseUrl/buddypress/v1/activity');
    var queryParameters = {'display_comments': 'threaded'};

    if (tab.isNotEmpty) {
      queryParameters['scope'] = tab;
    }

    uri = uri.replace(queryParameters: queryParameters);

    // Modify headers based on whether the token is null or not
    Map<String, String> headers =
        isUserLoggedIn ? {'Authorization': 'Bearer $token0'} : {};

    var response =
        await client.get(uri, headers: headers);

    if (response.statusCode == 200) {
      var json = response.body;
      activitiesByTab[tab] = activityFromJson(json) ?? [];
      isLoaded = true;
      notifyListeners();
    } else {
      isLoaded = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreActivitiesForTab(String tab) async {
    // Check if a load more operation is already in progress
    if (_isLoadingMore) {
      return;
    }

    // Set _isLoadingMore to true when starting to load more activities
    _isLoadingMore = true;
    await initializeToken();

    // Initialize the current page for the tab if not already initialized
    _currentPageMap.putIfAbsent(tab, () => 1);

    var currentPage = _currentPageMap[tab]!;
    var client = http.Client();
    var uri =
        Uri.parse('$baseUrl/buddypress/v1/activity?display_comments=threaded');
    var queryParameters = {
      'display_comments': 'threaded',
      'page': '${currentPage + 1}',
      'per_page': '$_perPage',
    };

    if (tab.isNotEmpty) {
      queryParameters['scope'] = tab;
    }

    uri = uri.replace(queryParameters: queryParameters);

    var response =
        await client.get(uri, headers: {'Authorization': 'Bearer $token0'});

    if (response.statusCode == 200) {
      var json = response.body;
      var newActivities = activityFromJson(json);

      // If new activities were fetched, update the current page for the tab
      if (newActivities.isNotEmpty) {
        _currentPageMap[tab] = currentPage + 1;
      }
      // Append the new activities to the existing list
      activitiesByTab[tab]?.addAll(newActivities);
      isLoaded = true;
      notifyListeners();
    } else {
      isLoaded = false;
      notifyListeners();
    }

    // Reset _isLoadingMore after completing the load more operation
    _isLoadingMore = false;
  }
}
