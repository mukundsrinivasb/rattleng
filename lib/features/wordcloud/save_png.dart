/// Save Button allows the user to save to their chosen location
//
// Time-stamp: <Thursday 2024-06-06 05:58:50 +1000 Graham Williams>
//
/// Copyright (C) 2024, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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
/// Authors: Yixiang Yin, Graham Williams

library;

// Group imports by dart, flutter, packages, local. Then alphabetically.

// import 'dart:io';

// import 'package:flutter/material.dart';

// import 'package:rattle/features/wordcloud/select_file.dart';

// class WordCloudSaveButton extends StatelessWidget {
//   // Path to the word cloud temp image file.
//   final String wordCloudImagePath;

//   const WordCloudSaveButton({super.key, required this.wordCloudImagePath});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () async {
//         String? pathToSave = await selectFile();
//         if (pathToSave != null) {
//           // Copy generated image from /tmp to user's location.
//           await File(wordCloudImagePath).copy(pathToSave);
//         }
//       },
//       child: const Text('Save Word Cloud Image'),
//     );
//   }
// }
