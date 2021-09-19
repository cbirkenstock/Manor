import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

// const tokensToRemove: string[] = [];
// const emails = context.params.specificChat.split(" + ", 2)
// Listing all tokens as an array.
// const tokens = Object.keys(tokensSnapshot.val());
// console.log(tokens);
// Send notifications to all tokens.
// console.log(response.results[0].error);


exports.updateBadgeCount = functions.database
    .ref("/ChatsByUser/{userEmail}/Chats/{specificChat}/readNotification")
    .onUpdate(async (change, context) => {
      const specificChat = context.params.specificChat;
      const userEmail = context.params.userEmail;

      const afterReadNotification = change.after.val();


      if (afterReadNotification === true) {
        const conversationBadgeCountPromise = admin.database()
            .ref(`/ChatsByUser/${userEmail}/Chats/${specificChat}/badgeCount`)
            .once("value");

        const userBadgeCountPromise = admin.database()
            .ref(`/users/${userEmail}/badgeCount`)
            .once("value");

        const results1 = await Promise
            .all([conversationBadgeCountPromise, userBadgeCountPromise]);

        const conversationBadgeCount = Number(results1[0].val());
        const userBadgeCount = Number(results1[1].val());
        console.log(conversationBadgeCount);
        console.log(userBadgeCount);
        console.log(userBadgeCount - conversationBadgeCount);

        const updateConversationBadgeCountPromise = admin.database()
            .ref(`/ChatsByUser/${userEmail}/Chats/${specificChat}`)
            .update({
              "badgeCount": "0",
            });

        const updateBadgeCountPromise = admin.database()
            .ref(`/users/${userEmail}`)
            .update({
              "badgeCount": String(userBadgeCount - conversationBadgeCount),
            });

        const updateReadNotificationPromise = admin.database()
            .ref(`/ChatsByUser/${userEmail}/Chats/${specificChat}`)
            .update({
              "readNotification": false,
            });

        return Promise.all([updateConversationBadgeCountPromise,
          updateBadgeCountPromise, updateReadNotificationPromise])
            .then((promises) => {
              console.log(promises);
            })
            .catch((error) => {
              console.log(error);
            });
      } else {
        return null;
      }
    });

exports.updateBadgeCountGroup = functions.database
    .ref("/GroupChatsByUser/{userEmail}/Chats/{specificChat}/readNotification")
    .onUpdate(async (change, context) => {
      console.log("FUNCTIONING");
      const chat = context.params.specificChat;
      const userEmail = context.params.userEmail;

      const afterReadNotification = change.after.val();


      if (afterReadNotification === true) {
        const conversationBadgeCountPromise = admin.database()
            .ref(`/GroupChatsByUser/${userEmail}/Chats/${chat}/badgeCount`)
            .once("value");

        const userBadgeCountPromise = admin.database()
            .ref(`/users/${userEmail}/badgeCount`)
            .once("value");

        const results1 = await Promise
            .all([conversationBadgeCountPromise, userBadgeCountPromise]);

        const conversationBadgeCount = Number(results1[0].val());
        const userBadgeCount = Number(results1[1].val());

        const updateConversationBadgeCountPromise = admin.database()
            .ref(`/GroupChatsByUser/${userEmail}/Chats/${chat}`)
            .update({
              "badgeCount": "0",
            });

        const updateBadgeCountPromise = admin.database()
            .ref(`/users/${userEmail}`)
            .update({
              "badgeCount": String(userBadgeCount - conversationBadgeCount),
            });

        const updateReadNotificationPromise = admin.database()
            .ref(`/GroupChatsByUser/${userEmail}/Chats/${chat}`)
            .update({
              "readNotification": false,
            });

        return Promise.all([updateConversationBadgeCountPromise,
          updateBadgeCountPromise, updateReadNotificationPromise])
            .then((promises) => {
              console.log(promises);
            })
            .catch((error) => {
              console.log(error);
            });
      } else {
        return null;
      }
    });

