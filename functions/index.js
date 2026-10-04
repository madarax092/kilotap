const {onDocumentCreated} = require("firebase-functions/v2/firestore");
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
    "motorcycle_block", "vehicle_part_big",
  ],
  "Plastic": [
    "plastic_bottle_1L", "plastic_bottle_500ml", "plastic_hdpe", "plastic_pet",
  ],
  "Glass": ["glass_bottle_1L", "glass_bottle_330ml"],
  "Cardboard": ["cardboard_box_large", "cardboard_box_small", "cardboard"],
  "Appliances": [
    "refrigerator_standard", "washing_machine", "freezer", "dishwasher",
    "window_aircon", "microwave_oven", "electric_cooker", "stove_range",
    "clothes_dryer", "vacuum_cleaner", "electric_fan", "splittype_aircon",
    "hair_dryer",
  ],
  "E-Waste": [
    "crt_television", "desktop_computer", "laptop_computer", "printer",
    "lcd_screen", "mobile_phone", "hi_fi_system", "video_recorder_dvd",
    "electric_drill", "microwave", "flatscreentv", "car_battery", "mouse",
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

// Fires on every new booking. The app writes the booking and its items in
// one atomic batch (FirestoreService.createBookingWithItems), so the items
// already exist here. Notifies only Verified, online collectors whose
// vehicle can handle the job and whose material preferences match — the
// same filters Find Scrap applies. Writes one notifications doc per collector, which in
// turn triggers sendNotificationPush above — so these also land in the
// collector's in-app bell, not just as a push.
exports.fanOutNewBookingNotifications = onDocumentCreated(
    "bookings/{bookingId}",
    async (event) => {
      const booking = event.data?.data();
      if (!booking || booking.Status !== "Pending") return;

      const [collectors, items] = await Promise.all([
        admin
            .firestore()
            .collectionGroup("ScrapCollector")
            .where("Verification_Status", "==", "Verified")
            .where("Online_Status", "==", true)
            .get(),
        admin
            .firestore()
            .collection("bookingItems")
            .where("Booking_ID", "==", event.params.bookingId)
            .get(),
      ]);
      if (collectors.empty) return;

      const scrapClasses = items.docs.map((d) => d.data().ScrapClass || "");

      const batch = admin.firestore().batch();
      const notifCol = admin.firestore().collection("notifications");
      let count = 0;
      collectors.forEach((doc) => {
        const collectorUid = doc.ref.parent.parent.id;
        if (collectorUid === booking.Seller_ID) return; // paranoia guard
        const c = doc.data();
        if (!vehicleCanHandle(c.Vehicle_Type, booking.VehicleRequirement)) {
          return;
        }
        if (!matchesPreference(scrapClasses, c.Preferred_Materials)) return;
        count++;
        const ref = notifCol.doc();
        batch.set(ref, {
          Notification_ID: ref.id,
          Recipient_ID: collectorUid,
          Booking_ID: event.params.bookingId,
          Title: "New pickup available",
          Message: booking.VehicleRequirement ?
            `A new pickup needing a ${booking.VehicleRequirement} was posted.` :
            "A new pickup request was posted near you.",
          Type: "new_booking",
          IsRead: false,
          Timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      });
      if (count > 0) await batch.commit();
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
