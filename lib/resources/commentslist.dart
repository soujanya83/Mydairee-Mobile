import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/api/resourcesapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/removeTags.dart';

class CommentsList extends StatefulWidget {
  final String resourceId;
  CommentsList(this.resourceId);

  @override
  _CommentsListState createState() => _CommentsListState();
}

class _CommentsListState extends State<CommentsList> {
  // TextEditingController add;
  var res;

  static GlobalKey<FlutterMentionsState> add =
      GlobalKey<FlutterMentionsState>();

  List<Map<String, dynamic>> mentionUser = [];
  bool mChildFetched = false;

  @override
  void initState() {
    super.initState();
    //  add = new TextEditingController();
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
    // add.dispose();
  }

  Future<void> _fetchData() async {
    ObservationsAPIHandler handler2 =
        ObservationsAPIHandler({"userid": MyApp.LOGIN_ID_VALUE});

    var users = await handler2.getUsersList();
    print('hereee users');
    print(users);
    var usersList = users['UsersList'];
    mentionUser = [];
    try {
      assert(usersList is List);
      for (int i = 0; i < usersList.length; i++) {
        Map<String, dynamic> mChild = usersList[i];
        mChild['display'] = usersList[i]['name'];
        if (mChild['type'] == 'Staff') {
          mentionUser.add(mChild);
        }
      }
      mChildFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

    ResourceAPIHandler handler = ResourceAPIHandler(
        {'userid': MyApp.LOGIN_ID_VALUE, 'resourceId': widget.resourceId});

    var data = await handler.getCommentsList();

    if (!data.containsKey('error')) {
      res = data['commentsList'];
      print(res);
      setState(() {});
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header.appBar(),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: res != null
                    ? Container(
                        height: MediaQuery.of(context).size.height - 50,
                        child: ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) => Divider(),
                            itemCount: res.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                  title: Text(res[index]['name']),
                                  subtitle: tagRemove(res[index]['comment'],
                                      'title', '', context));
                            }),
                      )
                    : Container(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                      ),
                      // Container(
                      //   width: MediaQuery.of(context).size.width - 50,
                      //   child:

                      //  TextField(
                      //   controller: add,
                      //   decoration: InputDecoration(
                      //       disabledBorder: InputBorder.none,
                      //       hintStyle: TextStyle(color: Colors.grey),
                      //       hintText: ' add comment'),
                      // ),

                      // ),
                      if (mChildFetched)
                        Container(
                          width: MediaQuery.of(context).size.width - 40,
                          padding: const EdgeInsets.all(3.0),
                          // decoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(4),
                          //     border: Border.all(color: Colors.blueAccent)),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: FlutterMentions(
                              key: add,
                              suggestionPosition: SuggestionPosition.Top,
                              //  maxLines: 5,
                              minLines: 1,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                  disabledBorder: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: ' add comment'),
                              mentions: [
                                Mention(
                                    trigger: '@',
                                    style: TextStyle(
                                      color: Colors.amber,
                                    ),
                                    data: mentionUser,
                                    disableMarkup: true,
                                    matchAll: false,
                                    suggestionBuilder: (data) {
                                      return Container(
                                        padding: EdgeInsets.all(10.0),
                                        child: Row(
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                Text(data['name']),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ),
                        ),
                      Container(
                        width: 20,
                        child: GestureDetector(
                            onTap: () async {
                              String added =
                                  add.currentState?.controller?.markupText??'';

                              for (int i = 0; i < mentionUser.length; i++) {
                                if (added.contains(mentionUser[i]['name'])) {
                                  added = added.replaceAll(
                                      "@" + mentionUser[i]['name'],
                                      '<a href="user_${mentionUser[i]['type']}_${mentionUser[i]['id']}">@${mentionUser[i]['name']}</a>');
                                }
                              }

                              if (added.length > 0) {
                                ResourceAPIHandler handler =
                                    ResourceAPIHandler({
                                  'userid': MyApp.LOGIN_ID_VALUE,
                                  'resourceId': widget.resourceId,
                                  'comment': added
                                });
                                var data = await handler.addComment();
                                if (!data.containsKey('error')) {
                                  Navigator.pop(context, 'kill');
                                }
                              }
                            },
                            child: Icon(Icons.send)),
                      ),
                      Container(
                        width: 10,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
