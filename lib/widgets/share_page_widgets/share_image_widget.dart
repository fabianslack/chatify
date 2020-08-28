

import 'package:chatapp/widgets/share_page_widgets/share_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShareImageWidget extends ShareWidget
{
  ShareImageWidget(Function callback) : super(callback);

  @override
  Widget build(BuildContext context) 
  {
    return getBody("Share an image", context, Colors.pink[200], Colors.orangeAccent, Icons.image);
  }
}