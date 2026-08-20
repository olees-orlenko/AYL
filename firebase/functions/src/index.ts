/**
 * Cloud Functions для push-уведомлений приложения AYL.
 *
 * Две функции:
 *  1. onNewsCreated — срабатывает сразу при создании документа в коллекции "News".
 *     Если это мероприятие (isEvent === true), шлёт push всем подписчикам топика "news_all".
 *  2. sendEventReminders — расписание (каждый день в 09:00 по Москве). Находит мероприятия,
 *     которые пройдут завтра, и шлёт напоминание — один раз на мероприятие (флаг reminderSent).
 *
 * Деплой: см. README.md рядом с этой папкой.
 */

import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { logger } from "firebase-functions";

initializeApp();
const db = getFirestore();
const messaging = getMessaging();

/** Топик, на который подписывается каждое устройство при запуске приложения (см. PushNotificationManager.swift). */
const TOPIC_ALL_USERS = "news_all";

/** Москва — фиксированный UTC+3 (без перехода на летнее время с 2014 года). */
const MOSCOW_OFFSET_MS = 3 * 60 * 60 * 1000;

function truncate(text: string, maxLength: number): string {
  const trimmed = text.trim();
  return trimmed.length > maxLength ? `${trimmed.slice(0, maxLength - 1)}…` : trimmed;
}

// ──────────────────────────────────────────────────────────────────────────
// 1. Push сразу при публикации нового мероприятия/конференции/тренинга
// ──────────────────────────────────────────────────────────────────────────

export const onNewsCreated = onDocumentCreated("News/{newsId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) {
    return;
  }
  const news = snapshot.data();

  // Обычные новости пуш не получают — только анонсы мероприятий.
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

// ──────────────────────────────────────────────────────────────────────────
// 2. Ежедневное напоминание за день до мероприятия
// ──────────────────────────────────────────────────────────────────────────

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

    // eventDate хранится как обычный UTC Timestamp — переводим границы "завтра по Москве" в UTC.
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

      // Не слать повторно, если функция уже отправила напоминание по этому документу.
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
