import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:mykronicle_mobile/api/programplanapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/usermodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/hexconversion.dart';

class ViewPlan extends StatefulWidget {
  final String centerid;
  final String programid;

  ViewPlan(this.centerid, this.programid);

  @override
  _ViewPlanState createState() => _ViewPlanState();
}

class _ViewPlanState extends State<ViewPlan> {
  List<UserModel> users;
  bool usersFetched = false;
  List headers;
  List comments;
  TextEditingController cmnt;

  var unescape = new HtmlUnescape();

  @override
  void initState() {
    cmnt = TextEditingController();
    _load();
    super.initState();
  }

  void _load() async {
    var _objToSend = {
      'usertype': MyApp.USER_TYPE_VALUE,
      'userid': MyApp.LOGIN_ID_VALUE,
      'centerid': widget.centerid,
      'programid': widget.programid
    };

    ProgramPlanApiHandler apiHandler = ProgramPlanApiHandler(_objToSend);
    var data = await apiHandler.planDetails();

    var educators = data['get_details']['programusers'];
    print(educators);
    users = [];
    try {
      assert(educators is List);
      for (int i = 0; i < educators.length; i++) {
        users.add(UserModel.fromJson(educators[i]));
      }
      usersFetched = true;
      if (this.mounted) setState(() {});
    } catch (e) {
      print(e);
    }

    var headData = data['get_details']['programheader'];
    headers = headData;

    var commentsData = data['get_details']['comments'];
    comments = commentsData;

    if (this.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header.appBar(),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'View Program Plan',
                          style: Constants.header1,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      if (usersFetched)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Educators',
                                style: Constants.header2,
                              ),
                              Container(
                                height: 100,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: users.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: CircleAvatar(
                                          radius: 40,
                                          backgroundImage: NetworkImage(users[
                                                          index]
                                                      .imageUrl !=
                                                  ""
                                              ? Constants.ImageBaseUrl +
                                                  users[index].imageUrl
                                              : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                                        ),
                                      );
                                    }),
                              )
                            ],
                          ),
                        ),
                      if (headers != null)
                        ListView.builder(
                            itemCount: headers.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Card(
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: HexColor(
                                                headers[index]['headingcolor'])
                                            .withOpacity(0.4),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(headers[index]
                                                  ['headingname'] ??
                                              ''),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Html(
                                            data: unescape.convert(
                                          headers[index]['perhaps'] ?? '',
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      if (comments != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Comments',
                                style: Constants.header2,
                              ),
                              TextField(
                                controller: cmnt,
                                decoration: InputDecoration(
                                    hintText: 'Add your comment here',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[300]),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.send),
                                      onPressed: () async {
                                        if (cmnt.text != '') {
                                          var objToSend = {
                                            "userid": MyApp.LOGIN_ID_VALUE,
                                            "user_comment":
                                                cmnt.text.toString(),
                                            "programplanparentid":
                                                widget.programid,
                                            "usertype": MyApp.USER_TYPE_VALUE,
                                            "centerid": widget.centerid
                                          };
                                          print(objToSend);
                                          ProgramPlanApiHandler planApiHandler =
                                              ProgramPlanApiHandler(objToSend);
                                          var data =
                                              await planApiHandler.addComment();
                                          print(data);
                                          if (data['Status'] == 'Success') {
                                            cmnt.clear();
                                            _load();
                                            setState(() {});
                                          }
                                        } else {
                                          MyApp.ShowToast(
                                              'Comment should not be empty',
                                              context);
                                        }
                                      },
                                    )),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                  itemCount: comments.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Card(
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(comments[
                                                      index]['imageUrl'] !=
                                                  "" && comments[
                                                      index]['imageUrl'] !=
                                                  null
                                              ? Constants.ImageBaseUrl +
                                                  comments[index]['imageUrl']
                                              : 'https://www.alchinlong.com/wp-content/uploads/2015/09/sample-profile.png'),
                                        ),
                                        title: Text(
                                          comments[index]['name']??'',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                            comments[index]['commenttext']??''),
                                      ),
                                    );
                                  })
                            ],
                          ),
                        )
                    ])))));
  }
}
