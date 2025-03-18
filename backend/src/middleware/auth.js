const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Middleware para verificar o token JWT
const authenticateToken = async (req, res, next) => {
  try {
    // Obter o token do cabeçalho Authorization
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN
    
    if (!token) {
      return res.status(401).json({ message: 'Acesso negado. Token não fornecido.' });
    }
    
    // Verificar o token
    jwt.verify(token, process.env.JWT_SECRET, async (err, decoded) => {
      if (err) {
        return res.status(403).json({ message: 'Token inválido ou expirado.' });
      }
      
      // Verificar se o usuário ainda existe
      const user = await User.findById(decoded.userId);
      
      if (!user) {
        return res.status(404).json({ message: 'Usuário não encontrado.' });
      }
      
      // Adicionar informações do usuário ao objeto req
      req.user = {
        id: user.id,
        name: user.name,
        email: user.email
      };
      
      next();
    });
  } catch (error) {
    console.error('Erro no middleware de autenticação:', error);
    return res.status(500).json({ message: 'Erro interno do servidor.' });
  }
};

// Gerar token JWT
const generateToken = (user) => {
  return jwt.sign(
    { userId: user.id },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN }
  );
};

module.exports = {
  authenticateToken,
  generateToken
}; 