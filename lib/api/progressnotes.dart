import 'package:mykronicle_mobile/api/networking.dart';

import 'package:mykronicle_mobile/services/constants.dart';

var getProgramNote = Constants.BASE_URL + 'ProgressNotes/getAllProgressNotes';

// var deletePlanUrl = Constants.BASE_URL + 'Programplanlist/delete';

// var planDetailsUrl = Constants.BASE_URL + 'Programplanlist/get_details_list';

// var planSupportUrl =
//     Constants.BASE_URL + 'Programplanlist/getprogramplandetails';

class ProgramNotesApiHandler {
  final Map<String, String> data;

  ProgramNotesApiHandler(this.data);

  Future<dynamic> getDetails() async {
    print(getProgramNote);
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getProgramNote, this.data);

    var d = await helper.data();

    return d;
  }
}
