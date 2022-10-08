import admin from "firebase-admin";

import { ILocation, LocationRepository } from '../repositories';
import { client } from '../index';

export enum BikeTopics {
    PARK = 'bike/park',
    LOCATION = 'bike/location',
    WARNING = 'bike/warning'
}

const BIKE_ID = '123'
export class BikeService {
    private locationRepository = new LocationRepository();
    private messagingService = admin.messaging();

    public async sendNotificationToDevice() {
        try {
            const message = await this.messagingService.sendToTopic("bike_owner", {
                notification: {
                    title: "⚠️Sua bicicleta saiu do lugar em que foi estacionada!⚠️",
                    body: "Sua bicicleta saiu do lugar em que estava antes."
                },
            });
            console.log(message);
        } catch (error) {
            console.error(error)
        }
    }

    public async toggleBikeParking(bikeId: string, value: boolean) {
        await client.publish(BikeTopics.PARK, `${value}`);
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