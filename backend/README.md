# Moodly Backend

Backend da aplicação Moodly, um aplicativo para registro e acompanhamento do humor diário.

## Requisitos

- Node.js (v14+)
- MySQL (v8+)

## Configuração

1. Instale as dependências:
   ```
   npm install
   ```

2. Configure o arquivo `.env` com suas credenciais do MySQL:
   ```
   PORT=3000
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=sua_senha
   DB_NAME=moodly
   JWT_SECRET=sua_chave_secreta
   JWT_EXPIRES_IN=7d
   ```

3. Crie o banco de dados e as tabelas necessárias:
   - Abra o MySQL Workbench
   - Execute o script SQL localizado em `sql/schema.sql`

## Execução

Para iniciar o servidor em modo de desenvolvimento com recarga automática:
```
npm run dev
```

Para iniciar o servidor em produção:
```
npm start
```

## API Endpoints

### Autenticação

- `POST /api/auth/register` - Registrar novo usuário
- `POST /api/auth/login` - Login de usuário
- `GET /api/auth/profile` - Obter perfil do usuário (autenticação necessária)
- `PUT /api/auth/profile` - Atualizar perfil (autenticação necessária)
- `PUT /api/auth/password` - Atualizar senha (autenticação necessária)

### Registros de Humor

- `POST /api/mood-entries` - Criar novo registro de humor (autenticação necessária)
- `GET /api/mood-entries` - Listar registros de humor (autenticação necessária)
- `GET /api/mood-entries/:id` - Obter detalhes de um registro (autenticação necessária)
- `PUT /api/mood-entries/:id` - Atualizar um registro (autenticação necessária)
- `DELETE /api/mood-entries/:id` - Excluir um registro (autenticação necessária)
- `GET /api/mood-entries/stats` - Obter estatísticas de humor (autenticação necessária)

### Atividades

- `GET /api/activities` - Listar todas as atividades
- `GET /api/activities/user/common` - Listar atividades mais comuns do usuário (autenticação necessária)
- `POST /api/activities` - Criar nova atividade (autenticação necessária)
- `PUT /api/activities/:id` - Atualizar uma atividade (autenticação necessária)
- `DELETE /api/activities/:id` - Excluir uma atividade (autenticação necessária) 