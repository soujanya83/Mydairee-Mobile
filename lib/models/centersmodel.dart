
class CentersModel{
  String id;
  String centerName;
  String adressStreet;
  String addressCity;
  String addressState;
  String addressZip;

  CentersModel({
    this.id,
    this.centerName,
    this.adressStreet,
    this.addressCity,
    this.addressState,
    this.addressZip
    });

  static CentersModel fromJson(Map<String,dynamic> json){
    return CentersModel(
      id: json['id'],
      centerName: json['centerName'],
      adressStreet: json['adressStreet'],
      addressCity: json['addressCity'],
      addressState: json['addressState'],
      addressZip: json['addressZip']
    );
  }
}

