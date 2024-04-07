const functions = require('firebase-functions');
const admin = require('firebase-admin');
const logger = require('firebase-functions/logger');
const fetch = require('node-fetch');
const { google } = require('googleapis');

admin.initializeApp();

// Define the required scopes for the JWT client
const SCOPES = ['https://www.googleapis.com/auth/cloud-platform'];

// Function to retrieve the access token using service account credentials
async function getAccessToken() {
    try {
        const key = require('D:\Project\local_service_providers\local-service-providers-app-firebase-adminsdk-ibvz1-bb625990a8.json');
        const jwtClient = new google.auth.JWT(
            key.client_email,
            null,
            key.private_key,
            SCOPES,
            null
        );

        // Authorize the JWT client and retrieve access token
        const tokens = await jwtClient.authorize();
        return tokens.access_token;
    } catch (error) {
        throw new Error('Error fetching access token: ' + error.message);
    }
}

exports.sendNotification = functions.https.onRequest(async(req, res) => {
    try {
        const { userId, title, body } = req.body; // Assuming you are passing userId, title, and body in the request body

        if (!userId || !title || !body) {
            return res.status(400).send('Missing parameters');
        }

        // Fetch the FCM token for the user from Firestore or any other database
        // const userSnapshot = await admin.firestore().collection('users').doc(userId).get();
        const fcmToken = userId;

        // Construct the notification payload
        const notification = {
            title: title,
            body: body,
        };

        // Construct the FCM message
        const message = {
            token: fcmToken,
            notification: notification,
        };

        // Retrieve the access token
        const accessToken = await getAccessToken();

        // Send the FCM message
        const response = await fetch('https://fcm.googleapis.com/v1/projects/local-service-providers-app/messages:send', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + accessToken,
            },
            body: JSON.stringify(message),
        });

        if (!response.ok) {
            logger.error('Failed to send notification:', response.statusText);
            return res.status(500).send('Failed to send notification');
        }

        logger.info('Notification sent successfully');
        return res.status(200).send('Notification sent successfully');
    } catch (error) {
        logger.error('Error sending notification:', error);
        return res.status(500).send('Error sending notification');
    }
});