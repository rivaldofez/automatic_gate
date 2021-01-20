class DataRaspberry {
  final double ambient;
  final double object;
  final double calibrate;
  final double threshold;
  final double relay;

  DataRaspberry({this.ambient, this.calibrate, this.object, this.relay, this.threshold});

  factory DataRaspberry.fromJSON(Map<dynamic, dynamic> json){
    double parser(dynamic source){
      try{
        return double.parse(source.toString());
      } on FormatException{
        return -1;
      }
    }
    return DataRaspberry(
      ambient: parser(json['ambient']),
      object: parser(json['object']),
      calibrate: parser(json['calibrate']),
      threshold: parser(json['threshold']),
      relay: parser(json['relay']));
  }
}