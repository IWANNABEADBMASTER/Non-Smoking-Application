const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./hooha-app-firebase-adminsdk-wlayu-c51b35ae47.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://hooha-app-default-rtdb.asia-southeast1.firebasedatabase.app",
});

exports.createCustomToken = functions.https.onRequest(async (request, response) => {
  const user = request.body;
  const uid = `kakao:${user.uid}`;
  const updateParams = {
    email: user.email,
    photoURL: user.photoURL,
    displayName: user.displayName,
  };

  try {
    await admin.auth().updateUser(uid, updateParams);
  } catch (e) {
    updateParams.uid = uid;
    await admin.auth().createUser(updateParams);
  }

  const token = await admin.auth().createCustomToken(uid);

  response.send(token);
});
