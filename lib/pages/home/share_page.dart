import 'package:camera/camera.dart';
import 'package:chatapp/pages/home/camera_page.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:chatapp/widgets/share_page_widgets/share_camera_widget.dart';
import 'package:chatapp/widgets/share_page_widgets/share_image_widget.dart';
import 'package:flutter/material.dart';

class SharePage extends StatefulWidget 
{
  final String _id;

  final MessageService _messageService;

  SharePage(this._id, this._messageService);

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> 
{
  List<CameraDescription> _cameras;


  @override
  void initState()
  {
    super.initState();
    loadCameras();
  }

  void loadCameras() async
  {
    _cameras = await availableCameras();
  }


  void navigateToCamera()
  {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, animation2) => CameraPage(_cameras, widget._id, (){}),
      transitionsBuilder: (context, animation, secondaryAnimation, child)
      {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.linear;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      }, 
      transitionDuration: Duration(milliseconds: 700)
      )
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
        children: [
          ShareImageWidget(widget._messageService.selectImage),
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShareCameraWidget(navigateToCamera),
              ShareCameraWidget(navigateToCamera),
            ],
          )
        ],
      ),
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