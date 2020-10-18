import 'package:flutter/material.dart';
import '../Screens/PostScreenPage.dart';
import 'Post.dart';
import '../widgets/Progress.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile({this.post});

  displayPost(context){
    print(post.postId);
    Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreenPage(postId: post.postId,userId: post.ownerId,)));
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CachedNetworkImage(imageUrl: post.post_url,placeholder: (context, url) => circularProgress(),errorWidget: (context, url, error) => Icon(Icons.error),),
      onTap: (){
        print(post.description);
        displayPost(context);
      },
    );
  }
}
