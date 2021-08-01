import 'package:database_practice_lite/helper/db_helper.dart';
import 'package:database_practice_lite/model/student_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  late Future fetchStudents;
  Mode mode = Mode.Insert;
  int? updateId;
  String searchedData = "";
  @override
  void initState() {
    super.initState();
    fetchStudents = dbh.getAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomePage"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                decoration: InputDecoration(hintText: "Search"),
                onChanged: (val) {
                  setState(() {
                    searchedData = val;
                    fetchStudents = dbh.getStudentBuName(data: searchedData);
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: FutureBuilder(
              future: fetchStudents,
              builder: (context, AsyncSnapshot ss) {
                if (ss.hasError) {
                  return Center(
                    child: Text("ERROR: ${ss.error}"),
                  );
                } else {
                  if (ss.hasData) {
                    List<Student> data = ss.data;
                    return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          leading: Text("${data[i].id}"),
                          title: Text("${data[i].name}"),
                          subtitle: Text("${data[i].age}"),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  // TODO: Update Student data
                                  mode = Mode.Update;
                                  _nameController.text = data[i].name;
                                  _ageController.text = data[i].age.toString();
                                  updateId = data[i].id;
                                  openForm();
                                },
                              ),
                              IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Delete Record"),
                                        content: Text(
                                            "Are you sure to delete this record?"),
                                        actions: [
                                          ElevatedButton(
                                            child: Text("Delete"),
                                            onPressed: () async {
                                              int deletedId = await dbh
                                                  .deleteStudent(data[i].id);
                                              Navigator.of(context).pop();
                                              if (deletedId == 1) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Data deleted with Id: ${data[i].id}..."),
                                                  ),
                                                );
                                                refreshStudents();
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.redAccent,
                                                onPrimary: Colors.white),
                                          ),
                                          OutlinedButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mode = Mode.Insert;
          openForm();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  openForm() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Form"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please enter your name .....";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: "Name", hintText: "Enter Name"),
                  ),
                  TextFormField(
                    controller: _ageController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Please enter your age .....";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: "Age", hintText: "Enter Age"),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                  onPressed: () {
                    setState(() {
                      Navigator.of(context).pop();
                      _nameController.clear();
                      _ageController.clear();
                    });
                  },
                  child: Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    //TODO:Insert into Database

                    if (mode == Mode.Insert) {
                      Student s = Student(
                          name: _nameController.text,
                          age: int.parse(_ageController.text));

                      int insertedId = await dbh.insertData(s);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Data inserted at Id: $insertedId"),
                        ),
                      );
                    } else {
                      int response = await dbh.updateStudent(
                        name: _nameController.text,
                        age: int.parse(_ageController.text),
                        id: updateId,
                      );
                      if (response == 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Updated Id: $updateId")),
                        );
                      }
                    }
                    Navigator.of(context).pop();
                    _nameController.clear();
                    _ageController.clear();
                    refreshStudents();
                  }
                },
                child: Text(mode == Mode.Insert ? "Insert" : "Update"),
              ),
            ],
          );
        });
  }

  refreshStudents() {
    setState(() {
      fetchStudents = dbh.getAllStudents();
    });
  }
}

enum Mode { Update, Insert }
