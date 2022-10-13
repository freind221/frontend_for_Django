import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/todo_model.dart';
import 'package:frontend/models/todoey_model.dart';
import 'package:frontend/utilis/utilis.dart';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';
import 'package:toggle_switch/toggle_switch.dart';

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

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  _showSheet(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 30, right: 30),
          child: Column(
            children: [
              const Text(
                'Add Your Task',
                style: TextStyle(color: Colors.lightBlueAccent, fontSize: 30),
              ),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                textAlign: TextAlign.center,
                autofocus: true,
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'description'),
                controller: descController,
                textAlign: TextAlign.center,
                autofocus: true,
              ),
              const SizedBox(
                height: 30,
              ),
              ToggleSwitch(
                minWidth: 80.0,
                cornerRadius: 20.0,
                activeBgColors: [
                  [Colors.green[800]!],
                  [Colors.red[800]!]
                ],
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                initialLabelIndex: 1,
                totalSwitches: 2,
                labels: const ['True', 'False'],
                radiusStyle: true,
                onToggle: (index) {
                  check = index;
                  setState(() {});
                },
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () {
                    updateData(
                        titleController.text, descController.text, check!, id!);
                  },
                  child: const Text('Update')),
              const SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () {
                  postData(titleController.text, descController.text);
                  Navigator.pop(context);
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: const Center(
                    child: Text(
                      'Add',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  int? id;
  int? check = 1;
  bool ischecked = false;
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
      setState(() {
        myToDo = [];
      });
    } catch (e) {
      Utilis.toatsMessage(e.toString());
    }
  }

  Future<void> postData(String title, String desc) async {
    try {
      final response = await http.post(
        Uri.parse(Utilis.url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, dynamic>{"title": title, "desc": desc, "isDone": false}),
      );

      if (response.statusCode == 201) {
        // If the server did return a 201 CREATED response,
        setState(() {
          myToDo = [];
          fetchData();
        });
      } else {
        throw Exception('Failed to create album.');
      }
    } catch (e) {
      Utilis.toatsMessage(e.toString());
    }
  }

  Future<void> updateData(String title, String desc, int index, int id) async {
    try {
      final response = await http.put(
        Uri.parse('${Utilis.url}/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          "title": title,
          "desc": desc,
          "isDone": index == 1 ? false : true
        }),
      );

      print(response.statusCode);

      if (response.statusCode == 200) {
        // If the server did return a 201 CREATED response,
        setState(() {
          myToDo = [];
          fetchData();
        });
      } else {
        throw Exception('Failed to create album.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    print(check);
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

                      return InkWell(
                        onDoubleTap: () {
                          setState(() {
                            id = snapshot.data![index]['id'];
                          });
                          showModalBottomSheet(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20)),
                              ),
                              context: context,
                              builder: ((context) => _showSheet(context)));
                        },
                        child: Dismissible(
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
                                  title: Text(snapshot.data![index]['title']
                                      .toString()),
                                  subtitle: Text(snapshot.data![index]['desc']),
                                  trailing: Checkbox(
                                      value: ischecked,
                                      onChanged: ((value) {})))),
                        ),
                      );
                    }));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        onPressed: () {
          showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              context: context,
              builder: ((context) => _showSheet(context)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
