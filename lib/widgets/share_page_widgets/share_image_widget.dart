

import 'package:chatapp/widgets/share_page_widgets/share_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShareImageWidget extends ShareWidget
{
  ShareImageWidget(Function callback) : super(callback);

  Widget buildBody()
  {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image(
            image: AssetImage(
              "assets/background_share_widget.jpg",
            ),
            fit: BoxFit.fitWidth,
          ),
        ),
        Positioned(
         bottom: 20,
         left: 20,
         child: Text(
           "Share an image",
           style: TextStyle(
             color: Colors.white,
             fontSize: 26,
             fontWeight: FontWeight.w900
           )
         ),
       )
      ],
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return getBody(context, buildBody(), false);
  }
}