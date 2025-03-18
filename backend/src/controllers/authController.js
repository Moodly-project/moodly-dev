const User = require('../models/User');
const { generateToken } = require('../middleware/auth');

// Registrar um novo usuário
const register = async (req, res) => {
  try {
    const { name, email, password } = req.body;
    
    // Verificar se o email já está em uso
    const existingUser = await User.findByEmail(email);
    if (existingUser) {
      return res.status(409).json({ message: 'Este email já está em uso.' });
    }
    
    // Criar novo usuário
    const newUser = await User.create({ name, email, password });
    
    // Gerar token JWT
    const token = generateToken(newUser);
    
    res.status(201).json({
      message: 'Usuário registrado com sucesso!',
      user: {
        id: newUser.id,
        name: newUser.name,
        email: newUser.email
      },
      token
    });
  } catch (error) {
    console.error('Erro ao registrar usuário:', error);
    res.status(500).json({ message: 'Erro ao registrar usuário.' });
  }
};

// Login de usuário
const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Verificar credenciais
    const user = await User.verifyCredentials(email, password);
    
    if (!user) {
      return res.status(401).json({ message: 'Email ou senha inválidos.' });
    }
    
    // Gerar token JWT
    const token = generateToken(user);
    
    res.status(200).json({
      message: 'Login realizado com sucesso!',
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      },
      token
    });
  } catch (error) {
    console.error('Erro ao fazer login:', error);
    res.status(500).json({ message: 'Erro ao fazer login.' });
  }
};

// Obter perfil do usuário logado
const getProfile = async (req, res) => {
  try {
    // O middleware de autenticação já adicionou as informações do usuário no req.user
    res.status(200).json({ user: req.user });
  } catch (error) {
    console.error('Erro ao obter perfil:', error);
    res.status(500).json({ message: 'Erro ao obter perfil do usuário.' });
  }
};

// Atualizar perfil do usuário
const updateProfile = async (req, res) => {
  try {
    const { name, email } = req.body;
    const userId = req.user.id;
    
    // Verificar se o novo email já está em uso (se for diferente do atual)
    if (email !== req.user.email) {
      const existingUser = await User.findByEmail(email);
      if (existingUser) {
        return res.status(409).json({ message: 'Este email já está em uso.' });
      }
    }
    
    // Atualizar perfil
    const updatedUser = await User.update(userId, { name, email });
    
    res.status(200).json({
      message: 'Perfil atualizado com sucesso!',
      user: updatedUser
    });
  } catch (error) {
    console.error('Erro ao atualizar perfil:', error);
    res.status(500).json({ message: 'Erro ao atualizar perfil do usuário.' });
  }
};

// Atualizar senha do usuário
const updatePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.user.id;
    
    // Verificar senha atual
    const user = await User.findByEmail(req.user.email);
    const isValidPassword = await User.verifyCredentials(req.user.email, currentPassword);
    
    if (!isValidPassword) {
      return res.status(401).json({ message: 'Senha atual incorreta.' });
    }
    
    // Atualizar senha
    await User.updatePassword(userId, newPassword);
    
    res.status(200).json({ message: 'Senha atualizada com sucesso!' });
  } catch (error) {
    console.error('Erro ao atualizar senha:', error);
    res.status(500).json({ message: 'Erro ao atualizar senha.' });
  }
};

module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  updatePassword
}; 