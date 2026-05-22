import 'package:flutter/material.dart';
import 'package:tool_store_app/l10n/app_strings.dart';

extension L10nContext on BuildContext {
  AppStrings get s => AppStrings.current;
}
