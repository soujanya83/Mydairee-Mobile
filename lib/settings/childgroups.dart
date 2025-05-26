import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/settingsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/childgroupmodel.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/settings/addgroup.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class ChildGroups extends StatefulWidget {
  @override
  _ChildGroupsState createState() => _ChildGroupsState();
}

class _ChildGroupsState extends State<ChildGroups> {
  bool settingsDataFetched = false;
  List<ChildGroupsModel> _allGroups = [];

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  Future<void> _fetchData() async {
    SettingsApiHandler handler =
        SettingsApiHandler({"userid": MyApp.LOGIN_ID_VALUE});

    var data = await handler.getChildGroups();

    if (!data.containsKey('error')) {
      print(data);
      var groups = data['groups'];
      _allGroups = [];
      try {
        assert(groups is List);
        for (int i = 0; i < groups.length; i++) {
          _allGroups.add(ChildGroupsModel.fromJson(groups[i]));
        }
        settingsDataFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header.appBar(),
      drawer: GetDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: settingsDataFetched
              ? Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Child Groups',
                            style: Constants.header2,
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          // GestureDetector(
                          //     onTap: () async {},
                          //     child: Icon(
                          //       Entypo.select_arrows,
                          //       color: Constants.kButton,
                          //     )),

                          SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddGroup('add', ''))).then((value) {
                                if (value != null) {
                                  settingsDataFetched = false;
                                  setState(() {});
                                  _fetchData();
                                }
                              });
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Constants.kButton,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                  child: Text(
                                    '+ Add Group',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                )),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _allGroups.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          final group = _allGroups[index];
                          final childrenCount = group.children.length;
                          final showCount =
                              childrenCount > 5 ? 5 : childrenCount;

                          return Card(
                            elevation:
                                4, // Increased elevation for better depth
                            margin: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  16), // More rounded corners
                              side: BorderSide(
                                color: Colors.grey.shade200, // Subtle border
                                width: 1,
                              ),
                            ),
                            shadowColor: Colors.grey
                                .withOpacity(0.2), // Custom shadow color
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight:
                                    120, // Slightly taller minimum height
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.9),
                                    Colors.grey.shade50.withOpacity(0.9),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    16), // Match card border radius
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Header Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            group.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Container(
                                          height: 35,
                                          width: 35,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(
                                                0.1), // Subtle background
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(
                                                  0.3), // Light border
                                              width: 1,
                                            ),
                                          ),
                                          child: IconButton(   
                                              icon: Icon(Icons.edit_outlined,
                                                size:20), // Outlined version looks cleaner
                                            color: Colors.blue[700], // Deeper blue color
                                            padding: EdgeInsets.all(
                                                0), 
                                            constraints: BoxConstraints(
                                              minWidth:        
                                                  36, // Minimum touch target size
                                              minHeight: 36,
                                            ),
                                            splashRadius:
                                                15, // Controlled splash effect
                                            onPressed: () async {
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddGroup(
                                                          'edit', group.id),
                                                ),
                                              );
                                              if (result != null && mounted) {
                                                settingsDataFetched = false;
                                                setState(() {});
                                                _fetchData();
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 12),

                                    // Children Avatars
                                    if (childrenCount > 0)
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 60,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: showCount,
                                              itemBuilder: (context, i) {
                                                final child = group.children[i];
                                                return Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 12),
                                                  child: Container(
                                                    width: 48,
                                                    height: 48,
                                                    child: child['imageUrl'] !=
                                                                null &&
                                                            child['imageUrl'] !=
                                                                ''
                                                        ? CircleAvatar(
                                                            backgroundImage:
                                                                NetworkImage(
                                                              Constants
                                                                      .ImageBaseUrl +
                                                                  child[
                                                                      'imageUrl'],
                                                            ),
                                                          )
                                                        : CircleAvatar(
                                                            backgroundColor:
                                                                Colors
                                                                    .blue[100],
                                                            child: Text(
                                                              child['name']
                                                                      .isNotEmpty
                                                                  ? child['name']
                                                                          [0]
                                                                      .toUpperCase()
                                                                  : '?',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .blue[800],
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(height: 8),

                                          // More Button
                                          if (childrenCount > 5)
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: Size(50, 30),
                                                ),
                                                onPressed: () async {
                                                  final result =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddGroup(
                                                              'edit', group.id),
                                                    ),
                                                  );
                                                  if (result != null &&
                                                      mounted) {
                                                    settingsDataFetched = false;
                                                    setState(() {});
                                                    _fetchData();
                                                  }
                                                },
                                                child: Text(
                                                  '+${childrenCount - 5} more',
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      )
                                    else
                                      Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8),
                                        child: Text(
                                          'No children',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                )
              : Container(),
        ),
      ),
    );
  }
}
