/// The main tabs-based interface for the Rattle app.
///
/// Time-stamp: <Thursday 2024-07-18 16:46:17 +1000 Graham Williams>
///
/// Copyright (C) 2023-2024, Togaware Pty Ltd.
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
///
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Graham Williams, Yixiang Yin

library;

// Group imports by dart, flutter, packages, local. Then alphabetically.

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:rattle/constants/app.dart';
import 'package:rattle/constants/wordcloud.dart';
import 'package:rattle/providers/dataset_loaded.dart';
import 'package:rattle/providers/path.dart';
import 'package:rattle/providers/stdout.dart';
import 'package:rattle/providers/target.dart';
import 'package:rattle/providers/vars.dart';
import 'package:rattle/r/console.dart';
import 'package:rattle/r/extract_vars.dart';
import 'package:rattle/r/source.dart';
import 'package:rattle/features/dataset/button.dart';
import 'package:rattle/features/dataset/panel.dart';
import 'package:rattle/tabs/debug/tab.dart';
import 'package:rattle/tabs/explore.dart';
import 'package:rattle/tabs/model.dart';
import 'package:rattle/tabs/script/tab.dart';
import 'package:rattle/utils/reset.dart';
import 'package:rattle/widgets/status_bar.dart';

// Define the [NavigationRail] tabs for the home page.

final List<Map<String, dynamic>> homeTabs = [
  {
    'title': 'Dataset',
    'icon': Icons.input,
    'widget': const DatasetPanel(),
  },
  {
    'title': 'Explore',
    'icon': Icons.insights,
    'widget': const ExploreTabs(),
  },
  {
    'title': 'Wrangle',
    'icon': Icons.transform,
    'widget': const Center(child: Text('COMING SOON: WRANGLE')),
  },
  {
    'title': 'Model',
    'icon': Icons.model_training,
    'widget': const ModelTabs(),
  },
  {
    'title': 'Evaluate',
    'icon': Icons.leaderboard,
    'widget': const Center(child: Text('COMING SOON: EVALUATE')),
  },
  {
    'title': 'Console',
    'icon': Icons.terminal,
    'widget': const RConsole(),
  },
  {
    'title': 'Script',
    'icon': Icons.code,
    'widget': const ScriptTab(),
  },
  {
    'title': 'Debug',
    'icon': Icons.work,
    'widget': const DebugTab(),
  },
];

class RattleHome extends ConsumerStatefulWidget {
  const RattleHome({super.key});

  @override
  ConsumerState<RattleHome> createState() => RattleHomeState();
}

