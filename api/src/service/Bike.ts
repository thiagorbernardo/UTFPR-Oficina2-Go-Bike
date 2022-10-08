import admin from "firebase-admin";

import { ILocation, LocationRepository } from '../repositories';
import { client } from '../index';

export enum BikeTopics {
    PARK = 'bike/park',
    LOCATION = 'bike/location',
    WARNING = 'bike/warning'
}

export const BIKE_MESSAGES = {
    WARNING_MOVING_BIKE_TITLE: "⚠️Sua bicicleta saiu do lugar em que foi estacionada!⚠️",
    WARNING_MOVING_BIKE_BODY: "Sua bicicleta saiu do lugar em que estava antes.",
    PARKED_BIKE_TITLE: "Bicicleta estacionada com sucesso!🆗",
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
        await client.publish(BikeTopics.PARK, `${value}`);
        await this.sendNotificationToDevice(BIKE_MESSAGES.PARKED_BIKE_TITLE);
    }

    public async getBikeLastLocation(bikeId: string): Promise<ILocation | null> {
        const location = await this.locationRepository.findLatest(bikeId);

        return location;
    }

    public async saveBikeLocation(lat: string, lng: string, velocity: string, precision: string) {
        console.log(lat, lng, velocity, precision);
        await this.locationRepository.createRegister({
            bikeId: BIKE_ID,
            latitude: parseFloat(lat),
            longitude: parseFloat(lng),
            velocity: parseFloat(velocity),
            precision: parseFloat(precision)
        });
    }
}