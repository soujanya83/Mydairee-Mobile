import 'package:mykronicle_mobile/api/networking.dart';

import 'package:mykronicle_mobile/services/constants.dart';

var getReflection = Constants.BASE_URL + 'Reflections/getUserReflections';

var geteditReflection = Constants.BASE_URL + 'Reflections/getReflection';

// var planDetailsUrl = Constants.BASE_URL + 'Programplanlist/get_details_list';

// var planSupportUrl =
//     Constants.BASE_URL + 'Programplanlist/getprogramplandetails';

class ReflectionApiHandler {
  final Map<String, String> data;

  ReflectionApiHandler(this.data);

  Future<dynamic> getDetails() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(getReflection, this.data);

    var d = await helper.data();

    return d;
  }

  Future<dynamic> geteditDetails() async {
    ServiceWithHeaderDataPost helper =
        ServiceWithHeaderDataPost(geteditReflection, this.data);

    var d = await helper.data();

    return d;
  }
}
