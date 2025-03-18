-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS moodly CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE moodly;

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabela de registros de humor
CREATE TABLE IF NOT EXISTS mood_entries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  date DATETIME NOT NULL,
  mood VARCHAR(50) NOT NULL,
  mood_score INT NOT NULL CHECK (mood_score BETWEEN 1 AND 5),
  note TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Tabela de atividades
CREATE TABLE IF NOT EXISTS activities (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de relacionamento entre registros de humor e atividades
CREATE TABLE IF NOT EXISTS mood_entry_activities (
  id INT AUTO_INCREMENT PRIMARY KEY,
  mood_entry_id INT NOT NULL,
  activity_id INT NOT NULL,
  FOREIGN KEY (mood_entry_id) REFERENCES mood_entries(id) ON DELETE CASCADE,
  FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE,
  UNIQUE(mood_entry_id, activity_id)
);

-- Inserção de atividades padrão
INSERT IGNORE INTO activities (name) VALUES 
('Exercício'), 
('Leitura'), 
('Meditação'), 
('Trabalho'), 
('Estudo'), 
('Socialização'), 
('Descanso'), 
('Lazer'), 
('Família'), 
('Hobby'); 