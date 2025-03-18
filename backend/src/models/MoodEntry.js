const { pool } = require('../config/db');

class MoodEntry {
  // Criar uma nova entrada de humor
  static async create(entryData) {
    const { userId, date, mood, moodScore, note, activities = [] } = entryData;
    
    try {
      // Iniciar transação
      const connection = await pool.getConnection();
      await connection.beginTransaction();
      
      try {
        // Inserir entrada de humor
        const [result] = await connection.execute(
          'INSERT INTO mood_entries (user_id, date, mood, mood_score, note) VALUES (?, ?, ?, ?, ?)',
          [userId, date, mood, moodScore, note]
        );
        
        const moodEntryId = result.insertId;
        
        // Inserir atividades relacionadas
        if (activities.length > 0) {
          // Garantir que todas as atividades existem
          for (const activityName of activities) {
            await connection.execute(
              'INSERT IGNORE INTO activities (name) VALUES (?)',
              [activityName]
            );
            
            // Obter ID da atividade
            const [activityRows] = await connection.execute(
              'SELECT id FROM activities WHERE name = ?',
              [activityName]
            );
            
            if (activityRows.length > 0) {
              const activityId = activityRows[0].id;
              
              // Relacionar atividade com a entrada de humor
              await connection.execute(
                'INSERT INTO mood_entry_activities (mood_entry_id, activity_id) VALUES (?, ?)',
                [moodEntryId, activityId]
              );
            }
          }
        }
        
        // Confirmar transação
        await connection.commit();
        connection.release();
        
        return {
          id: moodEntryId,
          userId,
          date,
          mood,
          moodScore,
          note,
          activities
        };
      } catch (error) {
        // Reverter transação em caso de erro
        await connection.rollback();
        connection.release();
        throw error;
      }
    } catch (error) {
      throw error;
    }
  }
  
  // Buscar entradas de humor de um usuário
  static async findByUserId(userId, options = {}) {
    const { limit = 100, offset = 0, startDate, endDate } = options;
    
    try {
      let query = `
        SELECT me.*, GROUP_CONCAT(a.name) as activity_names
        FROM mood_entries me
        LEFT JOIN mood_entry_activities mea ON me.id = mea.mood_entry_id
        LEFT JOIN activities a ON mea.activity_id = a.id
        WHERE me.user_id = ?
      `;
      
      const params = [userId];
      
      if (startDate) {
        query += ' AND me.date >= ?';
        params.push(startDate);
      }
      
      if (endDate) {
        query += ' AND me.date <= ?';
        params.push(endDate);
      }
      
      query += ' GROUP BY me.id ORDER BY me.date DESC LIMIT ? OFFSET ?';
      params.push(limit, offset);
      
      const [rows] = await pool.execute(query, params);
      
      return rows.map(row => {
        const activities = row.activity_names 
          ? row.activity_names.split(',') 
          : [];
          
        const { activity_names, ...entryData } = row;
        
        return {
          ...entryData,
          activities
        };
      });
    } catch (error) {
      throw error;
    }
  }
  
  // Buscar uma entrada de humor por ID
  static async findById(id, userId) {
    try {
      const [rows] = await pool.execute(`
        SELECT me.*, GROUP_CONCAT(a.name) as activity_names
        FROM mood_entries me
        LEFT JOIN mood_entry_activities mea ON me.id = mea.mood_entry_id
        LEFT JOIN activities a ON mea.activity_id = a.id
        WHERE me.id = ? AND me.user_id = ?
        GROUP BY me.id
      `, [id, userId]);
      
      if (rows.length === 0) {
        return null;
      }
      
      const activities = rows[0].activity_names 
        ? rows[0].activity_names.split(',') 
        : [];
        
      const { activity_names, ...entryData } = rows[0];
      
      return {
        ...entryData,
        activities
      };
    } catch (error) {
      throw error;
    }
  }
  
  // Atualizar uma entrada de humor
  static async update(id, userId, entryData) {
    const { date, mood, moodScore, note, activities = [] } = entryData;
    
    try {
      // Iniciar transação
      const connection = await pool.getConnection();
      await connection.beginTransaction();
      
      try {
        // Verificar se a entrada pertence ao usuário
        const [rows] = await connection.execute(
          'SELECT id FROM mood_entries WHERE id = ? AND user_id = ?',
          [id, userId]
        );
        
        if (rows.length === 0) {
          throw new Error('Entrada não encontrada ou não pertence ao usuário');
        }
        
        // Atualizar entrada de humor
        await connection.execute(
          'UPDATE mood_entries SET date = ?, mood = ?, mood_score = ?, note = ? WHERE id = ?',
          [date, mood, moodScore, note, id]
        );
        
        // Remover todas as atividades relacionadas
        await connection.execute(
          'DELETE FROM mood_entry_activities WHERE mood_entry_id = ?',
          [id]
        );
        
        // Inserir atividades atualizadas
        if (activities.length > 0) {
          for (const activityName of activities) {
            await connection.execute(
              'INSERT IGNORE INTO activities (name) VALUES (?)',
              [activityName]
            );
            
            const [activityRows] = await connection.execute(
              'SELECT id FROM activities WHERE name = ?',
              [activityName]
            );
            
            if (activityRows.length > 0) {
              const activityId = activityRows[0].id;
              
              await connection.execute(
                'INSERT INTO mood_entry_activities (mood_entry_id, activity_id) VALUES (?, ?)',
                [id, activityId]
              );
            }
          }
        }
        
        // Confirmar transação
        await connection.commit();
        connection.release();
        
        return {
          id,
          userId,
          date,
          mood,
          moodScore,
          note,
          activities
        };
      } catch (error) {
        // Reverter transação em caso de erro
        await connection.rollback();
        connection.release();
        throw error;
      }
    } catch (error) {
      throw error;
    }
  }
  
  // Excluir uma entrada de humor
  static async delete(id, userId) {
    try {
      const [result] = await pool.execute(
        'DELETE FROM mood_entries WHERE id = ? AND user_id = ?',
        [id, userId]
      );
      
      return result.affectedRows > 0;
    } catch (error) {
      throw error;
    }
  }
  
  // Obter estatísticas de humor por período
  static async getStats(userId, period = 'month') {
    try {
      let dateFilter;
      
      switch (period) {
        case 'week':
          dateFilter = 'AND date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)';
          break;
        case 'month':
          dateFilter = 'AND date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)';
          break;
        case 'year':
          dateFilter = 'AND date >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)';
          break;
        default:
          dateFilter = '';
      }
      
      const [rows] = await pool.execute(`
        SELECT 
          mood, 
          mood_score, 
          COUNT(*) as count,
          AVG(mood_score) as average_score
        FROM mood_entries
        WHERE user_id = ? ${dateFilter}
        GROUP BY mood, mood_score
        ORDER BY count DESC
      `, [userId]);
      
      return rows;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = MoodEntry; 