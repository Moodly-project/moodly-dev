const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { testConnection } = require('./config/db');

// Importando as rotas
const authRoutes = require('./routes/authRoutes');
const moodEntryRoutes = require('./routes/moodEntryRoutes');
const activityRoutes = require('./routes/activityRoutes');

// Carregar variáveis de ambiente
dotenv.config();

// Criar aplicação Express
const app = express();

// Configurar middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Definir rotas
app.use('/api/auth', authRoutes);
app.use('/api/mood-entries', moodEntryRoutes);
app.use('/api/activities', activityRoutes);

// Rota de teste
app.get('/', (req, res) => {
  res.json({ message: 'API Moodly está funcionando!' });
});

// Iniciar servidor
const PORT = process.env.PORT || 3000;

// Testar conexão com o banco de dados antes de iniciar o servidor
const startServer = async () => {
  try {
    // Tentar conectar ao banco de dados
    const dbConnected = await testConnection();
    
    if (!dbConnected) {
      console.error('❌ Não foi possível conectar ao banco de dados. Verifique as configurações e tente novamente.');
      process.exit(1);
    }
    
    app.listen(PORT, () => {
      console.log(`✅ Servidor rodando na porta ${PORT}`);
    });
  } catch (error) {
    console.error('❌ Erro ao iniciar servidor:', error);
    process.exit(1);
  }
};

startServer(); 