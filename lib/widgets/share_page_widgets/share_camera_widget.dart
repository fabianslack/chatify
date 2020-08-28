import 'package:chatapp/widgets/share_page_widgets/share_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShareCameraWidget extends ShareWidget
{

  ShareCameraWidget(Function callback) : super(callback);

  @override
  Widget build(BuildContext context) 
  {
    return getBody("Take a photo or video", context, Colors.purple[400], Colors.lightBlue, CupertinoIcons.photo_camera_solid);
  }
}