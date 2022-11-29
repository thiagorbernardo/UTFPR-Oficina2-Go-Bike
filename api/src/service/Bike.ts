import admin from "firebase-admin";

import { ILocation, LocationRepository } from '../repositories';
import { client } from '../index';

export enum BikeTopics {
    PARK = 'bike/park',
    LOCATION = 'bike/location',
    WARNING = 'bike/warning',
    WARNING_STATE = 'bike/warning/state'
}

export const BIKE_MESSAGES = {
    WARNING_MOVING_BIKE_TITLE: "⚠️Sua bicicleta saiu do lugar em que foi estacionada!⚠️",
    WARNING_MOVING_BIKE_BODY: "Sua bicicleta saiu do lugar em que estava antes.",
    PARKED_BIKE_TITLE: "Bicicleta estacionada com sucesso!🆗",
    UNPARKED_BIKE_TITLE: "Bicicleta desestacionada com sucesso!🆗",
}

const BIKE_ID = '123'
export class BikeService {
    private locationRepository = new LocationRepository();
    private messagingService = admin.messaging();

    public async sendNotificationToDevice(title: string, body?: string) {
        try {
            const message = await this.messagingService.sendToTopic("bike_owner", {
                notification: {
                    title: title,
                    body: body || "",
                },
            });
            console.log(message);
        } catch (error) {
            console.error(error)
        }
    }

    public async toggleBikeParking(bikeId: string, value: boolean) {
        console.log("Parking", bikeId, `${+value}`);
        await client.publish(BikeTopics.PARK, `${+value}`);
    }

    public async getBikeLastLocation(bikeId: string): Promise<ILocation | null> {
        const location = await this.locationRepository.findLatest(bikeId);

        return location;
    }

    public async saveBikeLocation(lat: string, lng: string, velocity: string) {
        console.log(lat, lng, velocity);
        await this.locationRepository.createRegister({
            bikeId: BIKE_ID,
            latitude: parseFloat(lat),
            longitude: parseFloat(lng),
            velocity: parseFloat(velocity),
        });
    }

    public async notifyParking(oldState: number, newState: number) {
        if (oldState === 0 && newState === 1) {
            await this.sendNotificationToDevice(BIKE_MESSAGES.PARKED_BIKE_TITLE, `${newState}`);
        } else if (oldState === 1 && newState === 0) {
            await this.sendNotificationToDevice(BIKE_MESSAGES.UNPARKED_BIKE_TITLE, `${newState}`);
        }
    }
}