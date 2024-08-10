/// A provider of the pseudo terminal running R.
///
/// Time-stamp: <Monday 2023-11-06 12:16:56 +1100 Graham Williams>
///
/// Copyright (C) 2023, Togaware Pty Ltd.
///
/// Licensed under the GNU General Public License, Version 3 (the "License");
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html
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

import 'dart:convert';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_io/io.dart' show Platform;
import 'package:xterm/xterm.dart';

import 'package:rattle/provider/stdout.dart';
import 'package:rattle/provider/terminal.dart';
import 'package:rattle/utils/clean_string.dart';

final ptyProvider = StateProvider<Pty>((ref) {
  // Create a pseudo termminal provider.

  Terminal terminal = ref.watch(terminalProvider);
  Pty pty = Pty.start("R", arguments: ["--no-save"]);

  // Options
  //   columns: terminal.viewWidth,
  //   rows: terminal.viewHeight,

  // Add a listener of the pty to show the pty output within the enclosing
  // terminal. I also want to capture the output for parsing in the app.

  pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen((data) {
    terminal.write(data);
    ref.read(stdoutProvider.notifier).state =
        ref.read(stdoutProvider) + cleanString(data);
  });

  pty.exitCode.then((code) {
    terminal.write('the process exited with exit code $code');
  });

  terminal.onOutput = (data) {
    // This gets called when a user types into the R console. So typing the
    // command `ls()` in the R conosle the command is echoed in the R
    // console. This is not capturing the output from the console.

    pty.write(const Utf8Encoder().convert(data));
  };

  terminal.onResize = (w, h, pw, ph) {
    pty.resize(h, w);
  };

  return pty;
});

/// We are only interested in running R on whichever desktop.
///
/// Linux and MacOS desktops initiate R simply through the R command. Windows
/// does an R.exe.

String get shell {
  return Platform.isWindows ? 'R.exe' : 'R';
}
