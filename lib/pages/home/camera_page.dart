
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget 
{
  final List<CameraDescription> _cameras;

  CameraPage(this._cameras);
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> 
{
  CameraController _cameraController;

  @override
  void initState()
  {
    super.initState();
    _cameraController = CameraController(widget._cameras[0], ResolutionPreset.high);
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


 
  @override
  Widget build(BuildContext context) 
  {
    if(!_cameraController.value.isInitialized)
    {
      return Container();
    }
    return AspectRatio(
      aspectRatio: _cameraController.value.aspectRatio,
      child: CameraPreview(_cameraController),
    );
  }
}