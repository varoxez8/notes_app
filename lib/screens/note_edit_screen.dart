import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutternotes/helper/note_provider.dart';
import 'package:flutternotes/models/note.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutternotes/utils/constants.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'note_view_screen.dart';

class NoteEditScreen extends StatefulWidget {
  static const route = '/edit-note';
  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  File _image, localFile;
  final picker = ImagePicker();
  bool firstTime = true;
  Note selectedNote;
  int id;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (firstTime) {
      id = ModalRoute
          .of(this.context)
          .settings
          .arguments;

      if (id != null) {
        selectedNote =
            Provider.of<NoteProvider>(this.context, listen: false).getNote(id);

        titleController.text = selectedNote?.title;
        contentController.text = selectedNote?.content;

        if (selectedNote?.imagePath != null) {
          _image = File(selectedNote.imagePath);
        }
      }

      firstTime = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.7,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){   Navigator.popUntil(context, ModalRoute.withName('/'));

          },
          icon: Icon(Icons.arrow_back_ios),
          color: headerColor,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_camera),
            color: Colors.black,
            onPressed: () {
              getImage(ImageSource.camera);
            },
          ),
          IconButton(
            icon: Icon(Icons.insert_photo),
            color: Colors.black,
            onPressed: () {
              getImage(ImageSource.gallery);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.black,
            onPressed: () {

              Provider.of<NoteProvider>(context,listen:false).deleteNote(id);
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(
                left: 10.0, right: 5.0, top: 10.0, bottom: 5.0
            ),
              child: TextField(
                controller: titleController,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: createTitle,
                decoration: InputDecoration(
                    hintText: 'Enter Note Title', border: InputBorder.none
                ),

              ),

            ),

            if(_image != null)
              Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 250.0,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: FileImage(_image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Container(
                          height: 30.0,
                          width: 30.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle
                            , color: Colors.white,
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _image = null;
                              });
                            },
                            child: Icon(
                              Icons.delete,
                              size: 16.0,

                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            Padding(padding: const EdgeInsets.only(
                left: 10.0, right: 5.0, top: 10.0, bottom: 5.0
            ),
              child: TextField(
                controller: contentController,
                maxLines: null,
                style: createContent,
                decoration: InputDecoration(
                  hintText: 'Enter something ...',
                  border: InputBorder.none,
                ),
              ),

            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (titleController.text.isEmpty)
            titleController.text = 'untitled Note';
          saveNote();
        },
        child: Icon(Icons.save,color:Colors.white70,),
        backgroundColor: Colors.lightGreen,),
    );
  }

  void getImage(ImageSource imageSource) async {
    PickedFile imageFile = await picker.getImage(source: imageSource);
    if (imageFile == null) return;
    File tmpFile = File(imageFile.path);
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = basename(imageFile.path);
    localFile = await tmpFile.copy('${appDir.path}/$fileName');
    setState(() {
      _image = localFile;
    });
  }

  void saveNote() {
    String title = titleController.text.trim();
    String content = contentController.text.trim();
    String imagePath = _image != null ? _image.path : null;

    if (id != null) {
      Provider.of<NoteProvider>(this.context, listen: false)
          .addOrUpdateNote(id, title, content, imagePath, EditMode.UPDATE);
      Navigator.of(this.context).pop();
    } else {
      int id = DateTime
          .now()
          .millisecondsSinceEpoch;
      Provider.of<NoteProvider>(this.context, listen: false)
          .addOrUpdateNote(id, title, content, imagePath, EditMode.ADD);
      Navigator.of(this.context)
          .pushReplacementNamed(NoteViewScreen.route, arguments: id);
    }
    @override
    void dispose() {
      titleController.dispose();
      contentController.dispose();
      super.dispose();
    }
  }
}