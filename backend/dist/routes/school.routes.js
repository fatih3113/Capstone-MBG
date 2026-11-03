"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const school_controller_1 = require("../controllers/school.controller");
const router = (0, express_1.Router)();
const ctrl = new school_controller_1.SchoolController();
// GET /api/v1/schools?level=SD&city=Jakarta&search=name
router.get('/', ctrl.getSchoolsFiltered);
// GET /api/v1/schools/:id
router.get('/:id', ctrl.getSchoolById);
exports.default = router;
//# sourceMappingURL=school.routes.js.map