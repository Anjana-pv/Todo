import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:todo/add_page.dart';
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fecteditems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo"),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fecteditems,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item["_id"] as String;
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: PopupMenuButton(onSelected: (value) {
                    if (value == 'edit') {
                       navigationtoEdit(item);
                    } else if (value == 'delete') {
                      deleteByid(id);
                    }
                  }, itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      )
                    ];
                  }),
                );
              }),
        ),
        child: const Center
        (child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToAddPage();
        },
        label:  const Text("Add"),
      ),
    );
  }
   Future<void> navigationtoEdit(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) =>  Addtodo(todo: item,),
    );
   await Navigator.push(context, route);
   setState(() {
     isLoading=true;
   });
   fecteditems();
  

  }






  Future <void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => const Addtodo(),
    );
   await Navigator.push(context, route);
   setState(() {
     isLoading=true;
   });
   fecteditems();
  }

  Future deleteByid(String id) async {
   final url = 'https://api.nstack.in/v1/todos/$id';

    final uri = Uri.parse(url);

    final response = await http.delete(uri);
    
    if (response.statusCode == 200) {
    
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item deleted'),
      ),
    );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cannot delete item'),
      ),
      );
    }
  }

  Future<void> fecteditems() async {
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
