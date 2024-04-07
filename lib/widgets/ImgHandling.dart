import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';

class ImgView extends FutureBuilder<List<MemoryImage>> {
  ImgView(Future<List<MemoryImage>> future)
      : super(
            future: future,
            builder: (context, snapshot) {
              Widget toReturn;
              //print(snapshot.hasData);
              // print(snapshot.data);
              if (snapshot.hasData) {
                //log(snapshot.data);
                toReturn = PhotoViewGallery.builder(
                    itemCount: snapshot.data!.length,
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: snapshot.data![index],
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.contained * 4,
                      );
                    });
              } else {
                toReturn = CircularProgressIndicator();
              }
              return toReturn;
            });
}

class ImgHandling {
  static void showIMGs(BuildContext context, Future<List<MemoryImage>> future) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(child: ImgView(future));
        });
  }
}
