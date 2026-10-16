# Jarvis no Docker/Linux (Portainer)

Esta configuração mantém o Hermes fora do container do Jarvis. O único acesso
publicado é a porta interna `8765` (`ws://<host>:8765/ws` e
`http://<host>:8765/health`); não requer DNS, Cloudflare, certificados ou
publicação externa.

## Dependências e entrypoint

- Imagem base: Python 3.11 slim.
- Dependências: `server/requirements.txt` (FastAPI, Uvicorn, RealtimeSTT,
  faster-whisper, silero-vad e clientes de integração).
- Entrypoint: `python /app/server.py`.
- Bind: `server/config/server.yaml`, por padrão `0.0.0.0:8765`.
- Healthcheck: `GET /health`, sem aquecer ou inicializar o modelo STT.

## Stack no Portainer

1. Crie no host os diretórios de configuração, dados e certificados:
   `JARVIS_CONFIG_DIR`, `JARVIS_DATA_DIR` e `JARVIS_CERTS_DIR`.
2. Copie `server/config/server.example.yaml` para
   `${JARVIS_CONFIG_DIR}/server.yaml` e preencha `hermes.base_url` e os
   parâmetros de voz. Não grave segredos no YAML.
3. Crie `${JARVIS_ENV_FILE}` com `API_SERVER_KEY`, `ELEVENLABS_API_KEY` e,
   se usado, `JARVIS_HUD_TOKEN`; proteja o arquivo no host.
4. No Portainer, **Stacks → Add stack**, forneça este arquivo como Compose e
   ajuste as variáveis de caminho no ambiente da stack. Faça o build/deploy.

O arquivo é `deploy/docker/compose.portainer.yml`. O volume de configuração é
somente leitura; logs e estado ficam em `${JARVIS_DATA_DIR}/logs`.

O contexto de build é a raiz do repositório. O `.dockerignore` exclui ambientes
locais (`server/.venv`, `server/.venv.partial`), caches, logs, certificados e
`server/config/server.yaml`; portanto, segredos e os ambientes virtuais do host
não são enviados ao daemon. A imagem instala apenas `server/requirements.txt`.

## Validação isolada

```bash
docker compose -f deploy/docker/compose.portainer.yml config
docker compose -f deploy/docker/compose.portainer.yml build jarvis
docker compose -f deploy/docker/compose.portainer.yml up -d jarvis
curl --fail http://127.0.0.1:8765/health
docker inspect --format '{{json .State.Health}}' jarvis-voice
docker compose -f deploy/docker/compose.portainer.yml down
```

O `restart: unless-stopped` reinicia o container após falha. Não execute
`up`, `down` ou publicação em ambiente produtivo sem autorização; os comandos
acima são apenas para um host isolado.

## Execução Linux sem Docker

```bash
cd server
./scripts/jarvis-start.sh
```

Em Linux com systemd o script inicia `jarvis-emporio.service`; em Docker ou
Linux mínimo ele executa o servidor em foreground, permitindo que o supervisor
faça o restart. No macOS, o caminho existente via `launchctl` permanece.