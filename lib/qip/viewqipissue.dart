import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:mykronicle_mobile/api/qipapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/issuesmodel.dart';
import 'package:mykronicle_mobile/utils/header.dart';

class ViewIssue extends StatefulWidget {
  final IssuesModel issuesModel;
  final String type;
  final String qipId;
  final String areaId;
  final String elementId;
  ViewIssue(
      {required this.issuesModel, required this.type, required this.qipId, required this.areaId, required this.elementId});

  @override
  _ViewIssueState createState() => _ViewIssueState();
}

class _ViewIssueState extends State<ViewIssue> {
  TextEditingController issue, whatoutcome, measure, getoutcome;
  List<String> priority = ['HIGH', 'MEDIUM', 'LOW'];
  String selectedPriority = 'HIGH';
  List<String> status = ['CLOSED', 'OPEN'];
  String selectedStatus = 'CLOSED';
  DateTime date;

  @override
  void initState() {
    date = DateTime.now();
    issue = TextEditingController();
    whatoutcome = TextEditingController();
    measure = TextEditingController();
    getoutcome = TextEditingController();
    if (widget.type == 'edit') {
      date = DateTime.parse(widget.issuesModel.expectedDate);
      issue.text = widget.issuesModel.issueIdentified;
      whatoutcome.text = widget.issuesModel.outcome;
      measure.text = widget.issuesModel.successMeasure;
      getoutcome.text = widget.issuesModel.howToGetOutcome;
      selectedStatus = widget.issuesModel.status;
      selectedPriority = widget.issuesModel.priority;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: Header.appBar(),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Issues Identified',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(
                height: 4,
              ),
              TextField(
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(4),
                      ),
                    )),
                controller: issue,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'What outcome do you seek ?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(
                height: 4,
              ),
              TextField(
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(4),
                      ),
                    )),
                controller: whatoutcome,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'Priority',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(
                height: 4,
              ),
              DropdownButtonHideUnderline(
                child: Container(
                  height: 40,
                  width: size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Constants.greyColor),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: DropdownButton<String>(
                      //  isExpanded: true,
                      value: selectedPriority,
                      items: priority.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                       onChanged: (String? value)  {
                        selectedPriority = value!;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'By when',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(
                height: 4,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Constants.greyColor)),
                height: 35,
                width: size.width,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Text(
                        date != null
                            ? DateFormat("dd-MM-yyyy").format(date)
                            : '',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () async {
                            date = await _selectDate(context, date);

                            setState(() {});
                          },
                          child: Icon(
                            AntDesign.calendar,
                            color: Colors.grey[400],
                          ))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'Success Measure',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(
                height: 4,
              ),
              TextField(
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(4),
                      ),
                    )),
                controller: measure,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'How will you get the outcome',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(
                height: 4,
              ),
              TextField(
                decoration: InputDecoration(
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(4),
                      ),
                    )),
                controller: getoutcome,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              SizedBox(
                height: 4,
              ),
              DropdownButtonHideUnderline(
                child: Container(
                  height: 40,
                  width: size.width,
                  decoration: BoxDecoration(
                      border: Border.all(color: Constants.greyColor),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: DropdownButton<String>(
                      //  isExpanded: true,
                      value: selectedStatus,
                      items: status.map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                       onChanged: (String? value)  {
                        selectedStatus = value!;
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                  width: size.width,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (issue.text.toString() == '') {
                        MyApp.ShowToast('Issue should not be empty', context);
                      } else if (whatoutcome.text.toString() == '') {
                        MyApp.ShowToast(
                            'What outcome do you seek should not be empty',
                            context);
                      } else if (measure.text.toString() == '') {
                        MyApp.ShowToast('Measure should not be empty', context);
                      } else if (getoutcome.text.toString() == '') {
                        MyApp.ShowToast(
                            'How you will get outcome should not be empty',
                            context);
                      } else {
                        var _objToSend = {
                          "qipid": widget.qipId,
                          "areaid": widget.areaId,
                          "elementid": widget.elementId,
                          "issueIdentified": issue.text,
                          "outcome": whatoutcome.text,
                          "priority": selectedPriority,
                          "expectedDate": DateFormat("dd-MM-yyyy").format(date),
                          "successMeasure": measure.text,
                          "howToGetOutcome": getoutcome.text,
                          "userid": MyApp.LOGIN_ID_VALUE,
                          "status": selectedStatus
                        };
                        if (widget.type == 'edit') {
                          _objToSend['issueid'] = widget.issuesModel.id;
                        }
                        QipAPIHandler qipAPIHandler = QipAPIHandler(_objToSend);
                        await qipAPIHandler
                            .saveIssue()
                            .then((value) => Navigator.pop(context));
                      }
                    },
                    child: Text('Save'),
                  ))
            ],
          ),
        ),
      )),
    );
  }

  Future<DateTime> _selectDate(BuildContext context, DateTime dateTime) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: new DateTime(1800),
      lastDate: new DateTime(2100),
    );
    return picked;
  }
}
