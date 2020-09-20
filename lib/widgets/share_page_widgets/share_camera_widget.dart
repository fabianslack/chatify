import 'package:chatapp/widgets/share_page_widgets/share_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShareCameraWidget extends ShareWidget
{

  ShareCameraWidget(Function callback) : super(callback);

  Widget buildBody()
  {

  }

  @override
  Widget build(BuildContext context) 
  {
    return getBody(context, buildBody(), true);
  }
}