class RattleHomeState extends ConsumerState<RattleHome>
    with SingleTickerProviderStateMixin {
  // We use a [tabController] to manager what scripts are run on moving from the
  // DATASET feature. The [tabController] keeps track of the selected index for
  // the NavigationRail.

  late TabController _tabController;

  // We will populate the app name and version.

  var _appName = 'Unknown';
  var _appVersion = 'Unknown';

  // Helper function to cleanup any wordcloud leftover files.

  // TODO 20240613 gjw DO WE NEED THIS?

  Future<void> deleteFileIfExists() async {
    // clean up the files from previous use
    File fileToDelete = File(wordCloudImagePath);
    if (await fileToDelete.exists()) {
      await fileToDelete.delete();
      debugPrint('File $wordCloudImagePath deleted');
    }
    File tmpImageFile = File(tmpImagePath);
    if (await tmpImageFile.exists()) {
      await tmpImageFile.delete();
      debugPrint('File $tmpImagePath deleted');
    }
  }

  // Helper function to load the app name and version.

  Future<void> _loadAppInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appName = packageInfo.packageName; // Set app version from package info
      _appVersion = packageInfo.version; // Set app version from package info
    });
  }

  void goToDatasetTab() {
    setState(() {
      _tabController.index = 0;
    });
  }

  @override
  void initState() {
    super.initState();

    // TODO 20240613 gjw IS THIS REQUIRED?

    deleteFileIfExists();

    // Get the app name and version.

    _loadAppInfo();

    // Create the [tabController] to manage what happens on leaving/entering
    // tabs.

    _tabController = TabController(length: homeTabs.length, vsync: this);

    // Add a listener to the TabController to perform an action when we leave
    // the tab.

    _tabController.addListener(() {
      // Check if we are leaving the tab, not entering it.

      if (!_tabController.indexIsChanging) {
        if (_tabController.previousIndex == 0) {
          String path = ref.read(pathProvider);

          // TODO 20240613 WE PROBABLY ONLY DO THIS FOR THE CSV FILES.

          if (path.isNotEmpty) {
            // On leaving the DATASET tab we set the variables and run the data
            // template if there is a dataset loaded, as indicated by the path
            // having a value.

            List<String> vars = rExtractVars(ref.read(stdoutProvider));

            ref.read(varsProvider.notifier).state = vars;
            ref.read(targetProvider.notifier).state = vars.last;
            rSource(context, ref, 'dataset_template');
          }
        }

        // You can also perform other actions here, such as showing a snackbar,
        // calling a function, etc.
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title aligned to the left.

        //title: const Text(appTitle),

        title: Row(
          children: [
            Image.asset(
              'assets/images/rattle_logo.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 20),
            const Text(appTitle),
          ],
        ),

        // Deploy the buttons aligned to the top right for actions.

        actions: [
          // While the version number is reported in the About popup but for
          // screenshots, during development it is useful to have the version
          // visiable at all times, particularly for a screenshot, so place it
          // on the title bar for now.

          Text('Version $_appVersion', style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 50),

          // RESET

          IconButton(
            icon: const Icon(
              Icons.autorenew,
              color: Colors.grey,
            ),
            onPressed: () {
              // TODO yyx 20240611 return focus to DATASET TAB and set the sub tabs to the first tabs (put it in reset)
              if (ref.read(datasetLoaded)) {
                showAlertPopup(context, ref, false);
              } else {
                reset(context, ref);
              }
            },
            tooltip: 'Press here to clear the current project and\n'
                'so start a new project with a new dataset.',
          ),

          // SAVE - Context specific.

          IconButton(
            icon: const Icon(
              Icons.save,
              color: Colors.grey,
            ),
            onPressed: () {
              debugPrint('SAVE PRESSED NO ACTION YET');
            },
            tooltip: 'TODO: Save the current view to file.',
          ),

          // INFO - ABOUT

          IconButton(
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationIcon: Image.asset(
                  'assets/images/rattle_logo.png',
                  width: 80,
                  height: 80,
                ),
                applicationName:
                    '${_appName[0].toUpperCase()}${_appName.substring(1)}',
                applicationVersion: 'Version $_appVersion',
                applicationLegalese: '© 2006-2024 Togaware Pty Ltd',
                children: [
                  const SelectableText('\nRattleNG is a modern rewrite of the '
                      'very popular Rattle Data Mining and Data Science tool.\n\n'
                      'Authors: Graham Williams, Yixiang Yin.'),
                ],
              );
            },
            icon: const Icon(
              Icons.info,
              color: Colors.blue,
            ),
          ),
        ],
      ),

      // Build the tab bar from the list of homeTabs, noting the tab title and
      // icon. We rotate the tab bar for placement on the left edge.

      body: Row(
        children: [
          SingleChildScrollView(
            child: IntrinsicHeight(
              // Because the height constraint is unbounded, we need to provide a height limit
              child: NavigationRail(
                selectedIndex: _tabController.index,
                onDestinationSelected: (int index) {
                  setState(() {
                    _tabController.index = index;
                  });
                },
                labelType: NavigationRailLabelType.all,
                destinations: homeTabs.map((tab) {
                  return NavigationRailDestination(
                    icon: Icon(tab['icon']),
                    label: Text(
                      tab['title'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                  );
                }).toList(),
                selectedLabelTextStyle: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelTextStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: homeTabs[_tabController.index]['widget'],
          ),
        ],
      ),

      bottomNavigationBar: const StatusBar(),
    );
  }
}
