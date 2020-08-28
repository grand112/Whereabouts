const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.myFunction = functions.firestore
  .document('chats/{chatIdDocument}/{chatIdCollection}/{message}')
  .onCreate(async snapshot => {

    const message = snapshot.data();

    const querySnapshot = await admin.firestore()
      .collection('users')
      .doc(message.sentTo)
      .collection('tokens')
      .get();

    const tokens = querySnapshot.docs.map(snap => snap.id);

    return admin.messaging().sendToDevice(tokens, {
      notification: {
        title: `${message.sentByUsername} sent you a message!`,
        body: message.text,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      }
    });
  });


exports.myFunctionCircle = functions.firestore
  .document('in_circle/{data}')
  .onCreate(async snapshot => {

    const in_circle = snapshot.data();

    const querySnapshot = await admin.firestore()
      .collection('users')
      .doc(in_circle.circleCreatedBy)
      .collection('tokens')
      .get();

    const tokens = querySnapshot.docs.map(snap => snap.id);

    return admin.messaging().sendToDevice(tokens, {
      notification: {
        title: snapshot.data().nameOfCircle,
        body: `${snapshot.data().enteredByUser} just entered ${snapshot.data().nameOfCircle}`,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      }
    });
  });

exports.myFunctionOutOfCircle = functions.firestore
  .document('out_of_circle/{data}')
  .onCreate(async snapshot => {

    const out_of_circle = snapshot.data();

    const querySnapshot = await admin.firestore()
      .collection('users')
      .doc(out_of_circle.circleCreatedBy)
      .collection('tokens')
      .get();

    const tokens = querySnapshot.docs.map(snap => snap.id);

    return admin.messaging().sendToDevice(tokens, {
      notification: {
        title: snapshot.data().nameOfCircle,
        body: `${snapshot.data().leftByUser} just left ${snapshot.data().nameOfCircle}`,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      }
    });
  });

exports.myFunctionFriendInvite = functions.firestore
  .document('users/{id}/friends/{invite}')
  .onCreate(async snapshot => {

    const invite = snapshot.data();

    const querySnapshot = await admin.firestore()
      .collection('users')
      .doc(invite.sentTo)
      .collection('tokens')
      .get();

    const tokens = querySnapshot.docs.map(snap => snap.id);

    return admin.messaging().sendToDevice(tokens, {
      notification: {
        title: `You have a new friend invite!`,
        body: `${snapshot.data().sentBy_username} invited you to friends`,
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      }
    });
  }); 