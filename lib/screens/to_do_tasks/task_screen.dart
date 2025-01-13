import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:todo_app/firebase/crud_task.dart';
import 'package:todo_app/model/task_model.dart';

import 'package:todo_app/screens/to_do_tasks/add_task_screen.dart';

DateTime scheduleTime = DateTime.now();

class ToDoListScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Adjust the number of tabs
      child: Scaffold(
        backgroundColor: Colors.white, // Set the whole background to white
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Today's Tasks",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey, // More vibrant color
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 2,
          bottom: TabBar(
            indicatorColor: Colors.blue, // Highlighted tab indicator color
            labelColor: Colors.blueGrey[700],
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Today's"),
              Tab(text: "Open"),
              Tab(text: "Completed"),
              Tab(text: "All"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskForToday(),
            _buildOpenTaskList(),
            _buildClosedTaskList(),
            _buildTaskListForToday(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddTaskDialog(),
            );
          },
          backgroundColor: Colors.blueGrey,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTaskListForToday() {
    return StreamBuilder<List<Task>>(
      stream: _firestoreService.getTasksForUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading tasks'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks for today'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final task = snapshot.data![index];
            return _buildTaskCard(task);
          },
        );
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white, // White card background
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        shadowColor: Colors.blueGrey.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task title and checkbox
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.taskName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Checkbox(
                    value: task.isCompleted,
                    activeColor: Colors.teal, // More vibrant checkbox
                    onChanged: (newValue) {
                      _firestoreService.updateTaskCompletion(
                          task.id, newValue!);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Task date and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d, hh:mm a').format(task.dueDate),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: task.isCompleted
                        ? const Text("Completed",
                            style: TextStyle(
                              color: Colors.teal, // Completed task in teal
                              fontWeight: FontWeight.bold,
                            ))
                        : Text("Pending",
                            style: TextStyle(
                              color: Colors.deepOrangeAccent[
                                  400], // Pending in vibrant orange
                              fontWeight: FontWeight.bold,
                            )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpenTaskList() {
    return StreamBuilder<List<Task>>(
      stream: _firestoreService.getTasksForUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading tasks'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final openTasks =
            snapshot.data?.where((task) => !task.isCompleted).toList() ?? [];

        return _buildTaskListView(openTasks);
      },
    );
  }

  Widget _buildClosedTaskList() {
    return StreamBuilder<List<Task>>(
      stream: _firestoreService.getTasksForUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading tasks'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final closedTasks =
            snapshot.data?.where((task) => task.isCompleted).toList() ?? [];

        return _buildTaskListView(closedTasks);
      },
    );
  }

  Widget _buildTaskForToday() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return StreamBuilder<List<Task>>(
      stream: _firestoreService.getTasksForUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading tasks'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No tasks for today'));
        }

        final tasks = snapshot.data!.where((task) {
          return task.dueDate.isAfter(todayStart) &&
              task.dueDate.isBefore(todayEnd);
        }).toList();

        return _buildTaskListView(tasks);
      },
    );
  }

  Widget _buildTaskListView(List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }
}
