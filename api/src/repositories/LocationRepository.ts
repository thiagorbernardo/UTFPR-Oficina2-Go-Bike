import mongoose, { Document, Schema } from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

import { CollectionModels, Collections } from '../enum';

export type ILocation = {
  _id: string,
  bikeId: string,
  latitude: number,
  longitude: number,
  velocity: number,
};


const WorkRegisterSchema: Schema = new Schema({
  _id: { type: String, required: true },
  bikeId: { type: String, required: true, index: true },
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  velocity: { type: Number, required: true },
}, {
  timestamps: true,
  _id: false,
  toObject: {
    getters: true
  }
});

const WorkRegisterModel = mongoose.model<ILocation & Document>(CollectionModels.LOCATION, WorkRegisterSchema, Collections.LOCATION);

export class LocationRepository {
  protected model = WorkRegisterModel;

  public async createRegister({ bikeId, latitude, longitude, velocity }: Omit<Partial<ILocation>, "_id">) {
    return await this.model.create({
      _id: uuidv4(),
      bikeId,
      latitude,
      longitude,
      velocity,
    });
  }

  public async findLatest(bikeId: string): Promise<ILocation> {
    return await this.model.findOne({
      bikeId,
    }).sort({ createdAt: -1 }).lean();
  }
}
