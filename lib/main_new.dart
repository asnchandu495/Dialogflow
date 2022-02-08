import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sumed/chatscreen/chat_room.dart';
import 'package:sumed/models/user_model.dart';

import 'app_theme.dart';
import 'chat_room.dart';

/**
 *  Date add in conversation

|

Send button need to complete

|

Bottomsheet with chips
 * 
 */

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SuMed PoC',
      theme: ThemeData(
        // primaryColor: MyTheme.kPrimaryColor,
        // accentColor: MyTheme.kAccentColor,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        primarySwatch: MyTheme.createMaterialColor(MyTheme.kPrimaryColorVariant),
        visualDensity: VisualDensity.standard,
      ),
      home: ChatRoom(user: botSuMed),
    );
  }
}
