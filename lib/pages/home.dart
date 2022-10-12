import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/models/todoey_model.dart';
import 'package:frontend/utilis/utilis.dart';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    fetchData();
    super.initState();
  }

  late bool ischecked;
  int done = 0;
  List<ToDo> myToDo = [];
  Future<List<dynamic>> fetchData() async {
    http.Response response = await http.get(Uri.parse(Utilis.url));
    try {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        data.forEach((toDo) {
          ToDo t = ToDo(
              id: toDo['id'],
              title: toDo['title'],
              desc: toDo['desc'],
              isDone: toDo['isDone'],
              date: toDo['date']);
          myToDo.add(t);
        });

        return data;
      }
    } catch (e) {
      Utilis.toatsMessage(e.toString());
    }
    throw Exception('Error');
  }

  mydelete(String id) async {
    try {
      await http.delete(Uri.parse('${Utilis.url}/$id'));
    } catch (e) {
      Utilis.toatsMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Full Stack Developer'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            PieChart(dataMap: {
              'Completed': done.toDouble(),
              'InComplete': (myToDo.length - done).toDouble()
            }),
            Expanded(
              child: FutureBuilder(
                future: fetchData(),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: ((context, index) {
                        ischecked = snapshot.data![index]['isDone'];
                        if (snapshot.data![index]['isDone'] == true) {
                          done += 1;
                        }
                        return Dismissible(
                          background: Container(
                            color: Colors.red,
                            child: const Icon(Icons.delete_forever),
                          ),
                          onDismissed: (direction) {
                            mydelete(snapshot.data![index]['id'].toString());
                            setState(() {
                              snapshot.data!.remove(snapshot.data![index]);
                              fetchData();
                            });
                          },
                          key: ValueKey<int>(snapshot.data![index]['id']),
                          child: Card(
                              child: ListTile(
                            title:
                                Text(snapshot.data![index]['title'].toString()),
                            subtitle: Text(snapshot.data![index]['desc']),
                            trailing: Checkbox(
                              value: ischecked,
                              onChanged: ((value) {
                                setState(() {
                                  ischecked = !ischecked;
                                  value = ischecked;
                                });
                              }),
                            ),
                          )),
                        );
                      }));
                },
              ),
            ),
          ],
        ));
  }
}
