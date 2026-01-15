# Système de Vote Décentralisé

Un système de vote sécurisé et transparent déployé sur la blockchain Ethereum (réseau de test Sepolia).

## 📋 Description

Ce projet implémente un système de vote décentralisé utilisant des smart contracts Solidity. Les votants reçoivent un NFT unique pour authentifier leur vote, garantissant ainsi la transparence et l'intégrité du processus de vote.

## 🚀 Déploiement sur Sepolia

### Contrats déployés

- **SimpleVotingSystem** : `0x110b0dc05b666265d66cfd03b3a6269acd3992ff`
- **VoteNFT** : `0x05b8804c0f84658e07f26df1e25280bca76f54e6`

### Transaction de déploiement

- Hash : `0x3445984a97cc8d89a6ec52720aa5249ed0e0e041e80f7ea5ba9741bbca076ab7`
- Lien Etherscan : https://sepolia.etherscan.io/tx/0x3445984a97cc8d89a6ec52720aa5249ed0e0e041e80f7ea5ba9741bbca076ab7

### Informations du réseau

- **Réseau** : Sepolia Testnet
- **Chain ID** : 11155111
- **Block** : 10049582
- **Déployeur** : `0xd0d3ecdc5e8a95f72a476416da485ab2bef8520a`

## 🛠️ Installation
```bash
# Cloner le repository
git clone [URL_DE_TON_REPO]

# Installer les dépendances
forge install
```

## 🧪 Tests
```bash
forge test
```

## 📝 Utilisation

Le système de vote permet de :
- Créer des propositions de vote
- Voter de manière sécurisée avec authentification NFT
- Consulter les résultats de manière transparente

## 🔧 Technologies utilisées

- **Solidity** ^0.8.26
- **Foundry** (Forge)
- **OpenZeppelin Contracts**
- **Ethereum (Sepolia Testnet)**

## 📄 Licence

MIT

---

*Développé avec Foundry et déployé sur Sepolia*