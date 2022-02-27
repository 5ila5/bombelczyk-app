import 'package:flutter/material.dart';
import 'ftp.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class Dateien extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FileList();
  }
}

class Breadcrumbs extends StatelessWidget {
  String path;
  String basePath;
  Function(
    String path,
  ) onclick = (String path) {};
  Breadcrumbs(this.path, {this.onclick, this.basePath});

  @override
  Widget build(BuildContext context) {
    if (this.basePath != null) {
      print("replace:");
      print(basePath);
      print("in");
      print(path);
      print("with \"\"");

      this.path = this.path.replaceFirst(basePath, "");
    }
    List<String> splittetPath = path.split("/");
    List<Widget> breadcrumbs = [];
    print(splittetPath.toString());
    if (splittetPath[splittetPath.length - 1] == "") {
      splittetPath.removeLast();
    }

    for (int i = 0; i < splittetPath.length; i++) {
      String pathToCurrentCrumb = "$basePath/";
      for (int k = 0; k < i; k++) {
        pathToCurrentCrumb += splittetPath[k] + "/";
      }
      print("pathToCurrentCrumb: $pathToCurrentCrumb");
      print("splittetPath: " + splittetPath[i]);

      breadcrumbs.addAll([
        InkWell(
          child: Text((splittetPath[i] == "") ? "home" : splittetPath[i]),
          onTap: () => onclick(pathToCurrentCrumb),
        ),
        Icon(Icons.arrow_right)
      ]);
    }

    splittetPath.forEach((String pathBit) {});
    return Row(children: breadcrumbs);
  }
}

class FileList extends StatefulWidget {
  FileList({Key key}) : super(key: key);

  @override
  FileListState createState() => FileListState();
}

class FileListState extends State<FileList> {
  FTPVerwalutng ftp;
  String basePath;
  String currentPath = "/";
  @override
  void initState() {
    super.initState();
    print("create FTPVerwalutng");
    ftp = new FTPVerwalutng("silas.lan.home", "user", "password", port: 2211);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
        child: Column(children: [
      //Text("hallo2"),
      Breadcrumbs(currentPath, basePath: this.basePath, onclick: (String path) {
        setState(() {
          currentPath = path;
        });
      }),
      FloatingActionButton(child: Text("sync"), onPressed: ftp.sync),
      FloatingActionButton(
        child: Text("refresh"),
        onPressed: () {
          setState(() {});
        },
      ),
      getFileWidget(),
    ]));
  }

  Future<List<Map<String, String>>> getFiles(String path) async {
    basePath = (await getApplicationDocumentsDirectory()).path + "/dokumente/";
    print("basePath: $basePath");
    if (path == "/") {
      path = basePath;
    }
    List<Map<String, String>> toReturn = [];
    List<FileSystemEntity> content = await dirContents(Directory(path));
    await Future.forEach(content, (FileSystemEntity data) async {
      toReturn.add(
          {"path": data.path, "type": (await data.stat()).type.toString()});

      //if ((await data.stat()).type == FileSystemEntityType.directory) {
      //  toReturn.addAll(await getFiles(data.path));
      //} else {}
    });
    return toReturn;
  }

  getFileWidget() {
    return FutureBuilder<List<Map<String, String>>>(
      future: getFiles(currentPath),
      //getFiles('/data/user/0/de.bombelczykaufzuege.bombelczyk/app_flutter'),

      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, String>>> snapshot) {
        List<Widget> toReturn = [Text("")];
        if (snapshot.hasData) {
          snapshot.data.forEach((Map<String, String> f) {
            toReturn.add(InkWell(
                onTap: f["type"] == "directory"
                    ? () {
                        setState(() {
                          currentPath = f["path"];
                        });
                      }
                    : () {
                        OpenFile.open(f["path"]);
                      },
                child: Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(f["type"] == "directory"
                            ? Icons.folder
                            : Icons.file_present),
                        Flexible(child: Text(f["path"])),
                      ],
                    ))));
          });
        } else if (snapshot.hasError) {
          toReturn.add(Text("An Error has occurred"));
        } else {
          toReturn.add(Text("loading ..."));
        }
        return Column(children: toReturn);
      },
    );
  }

  Future<List<FileSystemEntity>> dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen((file) => files.add(file),
        // should also register onError
        onDone: () => completer.complete(files));
    return completer.future;
  }
}
