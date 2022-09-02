import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart' as window_size;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translate_subtitles/constant/constant.dart';
import 'package:translate_subtitles/constant/translate_colors.dart';

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
      outPath = shap.getString(kTranslateOutPath);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
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
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
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
          Expanded(child: Text(inputDirectoryPath())),
          InkWell(
            child: const Icon(Icons.close_rounded),
            onTap: () async {
              files = null;
              setState(() {});
            },
          ),
          const SizedBox(width: 10),
          ElevatedButton(onPressed: _selectFile, child: const Text('选取目录')),
        ],
      ),
    );
  }

  String inputDirectoryPath() {
    String text = '';
    if ((files?.length ?? 0) > 0) {
      List<String>? list = files?.first.split('/');
      list?.removeLast();
      text = list?.join('/') ?? '';
    }
    return text;
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
              onTap: () async {
                outPath = null;
                SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.remove(kTranslateOutPath);
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
        allowedExtensions: ['srt', 'vtt'],
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
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString(kTranslateOutPath, outPath!);
      setState(() {});
    }
  }

  // 转换列表
  Widget buildConversionList() {
    return Expanded(
        child: ListView.builder(
      itemCount: files?.length ?? 0,
      itemBuilder: (context, index) {
        return Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: TranslateColors.itemBgColor,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(files?.elementAt(index).split('/').last ?? '',maxLines: 2,overflow: TextOverflow.ellipsis,),
              ),
              InkWell(
                child: const Icon(Icons.close_rounded),
                onTap: () {
                  setState(() {
                    files?.removeAt(index);
                  });
                },
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                child: const Text(kTranslateText),
                onPressed: () {},
              )
            ],
          ),
        );
      },
    ));
  }
}
