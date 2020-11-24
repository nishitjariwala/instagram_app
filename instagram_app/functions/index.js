
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();


//When new Notification comes like like or comment post or start following someone

exports.onCreateActivityFeedItem = functions.firestore
.document('/notifications/{userId}/feedItems/{activityFeedItem}')
.onCreate(async (snapshot, context) =>
{
    const userId = context.params.userId;
    const userRef = admin.firestore().doc(`user/${userId}`);
    const doc = await userRef.get();


    const androidNotificationToken = doc.data().androidNotificationToken;
    const createActivityFeedItem = snapshot.data();

    if(androidNotificationToken)
    {
        sendNotification(androidNotificationToken, createActivityFeedItem);
    }
    else
    {
        console.log("No token for user, can not send notification.")
    }

    function sendNotification(androidNotificationToken, feedItems)
    {
        let body;

        switch (feedItems.type)
        {
            case "comment":
                body = `${feedItems.username} replied: ${feedItems.commentData}`;
                break;

            case "like":
                body = `${feedItems.username} liked your post`;
                break;

            case "follow":
                body = `${feedItems.username} started following you`;
                break;

            default:
            break;
        }

        const message =
        {
            notification: { body },
            token: androidNotificationToken,
            data: { recipient: userId },
        };

        admin.messaging().send(message)
        .then(response =>
        {
            console.log("Successfully sent message", response);
        })
        .catch(error =>
        {
            console.log("Error sending message", error);
        })

    }
});


//Update Timeline if user Started following someone


exports.onCreateFollower = functions.firestore
  .document("/followers/{userId}/userFollower/{followerId}")
  .onCreate(async (snapshot, context) => {

    console.log("Follower Created", snapshot.id);

    const userId = context.params.userId;

    const followerId = context.params.followerId;

    const followedUserPostsRef = admin
      .firestore()
      .collection("posts")
      .doc(userId)
      .collection("usersPosts");

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts");

    const querySnapshot = await followedUserPostsRef.get();

    querySnapshot.forEach(doc => {
      if (doc.exists) {
        const postId = doc.id;
        const postData = doc.data();
        timelinePostsRef.doc(postId).set(postData);
      }
    });
  });



//Update Timeline if user unfollow someone

  exports.onDeleteFollower = functions.firestore
  .document("/followers/{userId}/userFollower/{followerId}")
  .onDelete(async (snapshot, context) => {

    console.log("Follower Deleted", snapshot.id);

    const userId = context.params.userId;

    const followerId = context.params.followerId;

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("ownerId", "==", userId);

    const querySnapshot = await timelinePostsRef.get();
    querySnapshot.forEach(doc => {
      if (doc.exists)
      {
        doc.ref.delete();
      }
    });
  });



//When User Add new Post Update Followers Timeline


exports.onCreatePost = functions.firestore
  .document("/posts/{userId}/usersPosts/{postId}")
  .onCreate(async (snapshot, context) => {

    const postCreated = snapshot.data();

    const userId = context.params.userId;

    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollower");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .set(postCreated);
    });
  });





exports.onUpdatePost = functions.firestore
  .document("/posts/{userId}/usersPosts/{postId}")
  .onUpdate(async (change, context) => {
    const postUpdated = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollower");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.update(postUpdated);
          }
        });
    });
  });



//When User Delete Post Update Timeline of follower

exports.onDeletePost = functions.firestore
  .document("/posts/{userId}/usersPosts/{postId}")
  .onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;

    const userFollowersRef = admin
      .firestore()
      .collection("followers")
      .doc(userId)
      .collection("userFollower");

    const querySnapshot = await userFollowersRef.get();

    querySnapshot.forEach(doc => {
      const followerId = doc.id;

      admin
        .firestore()
        .collection("timeline")
        .doc(followerId)
        .collection("timelinePosts")
        .doc(postId)
        .get()
        .then(doc => {
          if (doc.exists) {
            doc.ref.delete();
          }
        });
    });
  });
