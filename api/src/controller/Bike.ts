import { Request, Response } from 'express';
import {
    StatusCodes,
} from 'http-status-codes';

import { BikeService, BikeTopics, BIKE_MESSAGES } from '../service';

let BIKE_STATE: number | null = null;
export class BikeController {
    public static async toggleBikeParking(req: Request, res: Response) {
        const bikeId = req.params.id as string;

        const service = new BikeService();

        await service.toggleBikeParking(bikeId, !Boolean(BIKE_STATE));

        return res.status(StatusCodes.CREATED).end();
    }

    public static async getLastLocation(req: Request, res: Response) {
        const bikeId = req.params.id as string;

        const service = new BikeService();

        const location = await service.getBikeLastLocation(bikeId);

        if (!location) {
            return res.status(StatusCodes.NOT_FOUND).end();
        }

        return res.status(StatusCodes.OK).send({...location, state: Boolean(BIKE_STATE)});
    }

    public static async handleMqttMessage(topic: string, message: Buffer) {
        const value = message.toString();
        console.log(`TOPIC: ${topic}\nMESSAGE: ${value}`);
        
        const service = new BikeService();

        if (topic === BikeTopics.LOCATION) {
            const pattern = /LT:(.+),LN:(.+),V:(.+)/gi;
            const match = pattern.exec(value);
            const lat = match?.[1];
            const lng = match?.[2];
            const velocity = match?.[3];

            if (!lat || !lng || !velocity) {
                console.error('Invalid message');
                return;
                // throw new Error('Invalid message');
            }
            await service.saveBikeLocation(lat, lng, velocity);
        } else if (topic === BikeTopics.WARNING) {
            console.log(Boolean(value));
            await service.sendNotificationToDevice(BIKE_MESSAGES.WARNING_MOVING_BIKE_TITLE, BIKE_MESSAGES.WARNING_MOVING_BIKE_BODY);
        } else if (topic === BikeTopics.WARNING_STATE) {
            if (BIKE_STATE === null) {
                BIKE_STATE = +value;
            }
            const oldState = BIKE_STATE;
            const newState = +value;
            BIKE_STATE = +value;
            await service.notifyParking(oldState, newState);
        }
    }
}