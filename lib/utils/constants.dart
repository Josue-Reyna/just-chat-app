import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

const preloader = Center(
  child: CircularProgressIndicator(),
);

final key = dotenv.env['KEY']!;

const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

const unexpectedErrorMessage = 'Unexpected error occured.';

extension ShowSnackBar on BuildContext {
  void showSnackBar({
    required String message,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.redAccent,
    );
  }
}

void showSomeDialog(
  BuildContext context,
  String msg,
  List<Widget> actions,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        actionsPadding: const EdgeInsets.only(
          bottom: 30,
        ),
        actionsAlignment: MainAxisAlignment.center,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        alignment: Alignment.center,
        title: msg != ''
            ? Text(
                msg,
                textAlign: TextAlign.center,
              )
            : null,
        content: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: actions,
        )),
        //actions: actions,
      );
    },
  );
}

void showSomeWrap(
  BuildContext context,
  String msg,
  List<Widget> wrapper,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 20,
        ),
        actionsPadding: const EdgeInsets.only(
          bottom: 30,
        ),
        actionsAlignment: MainAxisAlignment.center,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        alignment: Alignment.center,
        title: Text(
          msg,
          textAlign: TextAlign.center,
        ),
        actions: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: wrapper,
          ),
        ],
      );
    },
  );
}

void showSomeButtons(
    BuildContext context,
    String msg,
    List<IconData?> icons,
    Color backgroundColor1,
    Color? backgroundColor2,
    List<void Function()?> functions,
    {Widget? others}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 20,
        ),
        actionsPadding: const EdgeInsets.only(
          bottom: 30,
        ),
        actionsAlignment: MainAxisAlignment.center,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        alignment: Alignment.center,
        title: Text(
          msg,
          textAlign: TextAlign.center,
        ),
        content: others,
        actions: [
          ElevatedButton(
            onPressed: functions[0],
            style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromRadius(20),
              shadowColor: Theme.of(context).primaryColorLight,
              elevation: 20,
              shape: const CircleBorder(),
              foregroundColor: Theme.of(context).primaryColorLight,
              backgroundColor: backgroundColor1,
            ),
            child: Icon(
              icons[0],
            ),
          ),
          if (icons[1] != null)
            ElevatedButton(
              onPressed: functions[1],
              style: ElevatedButton.styleFrom(
                fixedSize: const Size.fromRadius(20),
                shadowColor: Theme.of(context).primaryColorLight,
                elevation: 20,
                shape: const CircleBorder(),
                foregroundColor: Theme.of(context).primaryColorLight,
                backgroundColor: backgroundColor2 ?? backgroundColor1,
              ),
              child: Icon(
                icons[1],
              ),
            ),
        ],
      );
    },
  );
}

void showSomeColors(
    BuildContext context,
    String msg,
    List<IconData?> icons,
    Color backgroundColor1,
    Color? backgroundColor2,
    List<void Function()?> functions,
    {Widget? others}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 20,
        ),
        actionsPadding: const EdgeInsets.only(
          bottom: 30,
        ),
        actionsAlignment: MainAxisAlignment.center,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        alignment: Alignment.center,
        title: Text(
          msg,
          textAlign: TextAlign.center,
        ),
        content: others,
        actions: [
          ElevatedButton(
            onPressed: functions[0],
            style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromRadius(20),
              shadowColor: Theme.of(context).primaryColorLight,
              elevation: 20,
              shape: const CircleBorder(),
              foregroundColor: Theme.of(context).primaryColorLight,
              backgroundColor: backgroundColor1,
            ),
            child: Icon(
              icons[0],
            ),
          ),
          if (icons[1] != null)
            ElevatedButton(
              onPressed: functions[1],
              style: ElevatedButton.styleFrom(
                fixedSize: const Size.fromRadius(20),
                shadowColor: Theme.of(context).primaryColorLight,
                elevation: 20,
                shape: const CircleBorder(),
                foregroundColor: Theme.of(context).primaryColorLight,
                backgroundColor: backgroundColor2 ?? backgroundColor1,
              ),
              child: Icon(
                icons[1],
              ),
            ),
        ],
      );
    },
  );
}

Future<bool?> showPhotoOptions(BuildContext context) {
  return showDialog<bool?>(
    context: context,
    barrierDismissible: true,
    builder: (context) => SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromRadius(30),
              shadowColor: Theme.of(context).primaryColorLight,
              elevation: 20,
              shape: const CircleBorder(),
            ),
            child: const Icon(
              Icons.photo,
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromRadius(30),
              shadowColor: Theme.of(context).primaryColorLight,
              elevation: 20,
              shape: const CircleBorder(),
            ),
            child: const Icon(
              Icons.add_a_photo,
            ),
          ),
        ],
      ),
    ),
  );
}

const checkColor = Color.fromARGB(255, 79, 185, 141);

const themeColors = [
  Color.fromARGB(255, 86, 135, 219),
  Colors.redAccent,
  Color.fromARGB(255, 245, 211, 87),
  checkColor,
  Colors.orangeAccent,
  Colors.deepPurpleAccent,
  Colors.cyanAccent,
  Colors.pinkAccent,
];
const themeNameColors = [
  'Blue',
  'Red',
  'Yellow',
  'Green',
  'Orange',
  'Purple',
  'Cyan',
  'Pink'
];
const whiteOld = Color.fromARGB(255, 249, 255, 221);
const white = Color.fromARGB(255, 242, 243, 240);
const black = Color.fromARGB(255, 31, 30, 30);

// Heights
const height0 = SizedBox(height: 5);
const height1 = SizedBox(height: 10);
const height2 = SizedBox(height: 20);
const height3 = SizedBox(height: 30);
const height4 = SizedBox(height: 40);
const height5 = SizedBox(height: 50);
const height6 = SizedBox(height: 60);
const height7 = SizedBox(height: 70);
const height8 = SizedBox(height: 80);
const height9 = SizedBox(height: 90);
const heightX = SizedBox(height: 100);

// Widths
const width1 = SizedBox(width: 10);
const width2 = SizedBox(width: 20);
const width3 = SizedBox(width: 30);
const width4 = SizedBox(width: 40);
const width5 = SizedBox(width: 50);
const width6 = SizedBox(width: 60);
const width7 = SizedBox(width: 70);
const width8 = SizedBox(width: 80);
const width9 = SizedBox(width: 90);
const widthX = SizedBox(width: 100);
