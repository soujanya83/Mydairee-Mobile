import 'package:flutter/material.dart';

import 'package:mykronicle_mobile/progress_notes/progressote.dart';

import 'package:mykronicle_mobile/rooms/editchildren.dart';

import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class ChildBasicDetails extends StatefulWidget {
  final String centerid;
  final String roomid;
  final String childid;

  ChildBasicDetails({this.centerid, this.roomid, this.childid});
  @override
  _ChildBasicDetailsState createState() => _ChildBasicDetailsState();
}

class _ChildBasicDetailsState extends State<ChildBasicDetails>
    with TickerProviderStateMixin {
  TabController _controller;
  final List<Tab> topTabs = <Tab>[
    new Tab(text: 'Basic Details'),
    new Tab(text: 'Progress Note'),
  ];

  @override
  void initState() {
    super.initState();

    _controller = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header.appBar(),
      body: Column(
        children: [
          new Container(
            child: TabBar(
              labelColor: Constants.kMain,
              isScrollable: true,
              controller: _controller,
              tabs: topTabs,
            ),
          ),
          Expanded(
            child: TabBarView(controller: _controller, children: [
              new Container(
                child: EditChildren(
                  id: widget.roomid,
                  childid: widget.childid,
                  type: 'edit',
                ),
              ),
              new Container(
                child: ProgressNotesActivity(
                  childid: widget.childid,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
