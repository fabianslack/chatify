
import 'package:flutter/material.dart';

class RecentSeachWidget extends StatelessWidget 
{
  bool _friend;
  String _name;
  AssetImage _profileImage;
  bool _story;

  RecentSeachWidget(this._friend, this._name, this._profileImage, this._story);

  @override
  Widget build(BuildContext context) 
  {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow:<BoxShadow>[
          BoxShadow(
            color: Colors.grey[800],
            blurRadius: 10,
          )
        ]
      ),
      child: Column(
        children: <Widget>[
          Center(
            child: CircleAvatar(
              backgroundColor: _story ? Colors.red : Colors.grey[300],
              radius: 25,
              child: CircleAvatar(
                backgroundImage: _profileImage,
                radius: 23,
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height*0.02,
          ),
          Text(
            _name,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.03,
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)
              ),
              child: Center(
                child: Icon(
                  _friend ? Icons.chat : Icons.group_add,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}