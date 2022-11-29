import express from 'express';
import 'express-async-errors';
import MQTT, { AsyncClient } from "async-mqtt";
import { initializeApp } from "firebase-admin/app";
import admin from "firebase-admin";

import AppRoutes from './routes';
import { BikeTopics } from './service';
import { BikeController } from './controller';
import Environment from './config/Environment';
import { connectDatabase } from './server';

initializeApp({
  credential: admin.credential.cert(Environment.firebase as any)
});

const app = express();

const _client = MQTT.connect(null, Environment.mqtt);
const client = new AsyncClient(_client)

app.use(express.json());

app.use('/api/', AppRoutes);

const subscribeMQTT = async (topic: string) => {
  try {
    await client.subscribe(topic);
  } catch (error) {
    console.error(error)
  }
};

client.on("connect", async () => {
  console.info("Connected to MQTT broker");
  client.on('message', BikeController.handleMqttMessage);

  subscribeMQTT(BikeTopics.LOCATION);
  subscribeMQTT(BikeTopics.WARNING);
  subscribeMQTT(BikeTopics.WARNING_STATE);
});

app.listen(Environment.node.port, async () => {
  try {
    await connectDatabase();
    console.log(`⚡️[server]: Server is running at http://localhost:${Environment.node.port}`);
  } catch (error) {
    console.error(error)
  }
});

export { client };