// Validação para registro de usuário
const validateUserRegistration = (req, res, next) => {
  const { name, email, password } = req.body;
  const errors = [];

  // Validar nome
  if (!name || name.trim() === '') {
    errors.push('Nome é obrigatório');
  } else if (name.length < 2) {
    errors.push('Nome deve ter pelo menos 2 caracteres');
  }

  // Validar email
  if (!email || email.trim() === '') {
    errors.push('Email é obrigatório');
  } else {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      errors.push('Email inválido');
    }
  }

  // Validar senha
  if (!password || password.trim() === '') {
    errors.push('Senha é obrigatória');
  } else if (password.length < 6) {
    errors.push('Senha deve ter pelo menos 6 caracteres');
  }

  // Retornar erros se houver
  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }

  next();
};

// Validação para login
const validateLogin = (req, res, next) => {
  const { email, password } = req.body;
  const errors = [];

  // Validar email
  if (!email || email.trim() === '') {
    errors.push('Email é obrigatório');
  }

  // Validar senha
  if (!password || password.trim() === '') {
    errors.push('Senha é obrigatória');
  }

  // Retornar erros se houver
  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }

  next();
};

// Validação para entrada de humor
const validateMoodEntry = (req, res, next) => {
  const { date, mood, moodScore, note, activities } = req.body;
  const errors = [];

  // Validar data
  if (!date) {
    errors.push('Data é obrigatória');
  } else {
    const dateObj = new Date(date);
    if (isNaN(dateObj.getTime())) {
      errors.push('Data inválida');
    }
  }

  // Validar humor
  if (!mood || mood.trim() === '') {
    errors.push('Humor é obrigatório');
  }

  // Validar pontuação de humor
  if (moodScore === undefined || moodScore === null) {
    errors.push('Pontuação de humor é obrigatória');
  } else if (!Number.isInteger(moodScore) || moodScore < 1 || moodScore > 5) {
    errors.push('Pontuação de humor deve ser um número inteiro entre 1 e 5');
  }

  // Validar atividades (opcional)
  if (activities && !Array.isArray(activities)) {
    errors.push('Atividades deve ser um array');
  }

  // Retornar erros se houver
  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }

  next();
};

module.exports = {
  validateUserRegistration,
  validateLogin,
  validateMoodEntry
}; 