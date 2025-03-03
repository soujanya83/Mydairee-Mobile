import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:html/parser.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/observation/childdetails.dart';
import 'package:mykronicle_mobile/services/constants.dart';

Widget tagRemove(String htmlString, String type, String centerid, var context) {
  var data = removeAllHtmlTags(htmlString);
  var title = data[0];
  var tags = data[1];
  var ids = data[2];
  var tagType = data[3];
  var tagDataType = data[4];

  List<TextSpan> txt = [];
  int p = 0;
  print('heyey');
  print(title);
  for (int j = 0; j < tags.length; j++) {
    var startTag = tagType[j];
    final startIndexTag = title.indexOf(startTag);
    print(tagType[j]);
    print(startIndexTag);
    if (startIndexTag != 0) {
      txt.add(TextSpan(
        text: title.toString().substring(p, startIndexTag),
        style: type == 'heading' ? Constants.header3 : Constants.header5,
      ));
    }
    txt.add(TextSpan(
      text: tags[j],
      style: type == 'heading' ? Constants.header3 : Constants.header5,
      recognizer: TapGestureRecognizer()
        ..onTap = () async {
          if (ids[j].contains("Child") && centerid != '') {
            print(ids[j]);
            var startTag = "childid=";
            final startIndexTag = ids[j].indexOf(startTag) + startTag.length;

            String id = ids[j].toString().substring(startIndexTag);
            print(id);
            print(centerid);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChildDetails(
                          childId: id,
                          centerId: centerid,
                        )));
          } else if (ids[j].contains("user_Staff_") && centerid != '') {
            print(ids[j]);
          } else {
            print(ids[j]);
            print(tagDataType[j]);
            print(ids[j].toString().substring(6));
            var body = {
              "type": tagDataType[j],
              "tagid": ids[j].toString().substring(6),
              "userid": MyApp.LOGIN_ID_VALUE
            };
            UtilsAPIHandler utilsAPIHandler = UtilsAPIHandler(body);
            var data = await utilsAPIHandler.getActTagInfo();
            print('here');
            var details = data['Tag'];
            print(details);
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(details['title']),
                    content: Container(
                      color: Colors.white,
                      height: 500,
                      width: 350,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (details['imageUrl'] != null &&
                              details['imageUrl'] != '')
                            Image.network(
                              Constants.ImageBaseUrl + details['imageUrl'],
                              height: 120,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fill,
                            ),
                          Text(details['subject']??''),
                          SizedBox(
                            height: 20,
                          ),
                          if(details['extras']!=null)
                          Text(
                            "Extras",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                           if(details['extras']!=null)
                          Container(
                            height: 150,
                            child: ListView.builder(
                                itemCount: details['extras'].length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Icon(AntDesign.arrowright),
                                    title:
                                        Text(details['extras'][index]['title']),
                                  );
                                }),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Ok'))
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                });
          }
        },
    ));
    p = startIndexTag + tagType[j].length;
  }
  print('----------');
  if (tags.length == 0) {
    txt.add(TextSpan(
      text: title,
      style: type == 'heading' ? Constants.header3 : Constants.header5,
    ));
  } else {
    var startTag = tagType[tagType.length - 1];
    final startIndexTag = title.indexOf(startTag);

    txt.add(TextSpan(
      text: title.toString().substring(startIndexTag + startTag.length),
      style: type == 'heading' ? Constants.header3 : Constants.header5,
    ));
  }
  return RichText(text: TextSpan(children: txt));
}

List removeAllHtmlTags(String htmlString) {
  final document = parse(htmlString);
  var formatted = tokenize(document.body.text.toString());

  return formatted;
}

List tokenize(String tok) {
  print('4' + tok);
  const start = "<a";
  const end = "</a>";
  List str = [];
  List tagType = [];
  List tags = [];
  List ids = [];
  List tagDataType = [];
  String token = tok;

  for (int i = 0; i < token.length; i++) {
    token = token.substring(i);
    final startIndex = token.indexOf(start);
    final endIndex = token.indexOf(end, startIndex + start.length);
    if (startIndex != -1 && endIndex != -1) {
      str.add(token.substring(startIndex + start.length, endIndex));
      i = endIndex + 3;
    }
  }
  print('1' + str.toString());

  const startTag = "link=\"";
  const endTag = "\">";

  const start2Taga = "\">@";
  const start2Tagb = "\">#";

  const startTagData = "data-type=\"";
  const endTagData = "\" data-toggle";

  for (int j = 0; j < str.length; j++) {
    final startIndexTag = str[j].indexOf(startTag);
    final endIndexTag = str[j].indexOf(endTag);

    final startDataTagIndex = str[j].indexOf(startTagData);
    final endDataTagIndex = str[j].indexOf(endTagData);

    var start2 = str[j].indexOf(start2Taga);
    if (start2 == -1) {
      start2 = str[j].indexOf(start2Tagb);
    }
    print(startIndexTag);
    print(startTag.length);
    print(str[j].substring(startIndexTag + startTag.length));
    print(str[j].substring(startIndexTag + startTag.length, endIndexTag));
    print(endIndexTag);
    print(start2);
    if (startIndexTag != -1 && endIndexTag != -1) {
      tagType.add(
          str[j].substring(startIndexTag + startTag.length, endIndexTag) +
              "_" +
              str[j].substring(start2 + 2, str[j].length));
      ids.add(str[j].substring(startIndexTag + startTag.length, endIndexTag));
    }

    if (startDataTagIndex != -1) {
      tagDataType.add(str[j]
          .substring(startDataTagIndex + startTagData.length, endDataTagIndex));
    } else if (start2 != -1) {
      tagDataType.add("");
    }
  }
  print('hereeeeZ');

  const start2Tag1 = "\">@";
  const start2Tag2 = "\">#";

  print('3' + tagType.toString());
  for (int k = 0; k < str.length; k++) {
    var startIndexTag;

    if (str[k].indexOf(start2Tag1) != -1) {
      startIndexTag = str[k].indexOf(start2Tag1);
    } else {
      startIndexTag = str[k].indexOf(start2Tag2);
    }

    print("<a" + str[k] + "</a>");
    print(tagType[k]);
    tok = tok.replaceAll("<a" + str[k] + "</a>", tagType[k]);
    tags.add(
        str[k].toString().substring(startIndexTag + start2Tag1.length - 1));
  }

  print(tags);
  print(ids);
  print(tagType);
  List d = [parse(tok).documentElement.text, tags, ids, tagType, tagDataType];

  return d;
}

String removeHtmlData(String htmlString) {
  final document = parse(htmlString);
  final String parsedString = parse(document.body.text).documentElement.text;

  return parsedString;
}
