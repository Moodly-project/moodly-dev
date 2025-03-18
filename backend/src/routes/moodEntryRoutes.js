const express = require('express');
const router = express.Router();
const moodEntryController = require('../controllers/moodEntryController');
const { authenticateToken } = require('../middleware/auth');
const { validateMoodEntry } = require('../middleware/validate');

// Todas as rotas de registros de humor requerem autenticação
router.use(authenticateToken);

// Rotas para gerenciar registros de humor
router.post('/', validateMoodEntry, moodEntryController.createMoodEntry);
router.get('/', moodEntryController.getMoodEntries);
router.get('/stats', moodEntryController.getMoodStats);
router.get('/:id', moodEntryController.getMoodEntryById);
router.put('/:id', validateMoodEntry, moodEntryController.updateMoodEntry);
router.delete('/:id', moodEntryController.deleteMoodEntry);

module.exports = router; 