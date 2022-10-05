import { Router, Request, Response } from 'express';
import { BikeController } from '../controller';

const router = Router();

router.get('/bike/:id/lastLocation', BikeController.getLastLocation);

router.post('/bike/park', BikeController.toggleBikeParking);

export default router;