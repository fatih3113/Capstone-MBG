import { Router } from 'express';
import { SchoolController } from '../controllers/school.controller';

const router = Router();
const ctrl = new SchoolController();

// GET /api/v1/schools?level=SD&city=Jakarta&search=name
router.get('/', ctrl.getSchoolsFiltered);

// GET /api/v1/schools/:id
router.get('/:id', ctrl.getSchoolById);

export default router;
