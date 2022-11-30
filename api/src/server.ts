import mongoose from 'mongoose';
import env from './config/Environment';
import lt from 'localtunnel'

mongoose.Promise = Promise;

export const connectDatabase = async () => mongoose.connect(env.mongo.uri!, { dbName: env.mongo.dbName });
export const exposeServer = async () => {
    const tunnel = await lt({ port: 4000, subdomain: 'go-bike-back' });
    console.log(`Tunnel open at ${tunnel.url}`);
}