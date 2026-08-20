import 'package:shared_preferences/shared_preferences.dart';

const defaultReviewPromptLaunchCounts = {20, 100};

const _appLaunchCountKey = 'app_launch_count';

/// Records a successful app launch and reports whether this launch lands on
/// one of [reviewPromptLaunchCounts] (by default the 20th and 100th launch).
Future<bool> recordAppLaunch({
  Set<int> reviewPromptLaunchCounts = defaultReviewPromptLaunchCounts,
}) async {
  final preferences = await SharedPreferences.getInstance();
  final launchCount = (preferences.getInt(_appLaunchCountKey) ?? 0) + 1;
  final saved = await preferences.setInt(_appLaunchCountKey, launchCount);
  return saved && reviewPromptLaunchCounts.contains(launchCount);
}
