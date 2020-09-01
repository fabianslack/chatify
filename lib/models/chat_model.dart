class ChatModel
{
  String _content;
  int _timestamp;
  String _from;
  bool _liked;
  int _type;
  bool _received;

  ChatModel(this._content, this._timestamp, this._from, this._liked, this._type, this._received);

  ChatModel.fromDocumentSnapshot(var ref)
  {
     _content = ref["content"];
    _timestamp = ref["timestamp"];
    _from = ref["from"];
    _liked = ref["liked"];
    _type = ref["type"];
    _received = ref["received"];
  }

  ChatModel.fromJson(Map<String, dynamic> json)
  {
    _content = json["content"];
    _timestamp = json["timestamp"];
    _from = json["from"];
    _liked = json["liked"];
    _type = json["type"];
    _received = json["received"];
  }

  Map<String, dynamic> toJson() =>
  {
    'content' : _content,
    'timestamp' : _timestamp,
    'from' : _from,
    'type' : _type,
    'liked' : _liked,
    'received' : _received
  };

  String from() => _from;
  int timestamp() => _timestamp;
  int type() => _type;
  bool liked() => _liked;
  String content() => _content;
  bool received() => _received;
}