class ChatModel
{
  String _content;
  int _timestamp;
  String _from;
  int _type;

  bool _read;

  ChatModel(this._content, this._timestamp, this._from, this._type)
  {
    _read = false;
  }

  ChatModel.fromDocumentSnapshot(var ref)
  {
     _content = ref["content"];
    _timestamp = ref["timestamp"];
    _from = ref["from"];
    _type = ref["type"];
    _read = false;
  }

  ChatModel.fromJson(Map<String, dynamic> json)
  {
    _content = json["content"];
    _timestamp = json["timestamp"];
    _from = json["from"];
    _type = json["type"];
    _read = json["read"];
  }

  Map<String, dynamic> toJson() =>
  {
    'content' : _content,
    'timestamp' : _timestamp,
    'from' : _from,
    'type' : _type,
    'read' : _read
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

  String from() => _from;
  int timestamp() => _timestamp;
  int type() => _type;
  String content() => _content;
  bool read() => _read;
}