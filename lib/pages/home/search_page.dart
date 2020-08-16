
import 'package:chatapp/services/file_service.dart';
import 'package:chatapp/services/search.dart';
import 'package:chatapp/themes/theme.dart';
import 'package:chatapp/widgets/recent_search_widget.dart';
import 'package:chatapp/widgets/search_user_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget 
{
  bool _searching;
  String _query;
  SharedPreferences _preferences;
  SearchPage(this._searching, this._query, this._preferences);
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> 
{
  FileService _fileService = FileService();
  SearchService _searchService = SearchService();

  List<String> _recentID = List();

  double _height;
  double _width;

  bool _dataLoaded = false;

  Map<String, String> _searchResult = Map();

  void loadResults() async
  {
    if(widget._query.length > 0)
    {
      _searchResult = await _searchService.getSuggestionsUsers(widget._query);
      //_searchResult = _searchService.getUsernamesFromId(results);
      setState(() {
        _dataLoaded = true;
      });
    }
    else
    {
      _searchResult = Map();
    }
  }

  List<Widget> buildRecent()
  {
    List<Widget> widgets = List();
    _recentID.forEach((element) 
    {
      widgets.add(RecentSeachWidget(false, element, AssetImage("assets/logo.png"), false));
     });
    return widgets;
  }

  Widget getPreviewScreen()
  {
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColor
      ),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              "Recent users",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20
              )
            ),
          ),
          SizedBox(
            height: _height * 0.01,

          ),
          _recentID.length > 0 ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
              height: _recentID.length > 3 ? _height *0.4 : _height*0.2,
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
                children: buildRecent()
              ),
            ),
          ) : Container(),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              "Your favorite widgets",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20
              )
            ),
          ),
          SizedBox(
            height: _height * 0.01,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              //scrollDirection: Axis.horizontal,
              children: <Widget>[
                

              ],
            ),
          )
        ]
      ),
    );
  }

  

  Widget getSearchView()
  {
    return Container(
      height: _height,
      width: _width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        )
      ),
      child: _dataLoaded ? ListView.builder(
      shrinkWrap: true,
      itemCount: _searchResult.length,
      itemBuilder: (context, index) => 
      SearchUserWidget(_searchResult.values.elementAt(index),  AssetImage("assets/logo.png"), false, _searchResult.keys.elementAt(index),)
    ) : CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) 
  {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    loadResults();
    _recentID = widget._preferences.getStringList("recentSearches");
    return widget._searching ? getSearchView() : getPreviewScreen();
    
  }
}