exports.sendRecipientNotification = functions.database
    .ref("/ChatsByUser/{userEmail}/Chats/{specificChat}/timeStamp")
    .onWrite(async (change, context) => {
      const specificChat = context.params.specificChat;
      const userEmail = String(context.params.userEmail);

      const userBadgeCountPromise = admin.database()
          .ref(`/users/${userEmail}/badgeCount`)
          .once("value");

      const conversationBadgeCountPromise = admin.database()
          .ref(`/ChatsByUser/${userEmail}/Chats/${specificChat}/badgeCount`)
          .once("value");

      const senderEmailPromise = admin.database()
          .ref(`/ChatsByUser/${userEmail}/Chats/${specificChat}/senderEmail`)
          .once("value");

      const result = await Promise
          .all([senderEmailPromise, userBadgeCountPromise,
            conversationBadgeCountPromise]);

      const senderEmail = String(result[0].val());
      const userBadgeCount = Number(result[1].val());
      const conversationBadgeCount = Number(result[2].val());

      if (userEmail !== senderEmail) {
        const tokensPromise = admin.database()
            .ref(`/users/${userEmail}/fcmToken`)
            .once("value");

        const titlePromise = admin.database()
            .ref(`/ChatsByUser/${userEmail}/Chats/${specificChat}/title`)
            .once("value");

        const bodyPromise = admin.database()
            .ref(`/ChatsByUser/${userEmail}/Chats/${specificChat}/lastMessage`)
            .once("value");

        const updateBadgeCountPromise = admin.database()
            .ref(`/users/${userEmail}`)
            .update({
              "badgeCount": String(userBadgeCount + 1),
            });

        const updateConversationBadgeCountPromise = admin.database()
            .ref(`/ChatsByUser/${userEmail}/Chats/${specificChat}`)
            .update({
              "badgeCount": String(conversationBadgeCount + 1),
            });

        const results1 = await Promise
            .all([tokensPromise, titlePromise, bodyPromise,
              updateBadgeCountPromise, updateConversationBadgeCountPromise]);

        const tokensSnapshot = results1[0];
        const titleSnapshot = results1[1];
        const bodySnapshot = results1[2];

        const newUserBadgeCountPromise = admin.database()
            .ref(`/users/${userEmail}/badgeCount`)
            .once("value");

        const results2 = await Promise
            .all([newUserBadgeCountPromise]);

        // return results2;

        const newBadgeCountSnapshot = results2[0];

        const payload = {
          notification: {
            title: titleSnapshot.val(),
            body: bodySnapshot.val(),
            badge: newBadgeCountSnapshot.val(),
          },
        };

        return admin.messaging()
            .sendToDevice(tokensSnapshot.val(), payload)
            .then(function(response) {
              console.log("Successfully sent message: ", response);
            })
            .catch(function(error) {
              console.log("Error sending message: ", error);
            });
      } else {
        return null;
      }
    });

exports.sendGroupMembersNotification = functions.database
    .ref("/GroupChatMessages/{Chat}/timeStamp")
    .onUpdate(async (change, context) => {
      // const body = change.after.val();
      const chat = context.params.Chat;

      const BodyPromise = admin.database()
          .ref(`/GroupChatMessages/${chat}/lastMessage`)
          .once("value");

      const membersPromise = admin.database()
          .ref(`/GroupChatMessages/${chat}/Members`)
          .once("value");

      const titlePromise = admin.database()
          .ref(`/GroupChatMessages/${chat}/title`)
          .once("value");

      const senderEmailPromise = admin.database()
          .ref(`/GroupChatMessages/${chat}/senderEmail`)
          .once("value");

      const result = await Promise
          .all([membersPromise, titlePromise, senderEmailPromise, BodyPromise]);
      const members = result[0].val();
      const title = result[1].val();
      const senderEmail = result[2].val();
      const body = result[3].val();

      for (let i = 0; i < members.length; i++) {
        const member = members[i];


        if (member[1] !== senderEmail) {
          const commaMember = String(member[1]).split(".").join(",");

          const userBadgeCountPromise = admin.database()
              .ref(`/users/${commaMember}/badgeCount`)
              .once("value");

          const conversationBadgeCountPromise = admin.database()
              .ref(`/GroupChatsByUser/${commaMember}/Chats/${chat}/badgeCount`)
              .once("value");

          const result = await Promise
              .all([userBadgeCountPromise, conversationBadgeCountPromise]);
          const userBadgeCount = Number(result[0].val());
          const conversationBadgeCount = Number(result[1].val());

          console.log("CONVERSATION BADGE COUNT");
          console.log(conversationBadgeCount);


          const userTokenPromise = admin.database()
              .ref(`/users/${commaMember}/fcmToken`)
              .once("value");

          const updateBCProm = admin.database()
              .ref(`/users/${commaMember}`)
              .update({
                "badgeCount": String(userBadgeCount + 1),
              });

          const updateConversationBCProm = admin.database()
              .ref(`/GroupChatsByUser/${commaMember}/Chats/${chat}`)
              .update({
                "badgeCount": String(conversationBadgeCount + 1),
              });

          const results = await Promise
              .all([userTokenPromise, updateBCProm, updateConversationBCProm]);
          const memberToken = results[0].val();


          const newUserBadgeCountPromise = admin.database()
              .ref(`/users/${commaMember}/badgeCount`)
              .once("value");

          const results2 = await Promise
              .all([newUserBadgeCountPromise]);
          const newBadgeCount = results2[0].val();

          const payload = {
            notification: {
              title: String(title),
              body: String(body),
              badge: newBadgeCount,
            },
          };

          admin.messaging()
              .sendToDevice(memberToken, payload)
              .then(function(response) {
                console.log("Successfully sent message: ", response);
              })
              .catch(function(error) {
                console.log("Error sending message: ", error);
              });
        }
      }
      return null;
    });

