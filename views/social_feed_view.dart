import 'package:flutter/material.dart';
import 'package:houzi_package/buddypress/models/activity.dart';
import 'package:houzi_package/buddypress/services/remote_service.dart';
import 'package:houzi_package/buddypress/widgets/activity_list.dart';
import 'package:houzi_package/pages/home_page_screens/home_tabbed_related/related_widgets/home_tabbed_sliver_app_bar.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../files/app_preferences/app_preferences.dart';
import '../../files/generic_methods/utility_methods.dart';
import 'package:houzi_package/pages/home_page_screens/parent_home_related/parent_home.dart';

import '../providers/activity_provider.dart';
import '../../files/hive_storage_files/hive_storage_manager.dart';

class SocialFeedView extends Home {
  const SocialFeedView({super.key});

  @override
  _SocialFeedViewState createState() => _SocialFeedViewState();
}

class _SocialFeedViewState extends HomeState<SocialFeedView>
    with TickerProviderStateMixin {
  List<dynamic> homeConfigList = [];
  Map selectedHomeConfigItem = {};
  late TabController _tabController = TabController(length: 1, vsync: this);

  List<Activity>? activities;
  var isLoaded = false;
  String htmlData = '';
  int commentCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (super.userName.isNotEmpty) {
        _tabController = TabController(length: 3, vsync: this);
      }
      _initializeServices();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Remove _initializeServices() from here
  }

  Future<void> _initializeServices() async {
    Provider.of<ActivityProvider>(context, listen: false)
        .fetchActivitiesForTab('');
    if (super.userName.isNotEmpty) {
      Provider.of<ActivityProvider>(context, listen: false)
          .fetchActivitiesForTab('favorites');
      Provider.of<ActivityProvider>(context, listen: false)
          .fetchActivitiesForTab('mentions');
    }
  }

  void _updateCommentCount(int count) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          commentCount = count;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          HomeTabbedSliverAppBar(
            userName: super.userName,
            onLeadingIconPressed: () => {},
            homeTabbedSliverAppBarListener: null,
            isSocial: true,
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                tabs: HiveStorageManager.isUserLoggedIn()
                    ? const [
                        Tab(text: 'Para ti'),
                        Tab(text: 'Mis favoritos'),
                        Tab(text: 'Menciones'),
                      ]
                    : const [
                        Tab(text: 'Para ti'),
                      ],
                padding: const EdgeInsets.symmetric(horizontal: 10),
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: Colors.white,
                isScrollable: true,
                labelColor: Colors.white,
                controller: _tabController,
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: super.userName.isNotEmpty
            ? [
                ActivityListWidget(
                  scope: '', // Pass the selected tab index
                  onCommentCountUpdated: _updateCommentCount,
                ),
                ActivityListWidget(
                  scope: 'favorites', // Pass the selected tab index
                  onCommentCountUpdated: _updateCommentCount,
                ),
                ActivityListWidget(
                  scope: 'mentions', // Pass the selected tab index
                  onCommentCountUpdated: _updateCommentCount,
                ),
              ]
            : [
                ActivityListWidget(
                  scope: '', // Pass the selected tab index
                  onCommentCountUpdated: _updateCommentCount,
                ),
              ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppThemePreferences().appTheme.primaryColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
