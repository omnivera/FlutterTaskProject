const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.scheduleNotification = functions.https.onRequest(async (req, res) => {
  const { title, body, taskDate, token } = req.body;

  const message = {
    notification: {
      title,
      body,
    },
    token,
  };

  const taskTime = new Date(taskDate).getTime();
  const currentTime = Date.now();
  const delay = taskTime - currentTime;

  if (delay > 0) {
    setTimeout(async () => {
      try {
        await admin.messaging().send(message);
        console.log('Bildirim gönderildi:', message);
      } catch (error) {
        console.error('Bildirim gönderilemedi:', error);
      }
    }, delay);
    res.status(200).send('Bildirim planlandı.');
  } else {
    res.status(400).send('Geçmiş bir tarih için bildirim planlanamaz.');
  }
});