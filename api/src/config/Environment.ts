import 'dotenv/config';
import MQTT from "async-mqtt";

const mongo = {
    uri: process.env.MONGOURL!,
    dbName: process.env.DB_NAME!
};

const node = {
    port: process.env.PORT ?? 4000
};

const firebase = {
    type: process.env.FIREBASE_TYPE!,
    project_id: process.env.FIREBASE_PROJECT_ID!,
    private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID!,
    private_key: process.env.FIREBASE_PRIVATE_KEY!,
    client_email: process.env.FIREBASE_CLIENT_EMAIL!,
    client_id: process.env.FIREBASE_CLIENT_ID!,
    auth_uri: process.env.FIREBASE_AUTH_URI!,
    token_uri: process.env.FIREBASE_TOKEN_URI!,
    auth_provider_x509_cert_url: process.env.FIREBASE_AUTH_PROVIDER_CERT_URL!,
    client_x509_cert_url: process.env.FIREBASE_CLIENT_CERT_URL!
};

const mqtt: MQTT.IClientOptions = {
    host: process.env.MQTT_HOST!,
    port: +process.env.MQTT_PORT!,
    protocol: "mqtt",
    // username: process.env.MQTT_USER!,
    // password: process.env.MQTT_PASSWD!,
    clientId: process.env.MQTT_CLIENT_ID!
}

export default Object.freeze({
    mongo,
    node,
    firebase,
    mqtt
});