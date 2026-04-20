import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:japan_app/constants.dart';
import 'package:japan_app/models/place_model.dart';

class EditPlaceScreen extends StatefulWidget {
  const EditPlaceScreen({super.key, this.place});

  final PlaceModel? place;

  @override
  State<EditPlaceScreen> createState() => _EditPlaceScreenState();
}

class _EditPlaceScreenState extends State<EditPlaceScreen> {
  late TextEditingController name;
  late TextEditingController description;
  late List<String> tags;
  late List<String>? imageUrls;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    name = TextEditingController();
    description = TextEditingController();
    tags = [];
    imageUrls = [];
    

    if (widget.place != null) {
      name.text = widget.place!.name;
      description.text = widget.place!.description;
      tags = widget.place!.tags;
      imageUrls = widget.place?.imageUrls ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Name'),
              TextField(controller: name),
              Padding(padding: EdgeInsets.all(5.0)),
              Text('Description'),
              TextField(controller: description),
              Padding(padding: EdgeInsets.all(5.0)),
              Wrap(
                children: [
                  ...predefinedTags.map(
                    (e) => Padding(
                      padding: EdgeInsets.all(5),
                      child: FilterChip(
                        label: Text(e),
                        selected: tags.contains(e),
                        onSelected: (bool value) {
                          if (tags.contains(e)) {
                            tags.remove(e);
                          } else {
                            tags.add(e);
                          }

                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(5.0)),
              ElevatedButton(onPressed: () async {
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                if(image != null)
                {
                  setState(() {
                    imageUrls?.add(image.path);
                  });
                }

              }, child: Text('Add Images')),
              GridView.builder(
                itemCount: imageUrls?.length ?? 0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Image.file(File(imageUrls![index])),// remplacé par Image plus tard
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () =>
                              setState(() => imageUrls!.removeAt(index)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
