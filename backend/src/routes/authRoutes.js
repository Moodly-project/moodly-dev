const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { validateUserRegistration, validateLogin } = require('../middleware/validate');
const { authenticateToken } = require('../middleware/auth');

// Rotas públicas
router.post('/register', validateUserRegistration, authController.register);
router.post('/login', validateLogin, authController.login);

// Rotas protegidas
router.get('/profile', authenticateToken, authController.getProfile);
router.put('/profile', authenticateToken, authController.updateProfile);
router.put('/password', authenticateToken, authController.updatePassword);

module.exports = router; 