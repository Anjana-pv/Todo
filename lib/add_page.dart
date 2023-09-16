import 'dart:convert';

import 'package:flutter/material.dart';

import "package:http/http.dart" as http;

class Addtodo extends StatefulWidget {

  final Map? todo;
 
  const Addtodo({super.key,this.todo});

  @override
  State<Addtodo> createState() => _AddtodoState();
}

class _AddtodoState extends State<Addtodo> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController discriptioncontroller = TextEditingController();

bool isEdit=false;

@override
  void initState() {
    
    super.initState();
    final todo =widget.todo;
    if(todo !=null){
      isEdit=true;
      final title = todo['title'];
      final discription = todo['description'];
      titlecontroller.text =title;
     discriptioncontroller.text = discription;

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Todo" :'Add todo',
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: titlecontroller,
            decoration: const InputDecoration(hintText: "Title"),
          ),
          const SizedBox(
            height: 30,
          ),
          TextField(
            controller: discriptioncontroller,
            decoration: const InputDecoration(hintText: "Description"),
            minLines: 5,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(
            height: 40,
          ),
          Center(
            child: ElevatedButton(
              onPressed: isEdit? update :submitData,
              child:  Padding(
                padding: const EdgeInsets.all(17.0),
                child: Text(isEdit?'Update':'Submit'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future <void>update() async{
    final todo =widget .todo;
    if(todo==null){
      print("you fail");
      return;
    }
    final id =todo ['_id'];
  
   final title = titlecontroller.text;
    final description = discriptioncontroller.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,

    };
    final url='https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response= await http.put(
      uri,

     body: jsonEncode(body),
      headers:{'Content-Type': 'application/json'});

       if (response.statusCode == 200) {
      titlecontroller.clear();
      discriptioncontroller.clear();
      showSuccess('success');
    } else {
      showerror(' failed');
    }
  
}
  Future<void> submitData() async {
    final title = titlecontroller.text;
    final description = discriptioncontroller.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };
    const url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-type': 'application/json'});

    if (response.statusCode == 201) {
      titlecontroller.clear();
      discriptioncontroller.clear();
      showSuccess('created success');
    } else {
      showerror('created is failed');
    }
  }

  void showSuccess(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showerror(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Color.fromARGB(255, 246, 241, 240),
        ),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
