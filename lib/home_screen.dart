import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool uploading = false;

  String? link;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("File Picker App"),),
      body: Center(
        child: uploading ? const CircularProgressIndicator() :
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(onPressed: () async{
                await pickAndUploadFile();
              }, child: const Text("Upload File")),
              link!=null ? Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Uploaded File Link: ", style: TextStyle(fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    TextButton(
                        onPressed: () async{
                          await Clipboard.setData( ClipboardData(text: link!));
                          Fluttertoast.showToast(msg: "Url Copied to Clipboard");
                        },
                        child: Text("${link!}\n\n(Tap here to Copy Link)")),
                  ],
                ),
              ) : SizedBox()

            ],
          ),
        ),
      ),
    );
  }

  pickAndUploadFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);

    if (result != null) {
      File file = File(result.files.single.path!, );

      setState((){
        uploading = true;
      });

      await uploadToFirebaseStorage(file);

      setState((){
        uploading = false;
      });

    } else {


      // User canceled the picker
    }
  }

  uploadToFirebaseStorage(File file) async{
    final storageRef = FirebaseStorage.instance.ref();
    final imagesRef = storageRef.child(DateTime.now().toString());
    try{
      await imagesRef.putFile(file);
      link = await imagesRef.getDownloadURL();
      print(link);
      Fluttertoast.showToast(msg: "File Uploaded to firebase.");

    }
    catch(e){
      print(e);
      Fluttertoast.showToast(msg: "Some Issue occurred. Try again later");
    }
  }
}