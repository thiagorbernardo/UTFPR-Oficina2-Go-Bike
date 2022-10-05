import { StatusCodes } from "http-status-codes";
import { v4 as uuidv4 } from 'uuid';
import { sign } from 'jsonwebtoken';
import admin from "firebase-admin";

// import AppError from "../error/AppError";
// import { UsersRepository } from '../repositories';

import { client } from '../index';

export class BikeService {
    // private userRepository = new UsersRepository();
    private messagingService = admin.messaging();

    private async sendNotificationToDevice() {
        try {
            const messagingService = admin.messaging();
    
            await messagingService.sendToTopic("bike_owner", {
                notification: {
                    title: "⚠️Sua bicicleta está sendo roubada!⚠️",
                    body: "Sua bicicleta saiu do lugar em que estava antes."
                },
            })
        } catch (error) {
            console.error(error)
        }
    }

    public async toggleBikeParking(value: string) {
        await client.publish('bike/park', `${value}`);
    }

    public async getBikeLastLocation(bikeId: string) {
        // const user = await this.userRepository.findByEmail(email);

        // if (user) {
        //     throw new AppError(AuthErrors.EMAIL_ALREADY_EXISTS, StatusCodes.BAD_REQUEST);
        // }

        // const _id = uuidv4();

        // await this.userRepository.createUser({ _id, name, email, password });

        // return _id;
    }
}