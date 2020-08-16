
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileService
{
  Future<String> get _localPath async
  {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async
  {
    final path = await _localPath;
    return File("$path/data.json");
  }

  Future<File> writeToFile(String key, String value) async
  {
    final file = await _localFile;

    file.writeAsString("$key : $value");
  }

  Future<String> readData() async
  {
    try 
    {
      final file = await _localFile;

    // Read the file.
      return await file.readAsString();
    } 
    catch (e) 
    {
    // If encountering an error, return 0.
      return null;
    }
  }

  void writeRecentSearchToFile(String searchString) async
  {
    final path = await getApplicationDocumentsDirectory();
    File file = File("$path/search.txt");

    try
    {
      file.writeAsString(searchString);
    }
    catch(e)
    {
      print(e);
    }
  }

  Future<List<String>> loadRecentSearch() async
  {
    File file = File("$_localPath/search.txt");

    return file.readAsLines();
  }
}