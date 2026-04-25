import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:japan_app/constants.dart';
import 'package:japan_app/models/place_model.dart';
import 'package:japan_app/services/foursquare_service.dart';
import 'package:japan_app/services/place_service.dart';

class EditPlaceScreen extends StatefulWidget {
  const EditPlaceScreen({
    super.key,
    this.place,
    this.tripId,
    this.lat,
    this.lng,
    this.foursquarePlace,
  });

  final PlaceModel? place;
  final String? tripId;
  final double? lat;
  final double? lng;
  final FoursquarePlace? foursquarePlace;

  @override
  State<EditPlaceScreen> createState() => _EditPlaceScreenState();
}

class _EditPlaceScreenState extends State<EditPlaceScreen> {
  late TextEditingController name;
  late TextEditingController description;
  late List<String> tags;
  late List<String>? imageUrls;
  final ImagePicker _picker = ImagePicker();
  final List<String> _deletedUrls = [];

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
              ElevatedButton(
                onPressed: () async {
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() {
                      imageUrls?.add(image.path);
                    });
                  }
                },
                child: Text('Add Images'),
              ),
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
                      imageUrls![index].startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: imageUrls![index],
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey.shade200),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.broken_image),
                            )
                          : Image.file(File(imageUrls![index])),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(Icons.close),
                          onPressed:() {
                              setState(() {
                                if(imageUrls![index].startsWith('http'))
                                {
                                  _deletedUrls.add(imageUrls![index]);

                                  imageUrls!.removeAt(index);
                                }
                              });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              Padding(padding: EdgeInsets.all(20.0)),
              ElevatedButton(
                onPressed: () async {
                  List<String> urls = [];
                  if (widget.place != null) {
                    for (final element in imageUrls!) {
                      if (element.startsWith('http')) {
                        urls.add(element);
                      } else {
                        final timestamp = DateTime.now().millisecondsSinceEpoch;
                        final ref = FirebaseStorage.instance.ref().child(
                          'places/${widget.place!.tripId}/${widget.place!.id}/$timestamp.jpg',
                        );
                        await ref.putFile(File(element));
                        final url = await ref.getDownloadURL();
                        urls.add(url);
                      }
                    }
                    for(final e in _deletedUrls)
                    {
                      await FirebaseStorage.instance.refFromURL(e).delete();
                    }
                    PlaceService().updatePlace(
                      PlaceModel(
                        id: widget.place!.id,
                        tripId: widget.place!.tripId,
                        creatorId: widget.place!.creatorId,
                        lat: widget.place!.lat,
                        lng: widget.place!.lng,
                        name: name.text,
                        description: description.text,
                        tags: tags,
                        imageUrls: urls,
                        fsqPlaceId: widget.place!.fsqPlaceId ?? '',
                      ),
                    );
                  } else {
                    PlaceService().addPlace(
                      PlaceModel(
                        id: '',
                        tripId: widget.tripId!,
                        creatorId: FirebaseAuth.instance.currentUser!.uid,
                        lat: widget.lat!,
                        lng: widget.lng!,
                        name: name.text,
                        description: description.text,
                        tags: tags,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
