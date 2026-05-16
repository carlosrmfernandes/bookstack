# BookStack — Docker

Stack do BookStack rodando em Docker, com banco MySQL externo configurável via `.env`.

## Estrutura

```
.
├── docker-compose.yml          # serviço bookstack (app)
├── docker-compose.mysql.yml    # MySQL local para desenvolvimento/teste
├── .env.example                # template das variáveis
├── custom-cont-init.d/
│   └── 10-apply-env.sh         # injeta variáveis do .env no .env interno do BookStack
└── bookstack_data/             # gerado em runtime: uploads, themes, .env interno (ignorado pelo git)
```

## Primeiro uso

1. **Copie o template do `.env`:**
   ```powershell
   Copy-Item .env.example .env
   ```

2. **Gere uma `APP_KEY`** e cole no `.env`:
   ```powershell
   docker run --rm --entrypoint /bin/bash lscr.io/linuxserver/bookstack:latest appkey
   ```

3. **Configure o banco** no `.env`:
   - **Para usar o MySQL local incluído** (`docker-compose.mysql.yml`): mantenha os valores padrão
     (`DB_HOST=host.docker.internal`, `DB_PORT=3307`, etc).
   - **Para usar um MySQL externo**: ajuste `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`.

4. **Suba os containers:**
   ```powershell
   # Se for usar o MySQL local
   docker compose -f docker-compose.mysql.yml up -d

   # BookStack
   docker compose up -d
   ```

5. **Acesse** http://localhost:6875
   Login inicial: `admin@admin.com` / `password`

## Operação

```powershell
# Logs do app
docker logs -f bookstack

# Recriar o app (após mudar .env)
docker compose up -d --force-recreate bookstack

# Parar tudo
docker compose down
docker compose -f docker-compose.mysql.yml down

# Atualizar para a imagem mais recente do BookStack
docker compose pull
docker compose up -d
```

As migrações do banco rodam automaticamente em cada start (Laravel `artisan migrate --force`),
então atualizações de versão se aplicam sozinhas.

## Requisitos do banco externo

- MySQL **8.0+** ou MariaDB **10.6+** (PostgreSQL **não** é suportado pelo BookStack)
- Charset/collation: `utf8mb4` / `utf8mb4_unicode_ci`
- Usuário com `ALL PRIVILEGES` na database alvo
- Firewall permitindo conexão TCP na porta do MySQL a partir do host que roda o Docker
