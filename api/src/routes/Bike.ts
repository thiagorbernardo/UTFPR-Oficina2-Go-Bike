import { Router } from 'express';
import { BikeController } from '../controller';

const router = Router();

router.get('/bike/:id/lastLocation', BikeController.getLastLocation);

router.post('/bike/:id/park', BikeController.toggleBikeParking);

export default router;