const express = require('express');
const router = express.Router();
const activityController = require('../controllers/activityController');
const { authenticateToken } = require('../middleware/auth');

// Rotas que não requerem autenticação
router.get('/', activityController.getAllActivities);

// Rotas que requerem autenticação
router.get('/user/common', authenticateToken, activityController.getMostCommonActivities);
router.post('/', authenticateToken, activityController.createActivity);
router.put('/:id', authenticateToken, activityController.updateActivity);
router.delete('/:id', authenticateToken, activityController.deleteActivity);

module.exports = router; 