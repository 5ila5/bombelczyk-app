import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ftpconnect/ftpconnect.dart';

class Config {
  static Map<String, DateTime> config;

  static Future<void> load() async {
    config = {};
    SharedPreferences prefs = await Preferences.getPrefs();
    String response = prefs.getString("FTPFilestate");
    if (response != null && response != "") {
      Map<String, String> strStrMap = jsonDecode(response);
      strStrMap.forEach(
          (String key, String value) => {config[key] = DateTime.parse(value)});
    }
  }

  static List<String> getPathList() {
    List<String> pathList = [];
    config.forEach((String key, DateTime value) {
      pathList.add(key);
    });
    return pathList;
  }

  static Future<void> save() async {
    SharedPreferences prefs = await Preferences.getPrefs();
    prefs.setString("FTPFilestate", toJson());
  }

  static String toJson() {
    String toReturn = "{";
    config
        .forEach((String key, DateTime value) => {toReturn += "$key: $value,"});
    toReturn = toReturn.substring(0, toReturn.length - 1) + "}";
    return toReturn;
  }

  static bool newer(String path, DateTime time) {
    if (!config.containsKey(path)) {
      return true;
    }
    if (config[path].isBefore(time)) {
      return true;
    }
    return false;
  }

  static void update(String path, DateTime time) {
    config[path] = time;
    save();
  }

  static bool exists(String path) {
    return config.containsKey(path);
  }
}

class FTPVerwalutng {
  FTPConnect ftpConnect;
  Directory _ftpDirectory;
  bool connected = false;
  List<Map<String, dynamic>> _filesToUpdate = [];
  int downloadFinishedPercent = 100;

  String server;
  String user;
  String password;
  int port;

  FTPVerwalutng(this.server, this.user, this.password, {this.port});

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory);
    return directory.path;
  }

  Future<void> connect() async {
    if (port == null) {
      this.ftpConnect = FTPConnect(
        server,
        user: user,
        pass: password,
      );
    } else {
      this.ftpConnect = FTPConnect(
        server,
        user: user,
        pass: password,
        port: port,
      );
      if (await this.ftpConnect.connect()) {
        print("connected successfully");
        connected = true;
      } else {
        print("connection error");
        connected = false;
      }
    }
  }

  void disconnect() {
    ftpConnect.disconnect();
  }

  Future<void> downloadOneFile(String path, String localPath) async {
    await ftpConnect.downloadFileWithRetry(
        path, File(localPath + "/" + "TMP.txt"));
  }

  Future<List<String>> checkForDeletedFiles() async {
    List<String> toDelete = [];

    await Future.forEach(Config.getPathList(), (String path) async {
      if (!await ftpConnect.existFile(path)) {
        toDelete.add(path);
      }
    });

    return toDelete;
  }

  Future<void> deleteLocalDepricatedFiles() async {
    await Future.forEach(await checkForDeletedFiles(), (String path) async {
      await File(path).delete();
    });
  }

  Future<void> checkForNewFiles(String path) async {
    print("checking in Folder: $path");
    bool changed = await ftpConnect.changeDirectory(path);

    print(changed
        ? "changed Dir succesfully"
        : "some error occured while changing directory");

    List<FTPEntry> content =
        await ftpConnect.listDirectoryContent(cmd: DIR_LIST_COMMAND.LIST);
    print("inhalt:" + content.toString());

    List<String> folderPaths = [];

    await Future.forEach(content, (FTPEntry element) async {
      if (element.type == FTPEntryType.DIR) {
        folderPaths.add(path + element.name + "/");
        //await checkForNewFiles(
        //   path + element.name + "/");

        //ftpConnect.downloadDirectory(
        //    element.name, Directory(localPath + "/" + element.name));

      } else if (element.type == FTPEntryType.FILE) {
        if (Config.newer(path + element.name, element.modifyTime)) {
          _filesToUpdate.add({
            "path": path,
            "name": element.name,
            "size": element.size,
            "modifyTime": element.modifyTime
          });
          //await ftpConnect.downloadFileWithRetry(
          //    element.name, File(localPath + "/" + element.name));
          //Config.update(path + element.name, element.modifyTime);
        }
      }
    });

    for (int i = 0; i < folderPaths.length; i++) {
      await checkForNewFiles(folderPaths[i]);
    }
  }

  int calculateTotalDownloadSize() {
    int size = 0;
    _filesToUpdate.forEach((Map<String, dynamic> file) {
      size += file["size"];
    });
    return size;
  }

  Future<void> download({Function(int) onPercentChanged}) async {
    if (_filesToUpdate == null || _filesToUpdate.length == 0) return;
    downloadFinishedPercent = 0;

    int totalDownload = calculateTotalDownloadSize();
    if (totalDownload == 0) {
      totalDownload = 1;
    }
    int downloadedSize = 0;

    for (int i = 0; i < _filesToUpdate.length; i++) {
      Map<String, dynamic> file = _filesToUpdate[i];

      String folder = file["path"];
      String localFolder = await _localPath + "/dokumente";

      if (!await Directory(folder).exists()) {
        await Directory(folder).create();
      }
      print("downloading: $folder" + file["name"]);
      ftpConnect.downloadFileWithRetry(
          folder + file["name"], File(localFolder + file["name"]));

      downloadedSize += file["size"];
      if (downloadFinishedPercent <
          ((downloadedSize / totalDownload) * 100).toInt()) {
        downloadFinishedPercent =
            ((downloadedSize / totalDownload) * 100).toInt();
        if (onPercentChanged != null) {
          onPercentChanged(downloadFinishedPercent);
        }
      }
      Config.update(folder + file["name"], file["modifyTime"]);
    }
  }

  Future<void> downloadOLD(String path, localPath) async {
    print("download path: $path localPath: $localPath");
    bool changed = await ftpConnect.changeDirectory(path);

    print(changed
        ? "changed Dir succesfully"
        : "some error occured while changing directory");

    List<FTPEntry> content =
        await ftpConnect.listDirectoryContent(cmd: DIR_LIST_COMMAND.LIST);
    print("inhalt:" + content.toString());

    content.forEach(await (FTPEntry element) async {
      if (element.type == FTPEntryType.DIR) {
        if (!await Directory(localPath + "/" + element.name).exists()) {
          await Directory(localPath + "/" + element.name).create();
        }
        await downloadOLD(
            path + element.name + "/", localPath + "/" + element.name);
        await ftpConnect.changeDirectory(path);

        //ftpConnect.downloadDirectory(
        //    element.name, Directory(localPath + "/" + element.name));

      } else if (element.type == FTPEntryType.FILE) {
        if (Config.newer(path + element.name, element.modifyTime)) {
          await ftpConnect.downloadFileWithRetry(
              element.name, File(localPath + "/" + element.name));
          Config.update(path + element.name, element.modifyTime);
        }
      }
    });
  }

  void sync() async {
    if (!connected) {
      await connect();
      if (!connected) {
        print("stop syncing not yet connected");
        return;
      }
    }
    Future<void> configLoader = Config.load();
    final path = await _localPath;
    final syncPath = "$path/dokumente";
    _ftpDirectory = Directory(syncPath);
    if (!await _ftpDirectory.exists()) {
      await _ftpDirectory.create();

      // ftpConnect.downloadDirectory(pRemoteDir, pLocalDir)

    }
    await configLoader;
    checkForNewFiles("/");
    download(onPercentChanged: (int value) => print(value));
    //downloadOneFile("/hallo/test2.txt", syncPath);
  }
}
