import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/recipeapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/recipemodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';
import 'package:mykronicle_mobile/utils/videoitem.dart';

class ViewRecipe extends StatefulWidget {
  final String id;
  ViewRecipe({required this.id});

  @override
  _ViewRecipeState createState() => _ViewRecipeState();
}

class _ViewRecipeState extends State<ViewRecipe> {
  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  RecipeModel? _recipe;
  bool dataFetched = false;

  Future<void> _fetchData() async {
    RecipeAPIHandler handler = RecipeAPIHandler({"rid": widget.id});
    var data = await handler.getRecipeDetails();
    if (!data.containsKey('error')) {
      print(data);
      var res = data['Recipes'];

      _recipe = RecipeModel.fromJson(res);

      dataFetched = true;
      if (this.mounted) setState(() {});
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: GetDrawer(),
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _recipe != null
            ? Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recipe',
                      style: Constants.header1,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.grey,
                              size: 18,
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          _recipe?.itemName??'',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        )
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Ingredients',
                      style: Constants.head1,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: _recipe?.ingredients.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            children: [
                              Text(_recipe?.ingredients[index]['qty']??''),
                              SizedBox(width: 10),
                              Text(_recipe?.ingredients[index]['name'])
                            ],
                          );
                        }),
                    SizedBox(height: 15),
                    Text(
                      'Method',
                      style: Constants.head1,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(_recipe?.recipe != null ? (_recipe?.recipe??'') : ''),
                    SizedBox(height: 15),
                    Text(
                      'Media',
                      style: Constants.head1,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _recipe?.media.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _recipe?.media[index]['mediaType'] == 'Image'
                              ? Card(
                                  child: Container(
                                    child: Image.network(
                                      Constants.ImageBaseUrl +
                                          _recipe?.media[index]['mediaUrl'],
                                      height: 150,
                                      width: MediaQuery.of(context).size.width,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                )
                              : Card(
                                  child: Container(
                                    child: VideoItem(
                                        url: Constants.ImageBaseUrl +
                                            _recipe?.media[index]['mediaUrl']),
                                  ),
                                );
                        })
                  ],
                ),
              )
            : Container(),
      )),
    );
  }
}
