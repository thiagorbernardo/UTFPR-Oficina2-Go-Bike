import express from 'express';
import 'express-async-errors';
import MQTT from "async-mqtt";
import { cert, initializeApp } from "firebase-admin/app";
import admin from "firebase-admin";

import AppRoutes from './routes';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const firebaseToken = require("../serviceAccountKey.json");
initializeApp({
  credential: admin.credential.cert(firebaseToken)
});

const app = express();
const PORT = 3000;

export const client = MQTT.connect("tcp://broker.hivemq.com:1883");

app.use(express.json());

app.use('/api/', AppRoutes);

const subscribeMQTT = async (topic: string) => {
  const result = await client.subscribe(topic);
  console.log(result);
  console.log("Subscribed!");
};

const registerNotifications = async () => {
  client.on('message', (topic: string, message: string) => {
    //   const value = message.toString();
    
    //   console.log(`RECEIVED: ${value} in ${topic}`);
    
    //   const humidity = value.match(/H(.+)T(.+)/)?.[1];
    //   const temperature = value.match(/H(.+)T(.+)/)?.[2];
    
    //   if (!humidity || !temperature) return;
    
    //   indoorClimate = {
    //     humidity: +humidity,
    //     temperature: +temperature
    //   };
    });
}

app.listen(PORT, async () => {
  try {
    await subscribeMQTT('/bike/park');
    await subscribeMQTT('/bike/location');
    console.log(`⚡️[server]: Server is running at http://localhost:${PORT}`);
  } catch (error) {
    console.error(error)
  }
});

