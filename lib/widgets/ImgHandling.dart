import 'package:Bombelczyk/widgets/MyFutureBuilder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';

class ImgView
    extends CircularProgressIndicatorFutureBuilder<List<MemoryImage>> {
  ImgView(Future<List<MemoryImage>> future)
      : super(future, (data) {
          return PhotoViewGallery.builder(
              itemCount: data.length,
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: data[index],
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.contained * 4,
                );
              });
        });
}

class ImgHandling {
  static void showIMGs(BuildContext context, Future<List<MemoryImage>> future) {
    future.then((value) {
      print("showing ${value.length} images");
      print(value);
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(child: ImgView(future));
        });
  }
}
