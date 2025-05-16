import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aunth/add_new_task.dart';
import 'package:aunth/utils.dart';
import 'package:aunth/widgets/date_selector.dart';
import 'package:aunth/widgets/task_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance.collection('tasks');
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewTask(),
                ),
              );
            },
            icon: const Icon(
              CupertinoIcons.add,
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const DateSelector(),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('tasks').where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading tasks'),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final task = snapshot.data!.docs[index];
                    return Row(
                      children: [
                        Expanded(
                          child: Dismissible(
                            key: Key(task.id),
                            onDismissed: (direction) {
                              FirebaseFirestore.instance.collection('tasks').doc(task.id).delete();
                            },
                            child: TaskCard(
                              color: hexToColor(task['color']),
                              headerText: task['title'],
                              descriptionText: task['description'],
                              scheduledDate: task['date'].toString(),
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: strengthenColor(
                              const Color.fromRGBO(246, 222, 194, 1),
                              0.69,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            '10:00AM',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              );
  }),
          ],
        ),
      ),
    );
  }
}
