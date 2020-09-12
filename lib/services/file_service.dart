import 'dart:convert';
import 'dart:io';

import 'package:chatapp/models/chat_model.dart';
import 'package:path_provider/path_provider.dart';

class FileService
{
  String _path;
  File _file;
  File _imageFile;
  String _imageRef;

  FileService(this._path, this._imageRef);


  Future<void> createFile() async
  {
    var path = await getApplicationDocumentsDirectory();
    _file = new File(path.path + "/" + _path + ".json");
    _imageFile = File(path.path + "/" +  _imageRef + ".png");
    if(!await _file.exists())
    {
      _file.writeAsStringSync(json.encode(new List()));
    }
  }

  void writeToFile(List<ChatModel> messages)
  {
    try
    {
      List<Map<String, dynamic>> jsonString = List();
      messages.forEach((element) 
      { 
        jsonString.add(element.toJson());
      });
      _file.writeAsStringSync(json.encode(jsonString)); 
    }
    catch(e)
    { 
      print(e);
    }
  }

  List<ChatModel> readFile()
  {
    List<ChatModel> messages = List();
    try
    {
      List<dynamic> jsonFileContent = json.decode( _file.readAsStringSync());
      for(int counter = 0; counter < jsonFileContent.length; counter++)
      {
        messages.add(ChatModel.fromJson(jsonFileContent[counter]));
      }
    }
    catch(e)
    {
      print("error occured: " + e.toString());
    }
    return messages;
  }

  void saveImageToFile()
  {
    //Image image = Image.from();
    //_imageFile.writeAsBytesSync(encodePng(image));
  }
  
}