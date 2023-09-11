/// A button to choose a dataset (from file or a package).
///
/// Copyright (C) 2023, Togaware Pty Ltd.
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
///
// Licensed under the GNU General Public License, Version 3 (the "License");
///
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
/// Authors: Graham Williams

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rattle/models/dataset_model.dart';

class DatasetButton extends StatelessWidget {
  const DatasetButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Simulate selecting a file (you can use file picker libraries here).

        String selectedFileName = "rattle::weather";

        // Update the selected filename using the Provider.

        Provider.of<DatasetModel>(context, listen: false)
            .setPath(selectedFileName);
      },
      child: const Text("Dataset:"),
    );
  }
}
