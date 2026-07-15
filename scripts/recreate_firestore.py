#!/usr/bin/env python3
"""Recreate KiloTap Firestore data with paper-aligned field names (Tables 7-15).
Run: python3 recreate_firestore.py
"""
from google.cloud import firestore
import sys

db = firestore.Client.from_service_account_json(
    '/root/.hermes/firebase/kilotap-prototype-service-account.json'
)

# ════ DELETE ════
print('Wiping Firestore...')
for col in ['UserAccount', 'bookings', 'bookingItems', 'ratings', 'notifications', 'auditLogs', 'scrapWeights']:
    for d in list(db.collection(col).stream()):
        for sub in d.reference.collections():
            for sd in list(sub.stream()):
                sd.reference.delete()
        d.reference.delete()
    print(f'  {col} ✓')

# ════ UserAccount ════
print('\nSeeding UserAccount...')
acct = db.collection('UserAccount')
uid_h = 'iu941alecVT6VQvhsr1dDp4BHwm1'
uid_c = 'Mc5GcfXGy2bHkwiSfIUyU13dTXo2'
uid_a = '7AKGgK7R1ff8key96XkFOugc5282'

# Household
acct.document(uid_h).set({
    'Account_Id': uid_h, 'Auth_UID': uid_h, 'Display_Name': 'Maria Santos',
    'Email': 'maria.santos@gmail.com', 'Phone': '09941395858', 'Role': 'Household',
    'Created_At': firestore.SERVER_TIMESTAMP,
})
acct.document(uid_h).collection('ScrapSeller').document(uid_h).set({
    'Seller_Id': uid_h, 'Account_Id': uid_h, 'Full_Name': 'Maria Santos',
    'Address': 'Maa, Davao City', 'Housing_Type': 'House',
    'Preferred_Schedule': 'ASAP', 'Created_At': firestore.SERVER_TIMESTAMP,
})

# Collector
acct.document(uid_c).set({
    'Account_Id': uid_c, 'Auth_UID': uid_c, 'Display_Name': 'Juan Dela Cruz',
    'Email': 'juan.delacruz@gmail.com', 'Phone': '09912144912', 'Role': 'Collector',
    'Created_At': firestore.SERVER_TIMESTAMP,
})
acct.document(uid_c).collection('ScrapCollector').document(uid_c).set({
    'Collector_ID': uid_c, 'Account_Id': uid_c, 'Full_Name': 'Juan Dela Cruz',
    'Vehicle_Type': 'Tricycle', 'Vehicle_Capacity_Kg': 500.0,
    'Preferred_Materials': ['Metal', 'Appliances'],
    'Verification_Status': 'Verified',
    'Verification_Docs': [
        {'type': 'Valid ID', 'url': '', 'status': 'verified'},
        {'type': 'Vehicle Photo', 'url': '', 'status': 'verified'},
        {'type': 'Profile Photo Match', 'url': '', 'status': 'verified'},
    ],
    'Digital_Badge_URL': '', 'Avg_Rating': 4.8,
    'Current_Latitude': 7.0734, 'Current_Longitude': 125.6128,
    'Online_Status': True,
})

# Admin
acct.document(uid_a).set({
    'Account_Id': uid_a, 'Auth_UID': uid_a, 'Display_Name': 'Admin',
    'Email': 'admin@kilotap.com', 'Phone': '', 'Role': 'Admin',
    'Created_At': firestore.SERVER_TIMESTAMP,
})

