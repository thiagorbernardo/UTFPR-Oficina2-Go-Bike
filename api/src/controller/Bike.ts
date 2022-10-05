import { Request, Response } from 'express';
import {
    StatusCodes,
} from 'http-status-codes';

import { BikeService } from '../service';


export class BikeController {
    public static async toggleBikeParking (req: Request, res: Response) {
        const bikeId = req.params.id as string;
        const { value } = req.body;

        const service = new BikeService();

        await service.toggleBikeParking(bikeId, value);

        return res.status(StatusCodes.CREATED).end();
    }

    public static async getLastLocation (req: Request, res: Response) {
        const bikeId = req.params.id as string;

        const service = new BikeService();

        await service.getBikeLastLocation(bikeId);

        return res.status(StatusCodes.CREATED).end();
    }
}