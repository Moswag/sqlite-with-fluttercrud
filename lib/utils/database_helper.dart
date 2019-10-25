import 'package:ininin/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';



class DatabaseHelper{

  static DatabaseHelper _databaseHelper;  //Singleton DatabaseHelper
  static Database _database;              //Singleton Database

  //database table
  String noteTable='note_table';
  String colId='id';
  String colTitle='title';
  String colDescription='description';
  String colPriority='priority';
  String colDate='date';



  DatabaseHelper._createInstance(); //named constructor to create instance of DatabaseHelper


 factory DatabaseHelper(){
   if(_databaseHelper==null){
     _databaseHelper=DatabaseHelper._createInstance();
   }

   return _databaseHelper;
 }

 Future<Database> get database async{
   if(_database==null){
     _database=await initialiseDatabase();
   }
   return _database;
 }

 Future<Database> initialiseDatabase() async{
   //Get the directory for both Android and iOS to store database.
   Directory directory=await getApplicationDocumentsDirectory();
   String path=directory.path+'notes.db';

   //Open/create the database at a given path
  var notesDatabase=await  openDatabase(path,version: 1,onCreate:_createDb);
  return notesDatabase;
   
 }


 void _createDb(Database db, int newVersion) async{
   await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
 }

 //Fetch Operation: Get all note objects from database
 Future<List<Map<String, dynamic>>> getNoteMapList() async{
   Database db=await this.database;

   var result=await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
   return result;
}

//Insert
 Future<int> insertNote(Note note) async{
   Database db=await this.database;
   var result=await db.insert(noteTable, note.toMap());
   return result;


 }

//update
  Future<int> updateNote(Note note) async{
    Database db=await this.database;
    var result=await db.update(noteTable, note.toMap(), where: '$colId =?', whereArgs: [note.id]);
    return result;
  }

//delete
  Future<int> deleteNote(int id) async{
    Database db=await this.database;
    int result=await db.rawDelete('DELETE FROM $noteTable WHERE $colId=$id');
    return result;
  }

//get number of Note objects in database
 Future<int> getCount() async{
   Database db=await this.database;
   List<Map<String, dynamic>> x=await db.rawQuery('SELECT COUNT (*) from $noteTable');
   int result=Sqflite.firstIntValue(x);
   return result;
 }

 //get the Map list [List<Map> and convert it to  Note List [ List<Note>]
Future<List<Note>> getNoteList() async{

   var noteMapList=await getNoteMapList(); //get 'Map List' from database
  int count=noteMapList.length;

  List<Note> noteList=List<Note>();

  for(int i=0; i<count; i++){
    noteList.add(Note.fromMapObject(noteMapList[i]));
  }

  return noteList;


}


}