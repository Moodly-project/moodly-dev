const MoodEntry = require('../models/MoodEntry');

// Criar uma nova entrada de humor
const createMoodEntry = async (req, res) => {
  try {
    const { date, mood, moodScore, note, activities } = req.body;
    const userId = req.user.id;
    
    const newEntry = await MoodEntry.create({
      userId,
      date,
      mood,
      moodScore,
      note,
      activities
    });
    
    res.status(201).json({
      message: 'Registro de humor criado com sucesso!',
      entry: newEntry
    });
  } catch (error) {
    console.error('Erro ao criar registro de humor:', error);
    res.status(500).json({ message: 'Erro ao criar registro de humor.' });
  }
};

// Obter todas as entradas de humor do usuário
const getMoodEntries = async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit, offset, startDate, endDate } = req.query;
    
    const options = {
      limit: limit ? parseInt(limit) : 100,
      offset: offset ? parseInt(offset) : 0
    };
    
    if (startDate) {
      options.startDate = new Date(startDate);
    }
    
    if (endDate) {
      options.endDate = new Date(endDate);
    }
    
    const entries = await MoodEntry.findByUserId(userId, options);
    
    res.status(200).json({
      count: entries.length,
      entries
    });
  } catch (error) {
    console.error('Erro ao obter registros de humor:', error);
    res.status(500).json({ message: 'Erro ao obter registros de humor.' });
  }
};

// Obter uma entrada de humor específica
const getMoodEntryById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    
    const entry = await MoodEntry.findById(id, userId);
    
    if (!entry) {
      return res.status(404).json({ message: 'Registro de humor não encontrado.' });
    }
    
    res.status(200).json({ entry });
  } catch (error) {
    console.error('Erro ao obter registro de humor:', error);
    res.status(500).json({ message: 'Erro ao obter registro de humor.' });
  }
};

// Atualizar uma entrada de humor
const updateMoodEntry = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const { date, mood, moodScore, note, activities } = req.body;
    
    const updatedEntry = await MoodEntry.update(id, userId, {
      date,
      mood,
      moodScore,
      note,
      activities
    });
    
    res.status(200).json({
      message: 'Registro de humor atualizado com sucesso!',
      entry: updatedEntry
    });
  } catch (error) {
    console.error('Erro ao atualizar registro de humor:', error);
    
    if (error.message === 'Entrada não encontrada ou não pertence ao usuário') {
      return res.status(404).json({ message: error.message });
    }
    
    res.status(500).json({ message: 'Erro ao atualizar registro de humor.' });
  }
};

// Excluir uma entrada de humor
const deleteMoodEntry = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    
    const deleted = await MoodEntry.delete(id, userId);
    
    if (!deleted) {
      return res.status(404).json({ message: 'Registro de humor não encontrado.' });
    }
    
    res.status(200).json({ message: 'Registro de humor excluído com sucesso!' });
  } catch (error) {
    console.error('Erro ao excluir registro de humor:', error);
    res.status(500).json({ message: 'Erro ao excluir registro de humor.' });
  }
};

// Obter estatísticas de humor
const getMoodStats = async (req, res) => {
  try {
    const userId = req.user.id;
    const { period } = req.query;
    
    const stats = await MoodEntry.getStats(userId, period);
    
    res.status(200).json({ stats });
  } catch (error) {
    console.error('Erro ao obter estatísticas de humor:', error);
    res.status(500).json({ message: 'Erro ao obter estatísticas de humor.' });
  }
};

module.exports = {
  createMoodEntry,
  getMoodEntries,
  getMoodEntryById,
  updateMoodEntry,
  deleteMoodEntry,
  getMoodStats
}; 