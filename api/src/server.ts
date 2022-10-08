import mongoose from 'mongoose';
import env from './config/Environment';

mongoose.Promise = Promise;

export const connectDatabase = async () => mongoose.connect(env.mongo.uri!, { dbName: env.mongo.dbName });
