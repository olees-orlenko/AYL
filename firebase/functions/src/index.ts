import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions";
import { getStorage } from "firebase-admin/storage";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getAuth } from "firebase-admin/auth";

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

const TOPIC_ALL_USERS = "news_all";

const MOSCOW_OFFSET_MS = 3 * 60 * 60 * 1000;

function truncate(text: string, maxLength: number): string {
  const trimmed = text.trim();
  return trimmed.length > maxLength ? `${trimmed.slice(0, maxLength - 1)}…` : trimmed;
}

export const onNewsCreated = onDocumentCreated("News/{newsId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    return;
  }
  const news = snapshot.data();

  if (!news?.isEvent) {
    return;
  }

  const title = `Новое мероприятие: ${news.title ?? ""}`;
  const body = news.content
    ? truncate(String(news.content), 140)
    : "Загляните в приложение, чтобы узнать подробности.";

  try {
    await messaging.send({
      topic: TOPIC_ALL_USERS,
      notification: { title, body },
      data: {
        newsId: event.params.newsId,
        type: "new_event",
      },
      apns: {
        payload: { aps: { sound: "default" } },
      },
    });
    logger.info(`onNewsCreated: push о новом мероприятии ${event.params.newsId} отправлен`);
  } catch (error) {
    logger.error(`onNewsCreated: ошибка отправки push для ${event.params.newsId}`, error);
  }
});

export const sendEventReminders = onSchedule(
  { schedule: "0 9 * * *", timeZone: "Europe/Moscow" },
  async () => {
    const nowMoscow = new Date(Date.now() + MOSCOW_OFFSET_MS);
    const startOfTomorrowMoscow = Date.UTC(
      nowMoscow.getUTCFullYear(),
      nowMoscow.getUTCMonth(),
      nowMoscow.getUTCDate() + 1,
      0, 0, 0
    );
    const endOfTomorrowMoscow = startOfTomorrowMoscow + 24 * 60 * 60 * 1000;

    const startUTC = new Date(startOfTomorrowMoscow - MOSCOW_OFFSET_MS);
    const endUTC = new Date(endOfTomorrowMoscow - MOSCOW_OFFSET_MS);

    const snapshot = await db
      .collection("News")
      .where("isEvent", "==", true)
      .where("eventDate", ">=", Timestamp.fromDate(startUTC))
      .where("eventDate", "<", Timestamp.fromDate(endUTC))
      .get();

    if (snapshot.empty) {
      logger.info("sendEventReminders: на завтра мероприятий нет");
      return;
    }

    for (const doc of snapshot.docs) {
      const news = doc.data();

      if (news.reminderSent === true) {
        continue;
      }

      try {
        await messaging.send({
          topic: TOPIC_ALL_USERS,
          notification: {
            title: `Завтра: ${news.title ?? "мероприятие"}`,
            body: "Не забудьте — мероприятие уже завтра. Подробности в приложении.",
          },
          data: {
            newsId: doc.id,
            type: "event_reminder",
          },
          apns: {
            payload: { aps: { sound: "default" } },
          },
        });
        await doc.ref.update({ reminderSent: true });
        logger.info(`sendEventReminders: напоминание по ${doc.id} отправлено`);
      } catch (error) {
        logger.error(`sendEventReminders: ошибка отправки напоминания для ${doc.id}`, error);
      }
    }
  }
);

export const convertPastEventSignups = onSchedule(
  { schedule: "0 3 * * *", timeZone: "Europe/Moscow" },
  async () => {
    const snapshot = await db
      .collectionGroup("eventSignups")
      .where("eventDate", "<", Timestamp.now())
      .get();

    if (snapshot.empty) {
      logger.info("convertPastEventSignups: прошедших записей нет");
      return;
    }

    for (const doc of snapshot.docs) {
      const signup = doc.data();
      const participantRef = doc.ref.parent.parent;
      if (!participantRef) {
        continue;
      }
      try {
        await participantRef.collection("participations").add({
          eventTitle: signup.eventTitle,
          eventDate: signup.eventDate,
          role: signup.role,
          newsId: signup.newsId ?? null,
          createdAt: Timestamp.now(),
        });
        await doc.ref.delete();
        logger.info(`convertPastEventSignups: запись ${doc.id} участника ${participantRef.id} перенесена в участие`);
      } catch (error) {
        logger.error(`convertPastEventSignups: ошибка переноса ${doc.id} участника ${participantRef.id}`, error);
      }
    }
  }
);

