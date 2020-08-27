import 'package:chatapp/services/message_service.dart';
import 'package:chatapp/widgets/share_image_widget.dart';
import 'package:flutter/material.dart';

class SharePage extends StatefulWidget 
{
  final String _id;

  SharePage(this._id);

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> 
{
  MessageService _messageService;

  @override
  void initState()
  {
    super.initState();
    _messageService = MessageService(widget._id);
  }

  Widget getTopContainer()
  {
    return Container(
      height: 5,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[400]
      ),
    );
  }

  Widget getWidgetList()
  {
    return Column(
      children: [
        ShareImageWidget(_messageService.selectImage)
      ],
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10,),
        getTopContainer(),
        SizedBox(height: 20,),
        getWidgetList()
      ],
    );
  }
}