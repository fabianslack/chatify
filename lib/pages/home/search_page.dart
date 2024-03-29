import 'package:chatapp/services/search.dart';
import 'package:chatapp/themes/theme.dart';
import 'package:chatapp/widgets/search_widgets/recent_search_widget.dart';
import 'package:chatapp/widgets/search_widgets/search_user_widget.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget 
{
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin
{
  SearchService _searchService = SearchService();
  TextEditingController _controller = TextEditingController();

  List<String> _recentID = List();

  double _height;
  double _width;

  String _query;

  bool _dataLoaded = false;

  Map<String, String> _searchResult = Map();



  void loadResults() async
  {
    if(_query.length > 0)
    {
      _searchResult = await _searchService.getSuggestionsUsers(_query);
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

  
  Widget getSearchBar()
  {
    return PreferredSize(
      preferredSize: Size.fromHeight(100),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
        child: Row(
          children: [
             Container(
               padding: const EdgeInsets.only(left: 5),
               width: MediaQuery.of(context).size.width *0.8,
               height: 35,
               decoration: BoxDecoration(
                 color: Colors.grey[200],
                 borderRadius: BorderRadius.circular(10)
               ),
               child: Row(
                 children: [
                   Icon(
                     Icons.search,
                     size: 25,
                     color: Colors.grey[400],
                   ),
                   SizedBox(width: 2,),
                   Expanded(
                     child: TextField(
                       autofocus: true,
                       controller: _controller,
                       style: TextStyle(
                         color: Colors.black,
                       ),
                       decoration: InputDecoration(
                         isDense: true,
                         border: InputBorder.none,
                         focusedBorder: InputBorder.none,
                         enabledBorder: InputBorder.none,
                         errorBorder: InputBorder.none,
                         disabledBorder: InputBorder.none,
                         hintText: "Search",
                         hintStyle: TextStyle(
                           color: Colors.grey[600],
                           fontSize: 18
                         ),
                       ),
                       onChanged: (value)
                       {
                         setState(() {
                           _query = value;
                         });
                       }      
                     ),
                   )
                 ],
               ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18
                )
              )
            )
          ]
        ),
      ),
    );
  }

  Widget getBody()
  {
    return Column(

    );
  }

  Widget getSearchView()
  {
    return Container(
      height: _height*0.8,
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: getSearchBar(),
      //body: getBody(),
    );
    
  }
}