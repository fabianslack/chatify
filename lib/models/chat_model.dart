class ChatModel
{
  String _content;
  int _timestamp;
  String _from;
  int _type;

  bool _read;

  ChatModel.fromDocumentSnapshot(var ref)
  {
     _content = ref["content"];
    _timestamp = ref["timestamp"];
    _from = ref["from"];
    _type = ref["type"];

  }

  ChatModel.fromJson(Map<String, dynamic> json)
  {
    _content = json["content"];
    _timestamp = json["timestamp"];
    _from = json["from"];
    _type = json["type"];
  }

  Map<String, dynamic> toJson() =>
  {
    'content' : _content,
    'timestamp' : _timestamp,
    'from' : _from,
    'type' : _type,
  };

  bool operator ==(o)
  {
    return o.timestamp() == timestamp() && o.content() == content();
  }

  int get hashCode
  {
    return _content.hashCode * _timestamp.hashCode;
  }


  void setRead(bool read)
  {
    _read = read;
  }

  void setContent(String content)
  {
    _content = content;
  }

  void setType(int newType)
  {
    _type = newType;
  }

  String from() => _from;
  int timestamp() => _timestamp;
  int type() => _type;
  String content() => _content;
  bool read() => _read == null ? false : _read;
}