# ════ scrapWeights ════
print('Seeding scrapWeights...')
sw = db.collection('scrapWeights')
weights = {
    'refrigerator_standard': (100.0, 'Heavy Override'),
    'washing_machine': (65.0, 'Heavy Override'),
    'freezer': (65.0, 'Heavy Override'),
    'cast_iron_bathtub': (135.0, 'Heavy Override'),
    'dishwasher': (50.0, 'Large'),
    'clothes_dryer': (49.0, 'Large'),
    'stove_range': (46.0, 'Large'),
    'electric_cooker': (46.0, 'Large'),
    'window_aircon': (25.0, 'Large'),
    'crt_television': (31.6, 'Large'),
    'tire_truck': (50.0, 'Large'),
    'metal_pipe_1m': (3.5, 'Large'),
    'microwave_oven': (15.0, 'Medium'),
    'microwave': (15.0, 'Medium'),
    'desktop_computer': (10.0, 'Medium'),
    'hi_fi_system': (10.0, 'Medium'),
    'metal_sheet_1sqm': (8.0, 'Medium'),
    'tire_car': (8.0, 'Medium'),
    'metal_rod_1m': (2.0, 'Medium'),
    'cardboard_box_large': (1.2, 'Medium'),
    'vacuum_cleaner': (8.0, 'Small'),
    'printer': (6.5, 'Small'),
    'video_recorder_dvd': (5.0, 'Small'),
    'lcd_screen': (4.7, 'Small'),
    'laptop_computer': (3.5, 'Small'),
    'electric_drill': (2.0, 'Small'),
    'glass_bottle_1L': (0.65, 'Small'),
    'glass_bottle_330ml': (0.35, 'Small'),
    'cardboard_box_small': (0.3, 'Small'),
    'mobile_phone': (0.1, 'Small'),
    'metal_bolt': (0.05, 'Small'),
    'plastic_bottle_1L': (0.04, 'Small'),
    'plastic_bottle_500ml': (0.03, 'Small'),
}
for name, (wt, sz) in weights.items():
    sw.document(name).set({'Class_Name': name, 'Weight_Kg': wt, 'Size_class': sz})

# ════ bookings ════
print('Seeding bookings...')
b = db.collection('bookings').document('PKP-0042')
b.set({
    'Booking_ID': 'PKP-0042', 'Seller_ID': uid_h, 'Collector_ID': uid_c,
    'Status': 'Accepted', 'VehicleRequirement': 'Tricycle', 'SpatialAreaRatio': 0.35,
    'PickupGPS': firestore.GeoPoint(7.0736, 125.6110),
    'PickupAddress': 'Maa, Davao City', 'HaversineDistanceKm': 0.24,
    'Created_At': firestore.SERVER_TIMESTAMP, 'Completed_At': None,
})
items = [
    ('ITM-001', 'Refrigerator', 1, 'Heavy Override', 100.0, 'refrigerator_standard'),
    ('ITM-002', 'Plastic Bottle', 6, 'Small', 0.24, 'plastic_bottle_1L'),
    ('ITM-003', 'Metal Pipes', 3, 'Large', 10.5, 'metal_pipe_1m'),
]
for iid, name, qty, sz, wt, sc in items:
    b.collection('bookingItems').document(iid).set({
        'Item_ID': iid, 'Booking_ID': 'PKP-0042', 'ItemName': name,
        'Quantity': qty, 'SizeClass': sz, 'EstimatedWeightKg': wt, 'ScrapClass': sc,
    })

# ════ ratings ════
db.collection('ratings').document('RAT-001').set({
    'Rating_ID': 'RAT-001', 'Booking_ID': 'PKP-0042',
    'Seller_ID': uid_h, 'Collector_ID': uid_c, 'Score': 4,
    'Feedback_Text': 'On time and professional',
    'Tags': ['On Time', 'Professional'], 'Created_At': firestore.SERVER_TIMESTAMP,
})

# ════ notifications ════
db.collection('notifications').document('NOTIF-001').set({
    'Notification_ID': 'NOTIF-001', 'Recipient_ID': uid_h, 'Booking_ID': 'PKP-0042',
    'Title': 'Collector on the way',
    'Message': 'Juan Dela Cruz is on the way to pick up your scrap.',
    'IsRead': False, 'Type': 'on_the_way', 'Timestamp': firestore.SERVER_TIMESTAMP,
})

# ════ auditLogs ════
db.collection('auditLogs').document('LOG-001').set({
    'Log_ID': 'LOG-001', 'Actor_ID': uid_a, 'Action': 'COLLECTOR_VERIFIED',
    'Target_ID': uid_c, 'Previous_Value': 'Pending', 'New_Value': 'Verified',
    'Reason': 'Documents validated by admin', 'Timestamp': firestore.SERVER_TIMESTAMP,
})

print('\n✅ All collections recreated with ACM Paper field names.')
