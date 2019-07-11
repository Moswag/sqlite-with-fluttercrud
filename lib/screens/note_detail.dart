import 'package:flutter/material.dart';
import 'package:ininin/screens/note_detail.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ininin/models/note.dart';
import 'package:ininin/utils/database_helper.dart';
import 'dart:async';

class NoteDetail extends StatefulWidget{

  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NoteDetailState(this.note, this.appBarTitle);
  }



}

class NoteDetailState extends State<NoteDetail> {
  String appBarTitle;
  Note note;

  NoteDetailState(this.note, this.appBarTitle);

  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();


  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    TextStyle textStyle = Theme
        .of(context)
        .textTheme
        .title;

    titleController.text = note.title;
    descriptionController.text = note.description;


    return WillPopScope(

        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(icon: Icon(
                Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),

          body: Padding(
            padding: EdgeInsets.only(top: 15, left: 10, right: 10),
            child: ListView(
              children: <Widget>[
                //First element
                ListTile(
                  title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      style: textStyle,

                      value: getPriorityAsString(note.priority),
                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          debugPrint('User selected $valueSelectedByUser');
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      }
                  ),
                ),

                //Second Element
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: TextField(
                    controller: titleController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Title text Field');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        )

                    ),
                  ),
                ),

                //Third Element
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: TextField(
                    controller: descriptionController,
                    style: textStyle,
                    onChanged: (value) {
                      debugPrint('Something changed in Description text Field');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: textStyle,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        )

                    ),
                  ),
                ),
//Forth element
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                            color: Theme
                                .of(context)
                                .primaryColorDark,
                            textColor: Theme
                                .of(context)
                                .primaryColorLight,
                            child: Text(
                              'Save',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                debugPrint("Save clicked");
                                _save();
                              });
                            }
                        ),
                      ),

                      Container(width: 5.0,), //for adding space between buttons
                      Expanded(
                        child: RaisedButton(
                            color: Theme
                                .of(context)
                                .primaryColorDark,
                            textColor: Theme
                                .of(context)
                                .primaryColorLight,
                            child: Text(
                              'Delete',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                debugPrint("Delete button clicked");
                                _delete();
                              });
                            }
                        ),
                      )
                    ],
                  ),
                ),

              ],
            ),
          ),


        )
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }


  //Convert the String priority in the form of integer before saving it to database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }


  //Convert the String priority in the form of integer before saving it to database
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; //high
        break;
      case 2:
        priority = _priorities[1]; //low
        break;
    }
    return priority;
  }

  //update the title of the note object
  void updateTitle() {
    note.title = titleController.text;
  }

  //update the description of the note object
  void updateDescription() {
    note.description = descriptionController.text;
  }


  void _save() async {
    moveToLastScreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (note.id != null) { //update operation
      result = await helper.updateNote(note);
    }
    else { //insert co note do not exist
      result = await helper.insertNote(note);
    }

    if (result != 0) { //success
      _showAlertDialog('Status', 'Note Saved Successfully');
    }
    else { //failure
      _showAlertDialog('Status', 'Note Fail to be Saved');
    }
  }

  void _delete() async {
    moveToLastScreen();
    //case 1 Delete from the add page ie wrong
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    //case 2 Delete from the edit  ie possible
    else {
      int result = await helper.deleteNote(note.id);
      if (result != 0) {
        _showAlertDialog('Status', 'Note successfully deleted');
      }
      else {
        _showAlertDialog('Status', 'Error occured while deleting note');
      }
    }
  }


  void _showAlertDialog(String title, String messge) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(messge),
    );

    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
}