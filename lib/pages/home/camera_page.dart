import 'dart:io';
import 'package:camera/camera.dart';
import 'package:chatapp/services/message_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget 
{
  final List<CameraDescription> _cameras;
  final String _id;
  final Function _onDismissed;

  CameraPage(this._cameras, this._id, this._onDismissed);
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> 
{
  CameraController _cameraController;
  MessageService _messageService;
  bool _imageTaken = false;
  bool _resized = false;
  String path;

  @override
  void initState()
  {
    super.initState();
    _messageService = MessageService(widget._id);
    _cameraController = CameraController(widget._cameras[0], ResolutionPreset.max);
    _cameraController.initialize().then((_)
    {
      if(!mounted)
      {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose()
  {
    super.dispose();
    _cameraController?.dispose();
  }

  void takePhoto() async
  {
   try {

      path = (await getTemporaryDirectory()).path + DateTime.now().toString() + ".png";
      await _cameraController.takePicture(path);

      setState(() {
        _imageTaken = true;
      });
    } catch (e) {
      print(e);
    }
  }

  void sendImage()
  {
    _messageService.uploadFile(File(path));
    Navigator.of(context).pop();
  }

  Widget getTopRow()
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.keyboard_arrow_down),
        getActionsMenu()
      ],
    );
  }

  Widget getActionsMenu()
  {
    return Column(
      children: [
        Icon(
          Icons.flash_off,
          size: 30,
        ),
        SizedBox(height: 15,),
        Icon(
          Icons.switch_camera,
          size: 30,
        ),
        SizedBox(height: 15),
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: Colors.white38,
            shape: BoxShape.circle
          ),
          child: Center(
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 28,
            )
          ),
        )
      ],
    );
  }

  Widget getImageButton()
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
              Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.white,
                  width: 2
                )
              ),
              ),
              GestureDetector(
              onTap: () => takePhoto(),
              child: Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle
                ),
            ),
              ),
          ],
        )
      ],
    );
  }

  Widget getImage()
  {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ClipRRect(
        borderRadius: _resized ? BorderRadius.circular(20) : BorderRadius.zero,
        child: _imageTaken ? FittedBox(
          child: Image.file(File(path)), 
          fit: BoxFit.fitWidth,
        ) : CameraPreview(_cameraController)
      )
    );
  }
 
  @override
  Widget build(BuildContext context) 
  {
    if(!_cameraController.value.isInitialized)
    {
      return Container();
    }
    return Dismissible(
      key: Key("key"),
      direction: DismissDirection.down,
      onResize: () 
      {
        setState(() {
          _resized = true;
        });
      },
      onDismissed: (_) => widget._onDismissed(),
      child: WillPopScope(
        onWillPop: () => widget._onDismissed(),
              child: Scaffold(
    body: Stack(
    children: [
        getImage(),
        !_imageTaken ? Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getTopRow(),
              getImageButton()
            ],
          ),
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              onPressed: () => sendImage(),
              color: Colors.blue,
              child: Text("Send"),
            )
          ],
        )
    ],
          )
          ),
      ),
      );
  }
}