const { pool } = require('../config/db');
const bcrypt = require('bcrypt');

class User {
  // Criar um novo usuário
  static async create(userData) {
    const { name, email, password } = userData;
    
    // Hash da senha
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    try {
      const [result] = await pool.execute(
        'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
        [name, email, hashedPassword]
      );
      
      return { id: result.insertId, name, email };
    } catch (error) {
      throw error;
    }
  }
  
  // Buscar usuário por email
  static async findByEmail(email) {
    try {
      const [rows] = await pool.execute(
        'SELECT * FROM users WHERE email = ?',
        [email]
      );
      
      return rows[0];
    } catch (error) {
      throw error;
    }
  }
  
  // Buscar usuário por ID
  static async findById(id) {
    try {
      const [rows] = await pool.execute(
        'SELECT id, name, email, created_at FROM users WHERE id = ?',
        [id]
      );
      
      return rows[0];
    } catch (error) {
      throw error;
    }
  }
  
  // Atualizar usuário
  static async update(id, userData) {
    const { name, email } = userData;
    
    try {
      await pool.execute(
        'UPDATE users SET name = ?, email = ? WHERE id = ?',
        [name, email, id]
      );
      
      return { id, name, email };
    } catch (error) {
      throw error;
    }
  }
  
  // Atualizar senha
  static async updatePassword(id, newPassword) {
    try {
      const saltRounds = 10;
      const hashedPassword = await bcrypt.hash(newPassword, saltRounds);
      
      await pool.execute(
        'UPDATE users SET password = ? WHERE id = ?',
        [hashedPassword, id]
      );
      
      return true;
    } catch (error) {
      throw error;
    }
  }
  
  // Verificar credenciais para login
  static async verifyCredentials(email, password) {
    try {
      const user = await this.findByEmail(email);
      
      if (!user) {
        return null;
      }
      
      const isPasswordValid = await bcrypt.compare(password, user.password);
      
      if (!isPasswordValid) {
        return null;
      }
      
      // Remover a senha antes de retornar o usuário
      const { password: _, ...userWithoutPassword } = user;
      return userWithoutPassword;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = User; 