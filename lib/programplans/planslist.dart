import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:mykronicle_mobile/api/programplanapi.dart';
import 'package:mykronicle_mobile/api/utilsapi.dart';
import 'package:mykronicle_mobile/main.dart';
import 'package:mykronicle_mobile/models/centersmodel.dart';
import 'package:mykronicle_mobile/programplans/addplan.dart';
import 'package:mykronicle_mobile/programplans/createplan.dart';
import 'package:mykronicle_mobile/programplans/viewplan.dart';
import 'package:mykronicle_mobile/services/constants.dart';
import 'package:mykronicle_mobile/utils/header.dart';
import 'package:mykronicle_mobile/utils/platform.dart';

class PlansList extends StatefulWidget {
  @override
  _PlansListState createState() => _PlansListState();
}

class _PlansListState extends State<PlansList> {
  List<CentersModel> centers = [];
  bool centersFetched = false;
  int currentIndex = 0;
  var planList;
  List progHead = [];

  @override
  void initState() {
    _fetchCenters();
    super.initState();
  }

  Future<void> _fetchCenters() async {
    UtilsAPIHandler hlr = UtilsAPIHandler({});
    var dt = await hlr.getCentersList();
    print(dt);
    if (!dt.containsKey('error')) {
      print(dt);
      var res = dt['Centers'];
      centers = [];
      try {
        assert(res is List);
        for (int i = 0; i < res.length; i++) {
          centers.add(CentersModel.fromJson(res[i]));
        }
        centersFetched = true;
        if (this.mounted) setState(() {});
      } catch (e) {
        print(e);
      }
    } else {
      MyApp.Show401Dialog(context);
    }

    _fetchData();
  }

  bool _loading = true;
  void _fetchData() async {
    try {
      if (this.mounted)
        setState(() {
          _loading = true;
        });
      var _objToSend = {
        // "usertype": MyApp.USER_TYPE_VALUE,
        "userid": MyApp.LOGIN_ID_VALUE,
        "centerid": centers[currentIndex].id
      };
      ProgramPlanApiHandler planApiHandler = ProgramPlanApiHandler(_objToSend);
      var data = await planApiHandler.getProgramPlanList();
      print('+++++++++++++mfkdmkfmdkfmkdfmkf++++++++');
      print(data);
      planList = data['data'];
      print('==========data========');
      print(data);
      //  progHead=data['get_details']['']
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
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
                child: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                      Row(
                        children: [
                          Text(
                            'Program Plan',
                            style: Constants.header1,
                          ),
                          Expanded(
                            child: Container(),
                          ),
                          if (MyApp.USER_TYPE_VALUE != 'Parent')
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddPlan(
                                            'add',
                                            centers[currentIndex].id,
                                            '',
                                            null,
                                            null))).then((value) {
                                  _fetchData();
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
                                      'Add Plan',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  )),
                            )
                        ],
                      ),
                      centersFetched
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: DropdownButtonHideUnderline(
                                child: Container(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Constants.greyColor),
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Center(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: centers[currentIndex].id,
                                        items:
                                            centers.map((CentersModel value) {
                                          return new DropdownMenuItem<String>(
                                            value: value.id,
                                            child: new Text(value.centerName),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          for (int i = 0;
                                              i < centers.length;
                                              i++) {
                                            if (centers[i].id == value) {
                                              setState(() {
                                                currentIndex = i;
                                                _fetchData();
                                              });
                                              break;
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      Builder(builder: (context) {
                        if (_loading)
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * .7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Constants.kButton,
                                ),
                              ],
                            ),
                          );
                        if (planList == null || planList!.isEmpty)
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * .7,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('No Program Plan Found'),
                              ],
                            ),
                          );

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: planList.length,
                          itemBuilder: (context, index) {
                            final plan = planList[index];
                            return PlanCard(
                              plan: plan,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddPlan(
                                      'edit',
                                      centers[currentIndex].id,
                                      plan['id'],
                                      null,
                                      plan,
                                    ),
                                  ),
                                ).then((value) {
                                  _fetchData(); // Refresh data after returning
                                });
                              },
                              onDelete: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: Text('Confirm Delete'),
                                      content: Text(
                                          'Are you sure you want to delete this program plan?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(dialogContext).pop();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(dialogContext).pop();

                                            Map<String, String> objToSend = {
                                              "user_id": MyApp.LOGIN_ID_VALUE,
                                              "program_id":
                                                  plan['id'].toString(),
                                            };

                                            ProgramPlanApiHandler apiHandler =
                                                ProgramPlanApiHandler(
                                                    objToSend);
                                            var response =
                                                await apiHandler.deletePlan();

                                            if (response['Status'] == 'SUCCESS' ||
                                                response['Status'] ==
                                                    'Success' ||
                                                response['Status'] == true ||
                                                response['status'] == true ||
                                                response['status'] ==
                                                    'success') {
                                              MyApp.ShowToast(
                                                  'Program plan deleted successfully',
                                                  context);
                                              _fetchData();
                                            }
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              getMonthName: (value) =>
                                  _getMonthName(value as String?),
                              formatDate: (value) =>
                                  _formatDate(value as String?),
                              isSuperAdmin:
                                  MyApp.USER_TYPE_VALUE == 'Superadmin',
                              isParent: MyApp.USER_TYPE_VALUE == 'Parent',
                            );
                          },
                        );
                      })
                    ])))));
  }
}

class PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String Function(dynamic) getMonthName;
  final String Function(dynamic) formatDate;
  final bool isSuperAdmin;
  final bool isParent;

  const PlanCard({
    Key? key,
    required this.plan,
    required this.onEdit,
    required this.onDelete,
    required this.getMonthName,
    required this.formatDate,
    required this.isSuperAdmin,
    required this.isParent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          elevation: 0,
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${getMonthName(plan['months'])} ${plan['years']}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.primaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSuperAdmin || !isParent)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSuperAdmin)
                              _ActionButton(
                                icon: Icons.edit_rounded,
                                onPressed: onEdit,
                                color: theme.primaryColor,
                              ),
                            if (!isParent) const SizedBox(width: 8),
                            if (!isParent)
                              _ActionButton(
                                icon: Icons.delete_rounded,
                                onPressed: onDelete,
                                color: Colors.red[400]!,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Content Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _InfoRow(
                        icon: Icons.meeting_room_rounded,
                        text: plan['room_name']?.toString() ?? 'Not specified',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.person_rounded,
                        text:
                            "Created by ${plan['creator_name']?.toString() ?? 'Unknown'}",
                      ),
                      if ((plan['inquiry_topic']?.toString() ?? '')
                          .isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.lightbulb_rounded,
                          text: "Topic: ${plan['inquiry_topic']}",
                        ),
                      ],
                      if ((plan['special_events']?.toString() ?? '')
                          .isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.event_rounded,
                          text: "Events: ${plan['special_events']}",
                        ),
                      ],
                    ],
                  ),
                ),

                // Footer Section
                const SizedBox(height: 16),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DateBadge(
                          label: "Created",
                          date: formatDate(plan['created_at']),
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(width: 12),
                        _DateBadge(
                          label: "Updated",
                          date: formatDate(plan['updated_at']),
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child:Material(
  color: Colors.transparent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onPressed,
    splashColor: color.withOpacity(0.2),
    highlightColor: color.withOpacity(0.1),
    hoverColor: color.withOpacity(0.05),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.05),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: 22,
        color: color,
      ),
    ),
  ),
)
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor.withOpacity(0.8),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.8),
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String label;
  final String date;
  final bool isDarkMode;

  const _DateBadge({
    required this.label,
    required this.date,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 150, // Prevents excessive widening
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "$label: $date",
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.7),
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

String _getMonthName(String? monthNumber) {
  if (monthNumber == null) return '-';
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  int index = int.tryParse(monthNumber) ?? 0;
  if (index >= 1 && index <= 12) {
    return months[index - 1];
  }
  return '';
}

String _formatDate(String? dateTimeString) {
  if (dateTimeString == null) return '-';
  try {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  } catch (e) {
    return '-';
  }
}
