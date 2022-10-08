import { Request, Response } from 'express';
import {
    StatusCodes,
} from 'http-status-codes';

import { BikeService, BikeTopics } from '../service';


export class BikeController {
    public static async toggleBikeParking(req: Request, res: Response) {
        const bikeId = req.params.id as string;
        const { value } = req.body;

        const service = new BikeService();

        await service.toggleBikeParking(bikeId, value);

        return res.status(StatusCodes.CREATED).end();
    }

    public static async getLastLocation(req: Request, res: Response) {
        const bikeId = req.params.id as string;

        const service = new BikeService();

        const location = await service.getBikeLastLocation(bikeId);

        if (!location) {
            return res.status(StatusCodes.NOT_FOUND).end();
        }

        return res.status(StatusCodes.OK).send(location);
    }

    public static async handleMqttMessage(topic: string, message: Buffer) {
        const value = message.toString();
        console.log(`TOPIC: ${topic}\nMESSAGE: ${value}`);
        
        const service = new BikeService();

        if (topic === BikeTopics.LOCATION) {
            const pattern = /LT:(.+),LN:(.+),V:(.+),P:(.+)/gi;
            const match = pattern.exec(value);
            const lat = match?.[1];
            const lng = match?.[2];
            const velocity = match?.[3];
            const precision = match?.[4];

            if(!lat || !lng || !velocity || !precision) {
                console.error('Invalid message');
                return;
                // throw new Error('Invalid message');
            }
            await service.saveBikeLocation(lat, lng, velocity, precision);
        } else if (topic === BikeTopics.WARNING) {
            console.log(Boolean(value));
            await service.sendNotificationToDevice();
        }
    }
}