import 'package:flutter/material.dart';
import 'package:mykronicle_mobile/api/observationapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/observation/assesmentstab/eylftab.dart';
import 'package:mykronicle_mobile/observation/assesmentstab/milestonestab.dart';
import 'package:mykronicle_mobile/observation/assesmentstab/montessoritabs.dart';
import 'package:mykronicle_mobile/observation/obsdata.dart';
import 'package:mykronicle_mobile/services/callbacks.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:provider/provider.dart';

class AssesmentsTabs extends StatefulWidget {
  final IndexCallback changeTab;
  final Map assesData;
  final Map viewData;
  AssesmentsTabs({required this.changeTab, required this.assesData, required this.viewData});
  @override
  _AssesmentsTabsState createState() => _AssesmentsTabsState();
}

class _AssesmentsTabsState extends State<AssesmentsTabs>
    with SingleTickerProviderStateMixin {
  TabController? _controller;
  // var data;
  // int load = 0;

  @override
  void initState() {
    print(widget.viewData);
    _controller = new TabController(length: tabCount(), vsync: this);
    super.initState();
  }

  int tabCount() {
    int count = 0;
    if (widget.viewData['montessori'] == '1') {
      count = count + 1;
    }
    if (widget.viewData['eylf'] == '1') {
      count = count + 1;
    }
    if (widget.viewData['devmile'] == '1') {
      count = count + 1;
    }
    return count;
  }

  // Future<void> _fetchData(String obid) async {
  //   ObservationsAPIHandler hand =
  //       ObservationsAPIHandler({"userid": MyApp.LOGIN_ID_VALUE, "obsid": obid});
  //   data = await hand.getAssesmentsData();
  //   load = 1;
  //   if (this.mounted) setState(() {});
  // }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var obs = Provider.of<Obsdata>(context);

    // if (load == 0) {
    //   _fetchData(obs.obsid);
    // }
    return Container(
      child: Column(
        children: <Widget>[
          new Container(
            child: DefaultTabController(
              length: tabCount(),
              child: new TabBar(
                isScrollable: true,
                controller: _controller,
                labelColor: Constants.kMain,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  if (widget.viewData['montessori'] == '1')
                    InkWell(
                      onTap: () {
                        print('=======Montessori=======');
                        print(widget.assesData['Montessori'].toString());
                      },
                      child: Tab(
                        text: 'Montessori',
                      ),
                    ),
                  if (widget.viewData['eylf'] == '1')
                    Tab(
                      text: 'EYLF',
                    ),
                  if (widget.viewData['devmile'] == '1')
                    Tab(
                      text: 'Developmental Milestones',
                    ),
                ],
              ),
            ),
          ),
          widget.assesData != null
              ? Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: new TabBarView(
                    controller: _controller,
                    children: <Widget>[
                      if (widget.viewData['montessori'] == '1')
                        MontessoriTabs(
                          count: widget.assesData['Montessori']['Subjects'].length,
                          data: widget.assesData['Montessori']['Subjects'],
                          totaldata: obs.data,
                          changeTab:(v){
                            _controller?.index = 1;
                          },
                        ),
                      if (widget.viewData['eylf'] == '1')
                        EylfTabs(
                          count: widget.assesData['EYLF']['outcome'].length,
                          data: widget.assesData['EYLF']['outcome'],
                          totaldata: obs.data,
                          changeTab: (v) {
                            _controller?.index = 2;
                          },
                        ),
                      if (widget.viewData['devmile'] == '1')
                        MilestonesTabs(
                          count: widget
                              .assesData['DevelopmentalMilestones']['ageGroups']
                              .length,
                          data: widget.assesData['DevelopmentalMilestones']
                              ['ageGroups'],
                          totaldata: obs.data,
                          changeTab: (v) {
                            print("moved");
                            widget.changeTab(2);
                          },
                        ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
