# Stacks Wallet Connection Contracts

Repositório de contratos Clarity para o projeto Stacks Wallet Connection Labs.

## Contratos

### Tip Jar (`tip-jar.clar` e `tip-jar-v2.clar`)
Contrato para envio de tips em STX entre usuários.

**Funcionalidades:**
- Envio de tips com memo opcional
- Rastreamento de tips enviados e recebidos
- Estatísticas de tippers e recipients
- Ranking de top tippers

**Versão v2:**
- Lista de tippers para consulta facilitada
- Funções para buscar todos os tippers com estatísticas

### Gas Meter (`gas-meter.clar`)
Mini-game de ações pagas com pequenas taxas.

**Ações disponíveis:**
- `cast-spell`: 0.01 STX
- `upgrade`: 0.05 STX
- `claim-daily`: 0.02 STX

**Funcionalidades:**
- Execução de ações repetíveis
- Rastreamento de usuários e estatísticas
- Histórico de ações
- Leaderboard de usuários

### Raffle (`raffle.clar`)
Sistema de rifa/sorteio on-chain com alto engajamento.

**Funcionalidades:**
- Compra de tickets (0.01 STX por ticket)
- Fechamento de round e seleção de vencedor (admin)
- Histórico de rounds e vencedores
- Rastreamento de participantes e tickets
- Sistema de rounds múltiplos

**Funções principais:**
- `buy-ticket`: Comprar tickets para o round atual
- `close-and-pick-winner`: Fechar round e escolher vencedor (admin)
- `start-new-round`: Iniciar novo round (admin)
- `get-round-status`: Consultar status do round atual
- `get-participant-tickets`: Consultar tickets de um participante

### Quest System (`quest-system.clar`)
Sistema de missões/quests on-chain com sistema de pontos e níveis.

**Funcionalidades:**
- 3 tipos de quests: daily (0.01 STX), weekly (0.05 STX), special (0.02 STX)
- Sistema de cooldown para quests diárias e semanais
- Sistema de pontos e níveis (Quest Master Level)
- Histórico completo de quests completadas
- Leaderboard de usuários
- Reivindicação de recompensas (gera transação adicional)

**Funções principais:**
- `complete-daily-quest`: Completar quest diária
- `complete-weekly-quest`: Completar quest semanal
- `complete-special-quest`: Completar quest especial
- `claim-quest-reward`: Reivindicar recompensa
- `get-user-stats`: Consultar estatísticas do usuário
- `can-complete-daily-quest`: Verificar se pode completar quest diária
- `can-complete-weekly-quest`: Verificar se pode completar quest semanal

## Estrutura

```
.
├── contracts/          # Contratos Clarity
├── tests/             # Testes unitários
├── settings/          # Configurações de rede
├── Clarinet.toml      # Configuração do Clarinet
└── package.json       # Dependências e scripts
```

## Instalação

```bash
npm install
```

## Testes

```bash
npm test
```

## Verificação de Contratos

```bash
clarinet check
```

## Deploy

Os contratos estão deployados na mainnet:

- `tip-jar-v2`: `SP1RSWVNQ7TW839J8V22E9JBHTW6ZQXSNR67HTZE9.tip-jar-v2`
- `gas-meter`: `SP1RSWVNQ7TW839J8V22E9JBHTW6ZQXSNR67HTZE9.gas-meter`

