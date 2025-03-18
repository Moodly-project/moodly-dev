const Activity = require('../models/Activity');

// Obter todas as atividades
const getAllActivities = async (req, res) => {
  try {
    const activities = await Activity.findAll();
    res.status(200).json({ activities });
  } catch (error) {
    console.error('Erro ao obter atividades:', error);
    res.status(500).json({ message: 'Erro ao obter atividades.' });
  }
};

// Obter atividades mais usadas pelo usuário
const getMostCommonActivities = async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit } = req.query;
    
    const activities = await Activity.findMostCommonForUser(
      userId,
      limit ? parseInt(limit) : 10
    );
    
    res.status(200).json({ activities });
  } catch (error) {
    console.error('Erro ao obter atividades mais comuns:', error);
    res.status(500).json({ message: 'Erro ao obter atividades mais comuns.' });
  }
};

// Criar uma nova atividade
const createActivity = async (req, res) => {
  try {
    const { name } = req.body;
    
    // Verificar se a atividade já existe
    const existingActivity = await Activity.findByName(name);
    if (existingActivity) {
      return res.status(409).json({ 
        message: 'Esta atividade já existe.',
        activity: existingActivity
      });
    }
    
    const newActivity = await Activity.create(name);
    res.status(201).json({
      message: 'Atividade criada com sucesso!',
      activity: newActivity
    });
  } catch (error) {
    console.error('Erro ao criar atividade:', error);
    res.status(500).json({ message: 'Erro ao criar atividade.' });
  }
};

// Atualizar uma atividade
const updateActivity = async (req, res) => {
  try {
    const { id } = req.params;
    const { name } = req.body;
    
    // Verificar se a atividade existe
    const activity = await Activity.findById(id);
    if (!activity) {
      return res.status(404).json({ message: 'Atividade não encontrada.' });
    }
    
    // Verificar se o novo nome já existe
    if (name !== activity.name) {
      const existingActivity = await Activity.findByName(name);
      if (existingActivity) {
        return res.status(409).json({ message: 'Já existe uma atividade com este nome.' });
      }
    }
    
    const updatedActivity = await Activity.update(id, name);
    res.status(200).json({
      message: 'Atividade atualizada com sucesso!',
      activity: updatedActivity
    });
  } catch (error) {
    console.error('Erro ao atualizar atividade:', error);
    res.status(500).json({ message: 'Erro ao atualizar atividade.' });
  }
};

// Excluir uma atividade
const deleteActivity = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Verificar se a atividade existe
    const activity = await Activity.findById(id);
    if (!activity) {
      return res.status(404).json({ message: 'Atividade não encontrada.' });
    }
    
    await Activity.delete(id);
    res.status(200).json({ message: 'Atividade excluída com sucesso!' });
  } catch (error) {
    console.error('Erro ao excluir atividade:', error);
    res.status(500).json({ message: 'Erro ao excluir atividade.' });
  }
};

module.exports = {
  getAllActivities,
  getMostCommonActivities,
  createActivity,
  updateActivity,
  deleteActivity
};