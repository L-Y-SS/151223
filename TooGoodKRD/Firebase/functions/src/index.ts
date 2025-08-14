import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from "stripe";

admin.initializeApp();
const db = admin.firestore();
const stripe = new Stripe(functions.config().stripe?.secret || "", { apiVersion: "2023-10-16" });

export const createPaymentIntent = functions.https.onCall(async (data, context) => {
	if (!context.auth) { throw new functions.https.HttpsError("unauthenticated", "Sign in required"); }
	const amount = Number(data.amount) || 1000; // amount in cents
	const paymentIntent = await stripe.paymentIntents.create({ amount, currency: "usd", automatic_payment_methods: { enabled: true } });
	return { clientSecret: paymentIntent.client_secret };
});

export const onNewItemNotify = functions.firestore.document("items/{itemId}").onCreate(async (snap, ctx) => {
	const item = snap.data() as any;
	const cityTopic = `city_${item.city}`;
	await admin.messaging().sendToTopic(cityTopic, {
		notification: {
			title: "New item available",
			body: `${item.name} for $${(item.priceCents/100).toFixed(2)}`
		}
	});
});

export const seedSampleData = functions.https.onCall(async (data, context) => {
	const batch = db.batch();
	const businesses = [
		{ name: "Duhok Bakery", city: "Duhok", category: "Bakery", contactPhone: "+9647510000000", latitude: 36.868, longitude: 42.989 },
		{ name: "Zakho Market", city: "Zakho", category: "Grocery", contactPhone: "+9647511111111", latitude: 37.144, longitude: 42.673 }
	];
	const businessIds: string[] = [];
	for (const b of businesses) {
		const ref = db.collection("businesses").doc();
		businessIds.push(ref.id);
		batch.set(ref, { ...b, ownerUserId: "seed", createdAt: admin.firestore.FieldValue.serverTimestamp() });
	}
	await batch.commit();

	const now = admin.firestore.Timestamp.now();
	const items = [
		{ businessId: businessIds[0], name: "Surplus Bread", quantity: 10, category: "Bakery", city: "Duhok", priceCents: 500, expiryDate: now, pickupStart: now, pickupEnd: now },
		{ businessId: businessIds[1], name: "Veggie Box", quantity: 5, category: "Grocery", city: "Zakho", priceCents: 1500, expiryDate: now, pickupStart: now, pickupEnd: now }
	];
	for (const it of items) {
		await db.collection("items").add({ ...it, isSoldOut: false, createdAt: admin.firestore.FieldValue.serverTimestamp() });
	}
	return { ok: true, businessIds };
});