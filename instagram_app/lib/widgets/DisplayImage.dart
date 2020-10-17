import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'Progress.dart';

DisplayImage(String url){
  return CachedNetworkImage(
    imageUrl: url,
    placeholder: (context, url)=>CircularProgressIndicator(),
  );
}