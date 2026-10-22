const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

// Mirrors the channel ids created in lib/services/push_notification_service.dart
// — keep both lists in sync if a type is added/renamed.
const DEFAULT_CHANNEL_ID = "kilotap_default_channel";
const CHANNEL_BY_TYPE = {
  booking_confirmed: "kilotap_bookings",
  completed: "kilotap_bookings",
  booking_cancelled: "kilotap_bookings",
  new_booking: "kilotap_bookings",
  chat_message: "kilotap_chat",
  verification_approved: "kilotap_verification",
  verification_rejected: "kilotap_verification",
};

// Fires whenever the Flutter app (or another function below) writes a new
// doc to the notifications collection (Table 15, see
// firestore_service.dart's sendNotification()) and relays it as a real FCM
// push so it shows up even if the recipient's app is backgrounded or
// closed — in-app only shows while NotificationsScreen is open, which this
// closes the gap on.
exports.sendNotificationPush = onDocumentCreated(
    "notifications/{notificationId}",
    async (event) => {
      const data = event.data?.data();
      if (!data) return;

      const recipientId = data.Recipient_ID;
      if (!recipientId) return;

      const userDoc = await admin
          .firestore()
          .collection("UserAccount")
          .doc(recipientId)
          .get();
      const token = userDoc.data()?.Fcm_Token;
      if (!token) return;

      try {
        await admin.messaging().send({
          token,
          notification: {
            title: data.Title || "KiloTap",
            body: data.Message || "",
          },
          data: {
            type: data.Type || "",
            bookingId: data.Booking_ID || "",
            notificationId: event.params.notificationId,
          },
          android: {
            notification: {
              channelId: CHANNEL_BY_TYPE[data.Type] || DEFAULT_CHANNEL_ID,
            },
          },
        });
      } catch (err) {
        // Most common cause: a stale/revoked token (device uninstalled the
        // app or logged out elsewhere) — not worth failing the function for.
        logger.warn(`FCM send failed for ${recipientId}: ${err.message}`);
      }
    },
);

// Mirrors lib/core/constants/material_preferences.dart (categoryMap, and
// the 'Other' catch-all for custom items) — keep both in sync.
const OTHER_CATEGORY = "Other";
const CATEGORY_MAP = {
  "Metal": [
    "metal_pipe_1m", "metal_bolt", "metal_sheet_1sqm", "metal_rod_1m",
    "tire_car", "tire_truck", "cast_iron_bathtub", "copper",
    "motorcycle_block", "vehicle_part_big", "metal_can",
  ],
  "Plastic": [
    "plastic_bottle_1L", "plastic_bottle_500ml", "plastic_hdpe", "plastic_pet",
    "plastic_bottle",
  ],
  "Glass": ["glass_bottle_1L", "glass_bottle_330ml", "glass_bottle"],
  "Cardboard": [
    "cardboard_box_large", "cardboard_box_small", "cardboard", "paper",
  ],
  "Appliances": [
    "refrigerator_standard", "washing_machine", "freezer", "dishwasher",
    "window_aircon", "microwave_oven", "electric_cooker", "stove_range",
    "clothes_dryer", "vacuum_cleaner", "electric_fan", "splittype_aircon",
    "hair_dryer", "microwave",
  ],
  "E-Waste": [
    "crt_television", "desktop_computer", "laptop_computer", "printer",
    "lcd_screen", "mobile_phone", "hi_fi_system", "video_recorder_dvd",
    "electric_drill", "flatscreentv", "car_battery", "mouse",
    "keyboard", "battery", "electronic_battery", "electronic_waste",
  ],
};

function matchesPreference(scrapClasses, preferred) {
  if (!Array.isArray(preferred) || preferred.length === 0) return true;
  return scrapClasses.some((cls) =>
    cls === OTHER_CATEGORY ||
    preferred.includes(cls) ||
    preferred.some((cat) => (CATEGORY_MAP[cat] || []).includes(cls)));
}

// Mirrors vehicleCanHandle() in lib/services/routing_service.dart.
const VEHICLE_ORDER = ["Pushcart", "Tricycle", "Multicab", "Truck"];

function vehicleCanHandle(collectorVehicle, requiredVehicle) {
  const have = VEHICLE_ORDER.indexOf(collectorVehicle);
  const need = VEHICLE_ORDER.indexOf(requiredVehicle);
  if (have === -1 || need === -1) return true;
  return have >= need;
}

