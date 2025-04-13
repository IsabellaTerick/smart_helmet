// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const twilio = require('twilio');

admin.initializeApp();

exports.twilioWebhook = functions.https.onRequest(async (req, res) => {
  // Validate that the request is from Twilio
  const twilioSignature = req.headers['x-twilio-signature'];
  const params = req.body;
  const url = `${req.protocol}://${req.hostname}${req.originalUrl}`;

  // Use environment variables instead of functions.config()
 const authToken = process.env.TWILIO_AUTH_TOKEN;
 const accountSid = process.env.TWILIO_ACCOUNT_SID;
 const twilioNumber = process.env.TWILIO_PHONE_NUMBER;

  console.log('Processing request from Twilio');

  const client = twilio(accountSid, authToken);

  const requestIsValid = twilio.validateRequest(
    authToken,
    twilioSignature,
    url,
    params
  );

  if (!requestIsValid && process.env.NODE_ENV !== 'development') {
    console.log('Invalid Twilio request');
    return res.status(403).send('Forbidden');
  }

  try {
    // Extract the message content and sender
    const incomingMessage = req.body.Body || '';
    const fromNumber = req.body.From || '';

    console.log(`Received message: "${incomingMessage}" from ${fromNumber}`);

    // Check if the message is "UPDATE" (case-insensitive)
    if (incomingMessage.trim().toUpperCase() === 'UPDATE') {
      // Look for device IDs
      const deviceIds = [];
      const devicesSnapshot = await admin.firestore().collection('device_registry').get();
      devicesSnapshot.forEach(doc => {
        deviceIds.push(doc.id);
      });

      console.log(`Found ${deviceIds.length} registered devices`);
      let foundCrashMode = false;

      // Check each device for crash mode
      for (const deviceId of deviceIds) {
        console.log(`Checking device: ${deviceId}`);
        const modeDoc = await admin.firestore().collection(deviceId).doc('settings').get();

        if (modeDoc.exists && modeDoc.data().mode === 'crash') {
          foundCrashMode = true;
          console.log(`Found device in crash mode: ${deviceId}`);

          // Get FCM token
          const fcmToken = modeDoc.data().fcmToken;

          if (fcmToken) {
            console.log(`Sending FCM message to token: ${fcmToken}`);
            // Send an FCM message to request location update
            await admin.messaging().send({
              token: fcmToken,
              data: {
                type: 'location_request',
                timestamp: Date.now().toString()
              }
            });

            // Tell the requester we're getting the location
            await client.messages.create({
              body: 'Requesting current location from Smart Helmet user...',
              from: twilioNumber,
              to: fromNumber
            });

            // Wait for device to update location (increase to 15 seconds)
            console.log('Waiting for location update...');
            await new Promise(resolve => setTimeout(resolve, 15000));

            // Get updated location
            console.log('Checking for updated location');
            const updatedDoc = await admin.firestore().collection(deviceId).doc('settings').get();

            if (updatedDoc.exists) {
              const data = updatedDoc.data();
              console.log('Updated document data:', JSON.stringify(data));

              const currentPosition = data.currentPosition;
              const initialPosition = data.initialPosition;

              // Use currentPosition if available and recent (within last 30 seconds)
              // Otherwise fall back to initialPosition (crash location)
              const positionUpdatedAt = data.positionUpdatedAt ? data.positionUpdatedAt.toDate() : null;
              console.log('Position updated at:', positionUpdatedAt);

              const isRecentUpdate = positionUpdatedAt &&
                (Date.now() - positionUpdatedAt.getTime() < 30000);

              if (currentPosition && isRecentUpdate) {
                const googleMapsUrl = `https://maps.google.com/?q=${currentPosition.latitude},${currentPosition.longitude}`;
                console.log('Sending current location');

                // Get user name if available
                let userName = 'Smart Helmet user';
                if (data.userName) {
                  userName = data.userName;
                }

                await client.messages.create({
                  body: `Current location for ${userName}: ${googleMapsUrl}`,
                  from: twilioNumber,
                  to: fromNumber
                });
              } else if (initialPosition) {
                // Fall back to crash location
                const googleMapsUrl = `https://maps.google.com/?q=${initialPosition.latitude},${initialPosition.longitude}`;
                console.log('Falling back to crash location');

                await client.messages.create({
                  body: `Could not get real-time location. Last known crash location: ${googleMapsUrl}`,
                  from: twilioNumber,
                  to: fromNumber
                });
              } else {
                console.log('No location data available');
                await client.messages.create({
                  body: 'No location data available for the Smart Helmet user.',
                  from: twilioNumber,
                  to: fromNumber
                });
              }
            }
          } else {
            // No FCM token, can't request real-time update
            // Just send the crash location if available
            console.log('No FCM token available');
            if (modeDoc.data().initialPosition) {
              const position = modeDoc.data().initialPosition;
              const googleMapsUrl = `https://maps.google.com/?q=${position.latitude},${position.longitude}`;

              await client.messages.create({
                body: `Last known crash location: ${googleMapsUrl}`,
                from: twilioNumber,
                to: fromNumber
              });
            } else {
              await client.messages.create({
                body: 'No location data available for the Smart Helmet user.',
                from: twilioNumber,
                to: fromNumber
              });
            }
          }

          break; // Only handle the first device in crash mode
        }
      }

      if (!foundCrashMode) {
        // No devices in crash mode
        console.log('No devices in crash mode');
        await client.messages.create({
          body: 'The Smart Helmet user is not currently in crash mode.',
          from: twilioNumber,
          to: fromNumber
        });
      }
    }

    // TwiML response to properly end the Twilio request
    const twiml = new twilio.twiml.MessagingResponse();
    res.type('text/xml');
    res.send(twiml.toString());

  } catch (error) {
    console.error('Error processing Twilio webhook:', error);
    res.status(500).send('Error processing request');
  }
});