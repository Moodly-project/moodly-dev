const { pool } = require('../config/db');

class Activity {
  // Listar todas as atividades
  static async findAll() {
    try {
      const [rows] = await pool.execute('SELECT * FROM activities ORDER BY name');
      return rows;
    } catch (error) {
      throw error;
    }
  }
  
  // Buscar atividade por ID
  static async findById(id) {
    try {
      const [rows] = await pool.execute('SELECT * FROM activities WHERE id = ?', [id]);
      return rows[0] || null;
    } catch (error) {
      throw error;
    }
  }
  
  // Buscar atividade por nome
  static async findByName(name) {
    try {
      const [rows] = await pool.execute('SELECT * FROM activities WHERE name = ?', [name]);
      return rows[0] || null;
    } catch (error) {
      throw error;
    }
  }
  
  // Criar uma nova atividade
  static async create(name) {
    try {
      const [result] = await pool.execute('INSERT INTO activities (name) VALUES (?)', [name]);
      return { id: result.insertId, name };
    } catch (error) {
      throw error;
    }
  }
  
  // Atualizar uma atividade
  static async update(id, name) {
    try {
      await pool.execute('UPDATE activities SET name = ? WHERE id = ?', [name, id]);
      return { id, name };
    } catch (error) {
      throw error;
    }
  }
  
  // Excluir uma atividade
  static async delete(id) {
    try {
      const [result] = await pool.execute('DELETE FROM activities WHERE id = ?', [id]);
      return result.affectedRows > 0;
    } catch (error) {
      throw error;
    }
  }
  
  // Buscar atividades mais comuns para um usuário
  static async findMostCommonForUser(userId, limit = 10) {
    try {
      const [rows] = await pool.execute(`
        SELECT a.id, a.name, COUNT(*) as count
        FROM activities a
        JOIN mood_entry_activities mea ON a.id = mea.activity_id
        JOIN mood_entries me ON mea.mood_entry_id = me.id
        WHERE me.user_id = ?
        GROUP BY a.id, a.name
        ORDER BY count DESC
        LIMIT ?
      `, [userId, limit]);
      
      return rows;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = Activity; 