# Community Voting Contract - Phase 2

A comprehensive decentralized voting system built on Stacks blockchain with enhanced security features and token-weighted governance capabilities.

## 🚀 Features

### Core Voting System
- **Proposal Creation**: Community members can create proposals with customizable voting periods
- **Weighted Voting**: Support for voter weight assignments and token-based voting power
- **Secure Voting**: Prevents double voting and ensures voting period compliance
- **Proposal Execution**: Automatic execution based on quorum and approval thresholds
- **Vote Delegation**: Users can delegate their voting power to trusted representatives

### Security Enhancements
- **Access Control**: Role-based permissions for proposal creation and administration
- **Input Validation**: Comprehensive validation of all user inputs and state changes
- **Time-based Controls**: Enforced voting periods with start/end block validation
- **Emergency Controls**: Proposal cancellation capabilities for proposers and admins

### Token Integration
- **SIP-010 Compatibility**: Works with standard Stacks tokens
- **Token Locking**: Prevents vote manipulation through token transfers during voting
- **Delegation System**: Advanced vote delegation with power tracking

## 📁 Project Structure

```
community-voting-contract/
├── contracts/
│   ├── community-voting.clar     # Main voting contract
│   └── token-voting.clar         # Token-weighted voting extension
├── Clarinet.toml                 # Project configuration
└── README.md                     # This file
```

## 🔧 Installation & Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) >= 1.5.0
- Stacks wallet for testing

### Local Development
```bash
# Clone the repository
git clone <repository-url>
cd community-voting-contract

# Check contract syntax
clarinet check

# Run tests
clarinet test

# Start local development environment
clarinet integrate
```

## 📖 Usage Guide

### Creating a Proposal
```clarity
;; Create a new proposal with 1 week voting period
(contract-call? .community-voting create-proposal 
  "Upgrade community treasury allocation" 
  u1008)  ;; ~1 week in blocks
```

### Voting on Proposals
```clarity
;; Vote YES on proposal #1
(contract-call? .community-voting vote u1 true)

;; Vote NO on proposal #1  
(contract-call? .community-voting vote u1 false)
```

### Executing Approved Proposals
```clarity
;; Execute proposal after voting period ends
(contract-call? .community-voting execute-proposal u1)
```

### Token-Weighted Voting
```clarity
;; Lock tokens for voting power
(contract-call? .token-voting lock-tokens-for-voting 
  u1      ;; proposal-id
  u1000   ;; token amount
  'SP1234...TOKEN-CONTRACT)

;; Delegate voting power
(contract-call? .token-voting delegate-voting-power 'SP5678...DELEGATE)
```

## ⚙️ Configuration

### Key Parameters
- **Minimum Voting Period**: 144 blocks (~1 day)
- **Maximum Voting Period**: 1008 blocks (~1 week) 
- **Quorum Threshold**: 100 total votes required
- **Default Execution Threshold**: 60% approval required
- **Token Lock Period**: 1008 blocks (~1 week)

### Administrative Functions
```clarity
;; Set voter weights (admin only)
(contract-call? .community-voting set-voter-weight 'SP1234...USER u5)

;; Transfer contract ownership
(contract-call? .community-voting transfer-ownership 'SP5678...NEW-OWNER)

;; Configure governance token
(contract-call? .token-voting set-governance-token 'SP9999...TOKEN)
```

## 🔍 Contract Functions

### Read-Only Functions
| Function | Description |
|----------|-------------|
| `get-proposal` | Retrieve proposal details |
| `get-voter-weight` | Get voting weight for a user |
| `has-user-voted` | Check if user voted on proposal |
| `get-proposal-status` | Get current proposal status |
| `get-voting-power` | Get token-based voting power |

### Public Functions
| Function | Description |
|----------|-------------|
| `create-proposal` | Create new governance proposal |
| `vote` | Cast vote on active proposal |
| `execute-proposal` | Execute approved proposal |
| `cancel-proposal` | Cancel proposal (proposer/admin) |
| `delegate-voting-power` | Delegate votes to another user |
| `lock-tokens-for-voting` | Lock tokens for voting weight |

## 🛡️ Security Features

1. **Double Vote Prevention**: Users cannot vote twice on the same proposal
2. **Time Validation**: Voting only allowed during active periods
3. **Weight Verification**: Voting power validation before vote casting
4. **Access Control**: Role-based permissions for sensitive operations
5. **Input Sanitization**: Comprehensive validation of all inputs
6. **Emergency Controls**: Admin override capabilities for security

## 🧪 Testing

Run the test suite to verify contract functionality:
```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/community-voting-test.ts

# Check contract with analysis
clarinet check --enable-analysis
```

## 🚦 Deployment

### Testnet Deployment
```bash
# Deploy to Stacks testnet
clarinet deploy --network testnet

# Verify deployment
clarinet console --network testnet
```

### Mainnet Deployment
```bash
# Deploy to mainnet (ensure thorough testing first)
clarinet deploy --network mainnet
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📞 Support

For questions and support:
- Open an issue on GitHub
- Check the [Stacks documentation](https://docs.stacks.co/)
- Join the Stacks community Discord

## 🗺️ Roadmap

- [ ] Multi-signature proposal execution
- [ ] Proposal categories and templates  
- [ ] Integration with existing DAOs
- [ ] Mobile wallet compatibility
- [ ] Advanced analytics dashboard
- [ ] Cross-chain governance bridging

---

**Phase 2 Improvements:**
✅ Fixed voting logic bugs and validation issues  
✅ Added comprehensive security enhancements  
✅ Implemented token-weighted voting system  
✅ Added vote delegation functionality  
✅ Enhanced error handling and access controls  
✅ Updated project configuration and documentation
