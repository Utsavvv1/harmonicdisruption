import 'package:flutter/material.dart';

class EditListScreen extends StatefulWidget {
  final String title;
  final List<String> initialList;
  final void Function(List<String>) onSave;

  const EditListScreen({
    super.key,
    required this.title,
    required this.initialList,
    required this.onSave,
  });

  @override
  State<EditListScreen> createState() => _EditListScreenState();
}

class _EditListScreenState extends State<EditListScreen> {
  late List<String> appList;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    appList = List.from(widget.initialList);
  }

  void addApp() {
    final app = controller.text.trim();
    if (app.isNotEmpty &&
        app.toLowerCase().endsWith('.exe') &&
        !appList.contains(app)) {
      setState(() {
        appList.add(app);
        controller.clear();
      });
    }
  }

  void removeSelected(int index) {
    setState(() {
      appList.removeAt(index);
    });
  }

  void saveList() {
    widget.onSave(appList);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontFamily: 'Montserrat', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF362DB7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A171A), Color(0xFF201E40)],
            stops: [0.75, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: appList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      appList[index],
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeSelected(index),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'AppName.exe',
                        hintStyle: const TextStyle(
                          color: Colors.white54,
                          fontFamily: 'Montserrat',
                        ),
                        filled: true,
                        fillColor: const Color(0xFF353434),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFF6C64E9),
                            width: 0.7,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFF362DB7)),
                    onPressed: addApp,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: saveList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF362DB7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(49),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.26),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