// ─── Dispatch: nearest five first, then remind and widen ────────────────
// Paper 2.3.2.3: only the nearest eligible collectors are alerted. A
// collector is eligible when Verified, online, their vehicle can handle the
// job and their material preferences match (the same filters Find Scrap
// applies). Ranking uses straight-line distance from the collector's last
// known location to the pickup pin; Google Maps gives the road ETA on the
// collector's phone once they open the request. Every eligible collector
// can still see the booking in Find Scrap — this only limits push alerts.
const WAVE_SIZE = 5;
const REMIND_AFTER_MIN = 5; // re-alert a wave once if nobody accepted
const WIDEN_EVERY_MIN = 10; // then alert the next five, every 10 minutes
const DISPATCH_WINDOW_MIN = 60; // stop alerting after an hour

function distanceKm(lat1, lon1, lat2, lon2) {
  const rad = (d) => (d * Math.PI) / 180;
  const dLat = rad(lat2 - lat1);
  const dLon = rad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(rad(lat1)) * Math.cos(rad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// Eligible collectors for a booking, nearest first. Collectors with no
// location on file go last.
async function rankedEligibleCollectors(booking, bookingId) {
  const db = admin.firestore();
  const [collectors, items] = await Promise.all([
    db.collectionGroup("ScrapCollector")
        .where("Verification_Status", "==", "Verified")
        .where("Online_Status", "==", true)
        .get(),
    db.collection("bookingItems").where("Booking_ID", "==", bookingId).get(),
  ]);
  const scrapClasses = items.docs.map((d) => d.data().ScrapClass || "");
  const pin = booking.PickupGPS;
  const ranked = [];
  collectors.forEach((doc) => {
    const uid = doc.ref.parent.parent.id;
    if (uid === booking.Seller_ID) return; // paranoia guard
    const c = doc.data();
    if (!vehicleCanHandle(c.Vehicle_Type, booking.VehicleRequirement)) return;
    if (!matchesPreference(scrapClasses, c.Preferred_Materials)) return;
    const lat = Number(c.Current_Latitude) || 0;
    const lon = Number(c.Current_Longitude) || 0;
    const located = pin && lat !== 0 && lon !== 0;
    ranked.push({
      uid,
      km: located ?
        distanceKm(lat, lon, pin.latitude, pin.longitude) : Infinity,
    });
  });
  ranked.sort((a, b) => a.km - b.km);
  return ranked;
}

// Writes one notifications doc per collector; each triggers
// sendNotificationPush above, so the alert also lands in the in-app bell.
async function alertCollectors(bookingId, booking, uids, reminder) {
  if (uids.length === 0) return;
  const batch = admin.firestore().batch();
  const notifCol = admin.firestore().collection("notifications");
  for (const uid of uids) {
    const ref = notifCol.doc();
    batch.set(ref, {
      Notification_ID: ref.id,
      Recipient_ID: uid,
      Booking_ID: bookingId,
      Title: reminder ?
        "Pickup still waiting" : "New pickup available",
      Message: reminder ?
        "A pickup near you has not been accepted yet." :
        (booking.VehicleRequirement ?
          `A new pickup needing a ${booking.VehicleRequirement} was posted.` :
          "A new pickup request was posted near you."),
      Type: "new_booking",
      IsRead: false,
      Timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  await batch.commit();
}

// First wave: the nearest five, as soon as the booking is created. The app
// writes the booking and its items in one batch, so the items exist here.
exports.fanOutNewBookingNotifications = onDocumentCreated(
    "bookings/{bookingId}",
    async (event) => {
      const booking = event.data?.data();
      if (!booking || booking.Status !== "Pending") return;
      const ranked =
        await rankedEligibleCollectors(booking, event.params.bookingId);
      await alertCollectors(event.params.bookingId, booking,
          ranked.slice(0, WAVE_SIZE).map((r) => r.uid), false);
    },
);

// Every minute, for bookings still Pending within the dispatch window:
// remind each alerted collector once, REMIND_AFTER_MIN after their first
// alert, and alert the next five nearest every WIDEN_EVERY_MIN. Who has
// been alerted is read from the notifications already sent, so bookings
// need no extra fields. Eligibility is re-checked each run.
exports.widenPendingBookingAlerts = onSchedule("every 1 minutes",
    async () => {
      const db = admin.firestore();
      const now = Date.now();
      const pending = await db.collection("bookings")
          .where("Status", "==", "Pending").get();
      for (const doc of pending.docs) {
        const booking = doc.data();
        const created = booking.Created_At?.toMillis?.();
        if (!created) continue;
        const ageMin = (now - created) / 60000;
        if (ageMin > DISPATCH_WINDOW_MIN) continue;

        const sent = await db.collection("notifications")
            .where("Booking_ID", "==", doc.id).get();
        const alerts = new Map(); // collector uid -> {count, first}
        sent.forEach((n) => {
          const d = n.data();
          if (d.Type !== "new_booking") return;
          const at = d.Timestamp?.toMillis?.() ?? now;
          const prev = alerts.get(d.Recipient_ID);
          alerts.set(d.Recipient_ID, prev ?
            {count: prev.count + 1, first: Math.min(prev.first, at)} :
            {count: 1, first: at});
        });

        const remind = [];
        alerts.forEach((a, uid) => {
          if (a.count === 1 && now - a.first >= REMIND_AFTER_MIN * 60000) {
            remind.push(uid);
          }
        });
        await alertCollectors(doc.id, booking, remind, true);

        const allowed =
          WAVE_SIZE * (1 + Math.floor(ageMin / WIDEN_EVERY_MIN));
        if (alerts.size < allowed) {
          const ranked = await rankedEligibleCollectors(booking, doc.id);
          const next = ranked
              .filter((r) => !alerts.has(r.uid))
              .slice(0, allowed - alerts.size)
              .map((r) => r.uid);
          await alertCollectors(doc.id, booking, next, false);
        }
      }
    });

// ─── Audit trail for booking outcomes (Table 14, capstone element CE-05) ─
// Written server-side because auditLogs is admin-only in firestore.rules.
// The client IP is not available to a trigger, so it is recorded as
// "server".
const AUDITED_STATUSES = ["Accepted", "Completed", "Cancelled"];

exports.auditBookingStatusChanges = onDocumentUpdated(
    "bookings/{bookingId}",
    async (event) => {
      const before = event.data?.before?.data();
      const after = event.data?.after?.data();
      if (!before || !after || before.Status === after.Status) return;
      if (!AUDITED_STATUSES.includes(after.Status)) return;
      // Households cancel; collectors accept and complete.
      const actor = after.Status === "Cancelled" ?
        after.Seller_ID : after.Collector_ID;
      const ref = admin.firestore().collection("auditLogs").doc();
      await ref.set({
        Log_ID: ref.id,
        Actor_ID: actor || "",
        Action: `BOOKING_${after.Status.toUpperCase()}`,
        Target_ID: event.params.bookingId,
        Description:
          `Booking ${event.params.bookingId} changed from ` +
          `${before.Status} to ${after.Status}`,
        Create_At: admin.firestore.FieldValue.serverTimestamp(),
        Ip_Adress: "server",
      });
    },
);

// Chat gets its own push path rather than going through the notifications
// collection — that bell is for discrete events, and every message landing
// there would flood it. The conversation list already serves as the inbox
// for messages, so this only sends the push, no Firestore doc.
exports.sendChatPush = onDocumentCreated(
    "messages/{messageId}",
    async (event) => {
      const msg = event.data?.data();
      if (!msg) return;

      const recipientId = msg.Recipient_ID;
      if (!recipientId) return;

      const [recipientDoc, senderDoc] = await Promise.all([
        admin.firestore().collection("UserAccount").doc(recipientId).get(),
        admin.firestore().collection("UserAccount").doc(msg.Sender_ID || "").get(),
      ]);
      const token = recipientDoc.data()?.Fcm_Token;
      if (!token) return;

      const senderName = senderDoc.data()?.Display_Name || "New message";
      const preview = (msg.Text || (msg.Image_URL ? "Sent a photo" : "")).slice(0, 120);

      try {
        await admin.messaging().send({
          token,
          notification: {title: senderName, body: preview},
          data: {type: "chat_message", senderId: msg.Sender_ID || ""},
          android: {notification: {channelId: CHANNEL_BY_TYPE.chat_message}},
        });
      } catch (err) {
        logger.warn(`Chat push failed for ${recipientId}: ${err.message}`);
      }
    },
);