export const deleteMyAccountData = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Нужно быть авторизованным");
  }
  const uid = request.auth.uid;

  await db.recursiveDelete(db.collection("participants").doc(uid));
  await db.collection("PublicProfiles").doc(uid).delete().catch(() => undefined);

  try {
    const contactSnapshots = await Promise.all([
      db.collection("ContactRequests").where("fromUid", "==", uid).get(),
      db.collection("ContactRequests").where("toUid", "==", uid).get(),
    ]);
    const contactBatch = db.batch();
    for (const snapshot of contactSnapshots) {
      snapshot.docs.forEach((doc) => contactBatch.delete(doc.ref));
    }
    await contactBatch.commit();
  } catch (error) {
    logger.error(`deleteMyAccountData: не удалось удалить ContactRequests для ${uid}`, error);
  }

  try {
    const certificateSnapshot = await db
      .collection("CertificateRequests")
      .where("participantUid", "==", uid)
      .get();
    const certificateBatch = db.batch();
    certificateSnapshot.docs.forEach((doc) => certificateBatch.delete(doc.ref));
    await certificateBatch.commit();
  } catch (error) {
    logger.error(`deleteMyAccountData: не удалось удалить CertificateRequests для ${uid}`, error);
  }

  try {
    const commentsSnapshot = await db
      .collectionGroup("comments")
      .where("authorUid", "==", uid)
      .get();
    const commentsBatch = db.batch();
    commentsSnapshot.docs.forEach((doc) => commentsBatch.delete(doc.ref));
    await commentsBatch.commit();
  } catch (error) {
    logger.error(`deleteMyAccountData: не удалось удалить комментарии для ${uid}`, error);
  }

  try {
    const deviceTokenSnapshot = await db
      .collection("deviceTokens")
      .where("userId", "==", uid)
      .get();
    const deviceTokenBatch = db.batch();
    deviceTokenSnapshot.docs.forEach((doc) => deviceTokenBatch.delete(doc.ref));
    await deviceTokenBatch.commit();
  } catch (error) {
    logger.error(`deleteMyAccountData: не удалось удалить deviceTokens для ${uid}`, error);
  }

  await getStorage().bucket().file(`participant_photos/${uid}.jpg`).delete().catch(() => undefined);

  await getAuth().deleteUser(uid);

  logger.info(`deleteMyAccountData: аккаунт и данные участника ${uid} удалены`);
  return { success: true };
});

export const banParticipant = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Нужно быть авторизованным");
  }
  const adminDoc = await db.collection("admins").doc(request.auth.uid).get();
  if (!adminDoc.exists) {
    throw new HttpsError("permission-denied", "Только администратор может блокировать пользователей");
  }
  const targetUid = request.data?.uid;
  if (!targetUid || typeof targetUid !== "string") {
    throw new HttpsError("invalid-argument", "Не передан uid пользователя");
  }

  await getAuth().updateUser(targetUid, { disabled: true });
  await db.collection("participants").doc(targetUid).set(
    { isBanned: true, bannedBy: request.auth.uid },
    { merge: true }
  );

  logger.info(`banParticipant: пользователь ${targetUid} заблокирован администратором ${request.auth.uid}`);
  return { success: true };
});

export const unbanParticipant = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Нужно быть авторизованным");
  }
  const adminDoc = await db.collection("admins").doc(request.auth.uid).get();
  if (!adminDoc.exists) {
    throw new HttpsError("permission-denied", "Только администратор может разблокировать пользователей");
  }
  const targetUid = request.data?.uid;
  if (!targetUid || typeof targetUid !== "string") {
    throw new HttpsError("invalid-argument", "Не передан uid пользователя");
  }

  await getAuth().updateUser(targetUid, { disabled: false });
  await db.collection("participants").doc(targetUid).set(
    { isBanned: false, bannedBy: FieldValue.delete() },
    { merge: true }
  );

  logger.info(`unbanParticipant: пользователь ${targetUid} разблокирован администратором ${request.auth.uid}`);
  return { success: true };
});