class TODOModel {
  int? id;
  String? title;
  String? desc;
  String? date;
  bool? isDone;

  TODOModel({this.id, this.title, this.desc, this.date, this.isDone});

  TODOModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    desc = json['desc'];
    date = json['date'];
    isDone = json['isDone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['desc'] = desc;
    data['date'] = date;
    data['isDone'] = isDone;
    return data;
  }
}
