const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

// Criando pool de conexões com o MySQL
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'moodly',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Função para testar a conexão com o banco de dados
async function testConnection() {
  try {
    const connection = await pool.getConnection();
    console.log('✅ Conexão com o banco de dados estabelecida com sucesso!');
    connection.release();
    return true;
  } catch (error) {
    console.error('❌ Erro ao conectar com o banco de dados:', error.message);
    return false;
  }
}

module.exports = {
  pool,
  testConnection
}; 