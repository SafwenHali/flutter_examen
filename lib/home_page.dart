import 'package:contacts_app/contact.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}


Future<String> fetchRandomEmoji() async {
  final response = await http.get(Uri.parse('https://api.emojipedia.org/emojis/random/'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final imageUrl = data['image_url'];
    return imageUrl;
  } else {
    throw Exception('Failed to load random emoji');
  }
}


class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  List<Contact> contacts = List.empty(growable: true);
  bool showOnlyFirstOfMonth = false;

  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    contacts.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contacts List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  hintText: 'Contact Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ))),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contactController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: 'Contact Number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ))),
            ),
          const SizedBox(height: 10),
            TextField(
              controller: dateController,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(
                  hintText: 'Contact Birthday',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ))),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      //
                      String name = nameController.text.trim();
                      String contact = contactController.text.trim();
                      String date = dateController.text.trim();
                      if (name.isNotEmpty && contact.isNotEmpty) {
                        setState(() {
                          nameController.text = '';
                          contactController.text = '';
                          dateController.text = '';
                          contacts.add(Contact(name: name, contact: contact, date: date));
                        });
                      }
                      //
                    },
                    child: const Text('Save')),
                ElevatedButton(
                    onPressed: () {
                      //
                      String name = nameController.text.trim();
                      String contact = contactController.text.trim();
                      String date = dateController.text.trim();
                      if (name.isNotEmpty && contact.isNotEmpty) {
                        setState(() {
                          nameController.text = '';
                          contactController.text = '';
                          dateController.text = '';
                          contacts[selectedIndex].name = name;
                          contacts[selectedIndex].contact = contact;
                          contacts[selectedIndex].date = date;
                          selectedIndex = -1;
                        });
                      }
                      //
                    },
                    child: const Text('Update')),
              ],
            ),const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showOnlyFirstOfMonth = !showOnlyFirstOfMonth;
                });
              },
              child: Text(
                showOnlyFirstOfMonth
                    ? 'Show All Contacts'
                    : 'Show only born on the first of the month',
              ),
            ),

            const SizedBox(height: 10),
            contacts.isEmpty
                ? const Text(
                    'No Contact yet..',
                    style: TextStyle(fontSize: 22),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: showOnlyFirstOfMonth
                          ? contacts
                              .where((contact) =>
                                  contact.date.endsWith('-01'))
                              .toList()
                              .length
                          : contacts.length,
                      itemBuilder: (context, index) {
                        if (showOnlyFirstOfMonth &&
                            !contacts[index].date.endsWith('-01')) {
                          return SizedBox.shrink();
                        }
                        return getRow(index);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget getRow(int index) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              index % 2 == 0 ? Colors.deepPurpleAccent : Colors.purple,
          foregroundColor: Colors.white,
          child: Text(
            contacts[index].name[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contacts[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(contacts[index].contact),
            Text(contacts[index].date),
          ],
        ),
        trailing: SizedBox(
          width: 70,
          child: Row(
            children: [
              InkWell(
                  onTap: () {
                    //
                    nameController.text = contacts[index].name;
                    contactController.text = contacts[index].contact;
                    dateController.text = contacts[index].date;
                    setState(() {
                      selectedIndex = index;
                    });
                    //
                  },
                  child: const Icon(Icons.edit)),
              InkWell(
                  onTap: (() {
                    //
                    setState(() {
                      contacts.removeAt(index);
                    });
                    //
                  }),
                  child: const Icon(Icons.delete)),
            ],
          ),
        ),
      ),
    );
  }
}