exports.sendEventGroupMembersNotification = functions.database
    .ref("/EventChatMessages/{Chat}/timeStamp")
    .onUpdate(async (change, context) => {
      // const body = change.after.val();
      const chat = context.params.Chat;

      const BodyPromise = admin.database()
          .ref(`/EventChatMessages/${chat}/lastMessage`)
          .once("value");

      const membersPromise = admin.database()
          .ref(`/EventChatMessages/${chat}/Members`)
          .once("value");

      const titlePromise = admin.database()
          .ref(`/EventChatMessages/${chat}/title`)
          .once("value");

      const senderEmailPromise = admin.database()
          .ref(`/EventChatMessages/${chat}/senderEmail`)
          .once("value");

      const result = await Promise
          .all([membersPromise, titlePromise, senderEmailPromise, BodyPromise]);
      const members = result[0].val();
      const title = result[1].val();
      const senderEmail = result[2].val();
      const body = result[3].val();

      for (let i = 0; i < members.length; i++) {
        const member = members[i];


        if (member[1] !== senderEmail) {
          const commaMember = String(member[1]).split(".").join(",");

          const userBadgeCountPromise = admin.database()
              .ref(`/users/${commaMember}/badgeCount`)
              .once("value");

          const conversationBadgeCountPromise = admin.database()
              .ref(`/EventChatsByUser/${commaMember}/Chats/${chat}/badgeCount`)
              .once("value");

          const result = await Promise
              .all([userBadgeCountPromise, conversationBadgeCountPromise]);
          const userBadgeCount = Number(result[0].val());
          const conversationBadgeCount = Number(result[1].val());

          console.log("CONVERSATION BADGE COUNT");
          console.log(conversationBadgeCount);


          const userTokenPromise = admin.database()
              .ref(`/users/${commaMember}/fcmToken`)
              .once("value");

          const updateBCProm = admin.database()
              .ref(`/users/${commaMember}`)
              .update({
                "badgeCount": String(userBadgeCount + 1),
              });

          const updateConversationBCProm = admin.database()
              .ref(`/EventChatsByUser/${commaMember}/Chats/${chat}`)
              .update({
                "badgeCount": String(conversationBadgeCount + 1),
              });

          const results = await Promise
              .all([userTokenPromise, updateBCProm, updateConversationBCProm]);
          const memberToken = results[0].val();


          const newUserBadgeCountPromise = admin.database()
              .ref(`/users/${commaMember}/badgeCount`)
              .once("value");

          const results2 = await Promise
              .all([newUserBadgeCountPromise]);
          const newBadgeCount = results2[0].val();

          const payload = {
            notification: {
              title: String(title),
              body: String(body),
              badge: newBadgeCount,
            },
          };

          admin.messaging()
              .sendToDevice(memberToken, payload)
              .then(function(response) {
                console.log("Successfully sent message: ", response);
              })
              .catch(function(error) {
                console.log("Error sending message: ", error);
              });
        }
      }
      return null;
    });

exports.updateBadgeCountEvent= functions.database
    .ref("/EventChatsByUser/{userEmail}/Chats/{specificChat}/readNotification")
    .onUpdate(async (change, context) => {
      console.log("FUNCTIONING");
      const chat = context.params.specificChat;
      const userEmail = context.params.userEmail;

      const afterReadNotification = change.after.val();


      if (afterReadNotification === true) {
        const conversationBadgeCountPromise = admin.database()
            .ref(`/EventChatsByUser/${userEmail}/Chats/${chat}/badgeCount`)
            .once("value");

        const userBadgeCountPromise = admin.database()
            .ref(`/users/${userEmail}/badgeCount`)
            .once("value");

        const results1 = await Promise
            .all([conversationBadgeCountPromise, userBadgeCountPromise]);

        const conversationBadgeCount = Number(results1[0].val());
        const userBadgeCount = Number(results1[1].val());

        const updateConversationBadgeCountPromise = admin.database()
            .ref(`/EventChatsByUser/${userEmail}/Chats/${chat}`)
            .update({
              "badgeCount": "0",
            });

        const updateBadgeCountPromise = admin.database()
            .ref(`/users/${userEmail}`)
            .update({
              "badgeCount": String(userBadgeCount - conversationBadgeCount),
            });

        const updateReadNotificationPromise = admin.database()
            .ref(`/EventChatsByUser/${userEmail}/Chats/${chat}`)
            .update({
              "readNotification": false,
            });

        return Promise.all([updateConversationBadgeCountPromise,
          updateBadgeCountPromise, updateReadNotificationPromise])
            .then((promises) => {
              console.log(promises);
            })
            .catch((error) => {
              console.log(error);
            });
      } else {
        return null;
      }
    });


