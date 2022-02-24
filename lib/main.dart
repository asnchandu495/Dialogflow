import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'chatscreen/app_body.dart';
import 'customfunctionality/generate_chip.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SuMed PoC',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'SuMed'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [];


  @override
  void initState() {
    super.initState();
    DialogFlowtter.fromFile().then((instance) {
      dialogFlowtter = instance;
      _checkForMessage("Hello");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'DialogFlowtter app'),
      ),
      body: Column(
        children: [
          Expanded(
              child: Material(
            child: AppBody(
              messages: messages,
              onExtraMessage: (extraMessage) {
                // showBottomView(extraMessage);
                print('********************onExtraMessage********************');
                _handleAtachmentPressed(extraMessage);
              },
              onSelection: onSelected,
            ),
          )),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            color: Colors.cyan,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  onSelected(selectedValue) {
    // addMessage
    print('********************onSelected********************');
    // print("selected values = $selectedValue");
    try {
      _bottomSheetController?.close();
      _open = !_open;
    } on Exception catch (e) {
      // TODO
    }
    sendMessage(selectedValue);
  }

  void _handleAtachmentPressed(List<String> values) {

    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) async {
/*       showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: GestureDetector(
                onTap: () {
                  setState(() {
                  Navigator.pop(context);
                    
                    
                  });
                },
                child: SizedBox(height: 144, child: _formGroupOfChips(values))),
          );
        },
      );
  */

      showMaterialModalBottomSheet(
          context: context,
          builder: (context) => _formGroupOfChips(values),
          isDismissible: true);
/* 
   _bottomSheetController = showBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
        builder: (BuildContext context) {
          return GestureDetector(
              onTap: () => Navigator.of(context).pop(), // Closing the sheet.
              child: SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[_formGroupOfChips(values)],
                  ),
                ),
              ));
        },
      );
     */
    });
  }

  showBottomView(List<String> values) {
    // if (!_open) {

    _bottomSheetController = showBottomSheet<void>(
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.amber,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('BottomSheet'),
                ElevatedButton(
                    child: const Text('Close BottomSheet'),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            ),
          ),
        );
      },
      context: context,
    );
/*       showDialog(
          context: context,
          builder: (ctxt) => new AlertDialog(
                title: Text("Text Dialog"),
                content: _formGroupOfChips(values),
              )); */
    /*  _bottomSheetController = await _key.currentState?.showBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
        builder: (BuildContext context) {
          return GestureDetector(
              onTap: () => Navigator.of(context).pop(), // Closing the sheet.
              child: SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[_formGroupOfChips(values)],
                  ),
                ),
              ));
        },
      ); */
    /*  } else {
        _bottomSheetController.close();
      } */
    // setState(() => _open = !_open);
  }

  _formGroupOfChips(List<String> values) {
    return Wrap(
        spacing: 6.0,
        runSpacing: 6.0,
        children: values.map((value) {
          return buildChip(value, true, (selectedValue) {
            onSelected(selectedValue);
            // Navigator.pop(context);
          });
        }).toList());
  }

  PersistentBottomSheetController? _bottomSheetController = null;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _open = false;

  void sendMessage(String text) async {
    if (text.isEmpty) return;
    setState(() {
      addMessage(
        Message(text: DialogText(text: [text])),
        true,
      );
    });

    // dialogFlowtter.projectId = "deimos-apps-0905";

    _checkForMessage(text);
  }

  void addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage,
    });
  }

  @override
  void dispose() {
    dialogFlowtter.dispose();
    super.dispose();
  }

  Future<void> _checkForMessage(text) async {
    DetectIntentResponse response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: text)),
    );

    if (response.message == null) return;
    setState(() {
      addMessage(response.message!);
    });
  }
}
