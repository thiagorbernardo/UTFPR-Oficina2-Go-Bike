import { Router } from 'express';

import Bike from './Bike';

const routes = Router();

routes.use(Bike);

export default routes;