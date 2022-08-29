import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart' as window_size;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translate_subtitles/constant/constant.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    window_size.DesktopWindow.setMinWindowSize(const Size(375, 750));
    window_size.DesktopWindow.setMaxWindowSize(const Size(600, 1000));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '字幕翻译',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String>? files;
  String? outPath;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((shap) {
      outPath = shap.getString(C_OUTPATH);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.blueGrey,
        ),
        child: Column(
          children: <Widget>[
            buildSelectorFiles(),
            const SizedBox(height: 10),
            buildOutputPath(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.white54)),
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    AppBar(
                      title: const Text(
                          '翻译列表',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20,color: Colors.black),
                        ),
                      backgroundColor: Colors.white70,
                    ),
                    buildConversionList()
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 选择文件
  Widget buildSelectorFiles() {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.only(left: 16, right: 16),
      decoration: const BoxDecoration(color: Colors.white54),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                ...List.generate(files?.length ?? 0, (index) {
                  return buildFileItem(files!.elementAt(index), index);
                })
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(onPressed: _selectFile, child: const Text('选择文件')),
        ],
      ),
    );
  }

  // 文件选项
  Widget buildFileItem(String path, index) {
    return SizedBox(
      height: 30,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              path.split('/').last,
              maxLines: 1,
            ),
          ),
          InkWell(
            child: const Icon(Icons.close_rounded),
            onTap: () {
              files?.removeAt(index);
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  // 选择输出路径
  Widget buildOutputPath() {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 16, right: 16),
      decoration: const BoxDecoration(color: Colors.white54),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(outPath ?? '')),
          if (outPath != null) ...[
            InkWell(
              child: const Icon(Icons.close_rounded),
              onTap: () {
                outPath = null;
                setState(() {});
              },
            ),
            const SizedBox(width: 10)
          ],
          ElevatedButton(onPressed: _outputFilepath, child: const Text('输出路径'))
        ],
      ),
    );
  }

  // 选择文件
  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['srt'],
        lockParentWindow: true);
    if (result != null) {
      files = result.paths.map((e) => e!).toList();
      setState(() {});
    } else {
      // User canceled the picker
    }
  }

  // 输出文件路径
  void _outputFilepath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      outPath = selectedDirectory;
      setState(() {});
    }
  }

  // 转换列表
  Widget buildConversionList() {
    return Container();
  }
}
