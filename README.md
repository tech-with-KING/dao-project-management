# DAO Project Management Smart Contract

A decentralized project management system built on Stacks blockchain using Clarity smart contracts. This system enables DAOs to manage projects, contractors, and milestone-based payments with built-in voting mechanisms.

## 🎯 Features

- **Project Management**
  - Create and manage multiple projects
  - Assign contractors to projects
  - Set project budgets and milestone targets
  - Track project completion status

- **Milestone System**
  - Define multiple milestones per project
  - Set milestone-specific budgets
  - Track milestone completion status
  - Automated fund release upon milestone completion

- **Voting Mechanism**
  - Democratic milestone approval process
  - Configurable minimum vote threshold
  - Protection against double voting
  - Automated completion triggers

- **Security Features**
  - Role-based access control
  - Input validation for all parameters
  - Protected fund management
  - Safeguards against common attack vectors

## 📋 Technical Specifications

### Constants
```clarity
MAX-PROJECT-ID: u1000000
MAX-MILESTONE-ID: u100
MAX-MIN-VOTES: u100
```

### Data Structures

#### Projects Map
```clarity
{
    owner: principal,
    contractor: principal,
    total-milestones: uint,
    completed-milestones: uint,
    total-budget: uint,
    funds-released: uint,
    active: bool
}
```

#### Milestones Map
```clarity
{
    description: (string-ascii 256),
    amount: uint,
    completed: bool,
    votes: uint
}
```

## 🚀 Getting Started

### Prerequisites
- Clarinet installed on your system
- Basic understanding of Clarity and Stacks blockchain
- A Stacks wallet for contract deployment

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd dao-project-management
```

2. Install dependencies
```bash
clarinet install
```

3. Run tests
```bash
clarinet test
```

### Contract Deployment

1. Build the contract
```bash
clarinet build
```

2. Deploy using Clarinet console or Stacks deployer
```bash
clarinet deploy
```

## 📖 Usage Guide

### Creating a New Project

```clarity
(contract-call? 
    .dao-project-management 
    create-project 
    u1  ;; project-id
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM  ;; contractor
    u5  ;; total-milestones
    u1000000  ;; total-budget
)
```

### Adding a Milestone

```clarity
(contract-call?
    .dao-project-management
    add-milestone
    u1  ;; project-id
    u1  ;; milestone-id
    "Complete Frontend Development"  ;; description
    u200000  ;; amount
)
```

### Voting on Milestone Completion

```clarity
(contract-call?
    .dao-project-management
    vote-milestone-completion
    u1  ;; project-id
    u1  ;; milestone-id
)
```

## 🔒 Security Considerations

1. **Input Validation**
   - All user inputs are validated against predefined bounds
   - Project and milestone IDs are checked for uniqueness
   - Vote counts are protected against overflow

2. **Access Control**
   - Only contract owner can create projects
   - Only project owner can add milestones
   - Voting rights can be restricted to DAO members

3. **Fund Safety**
   - Milestone payments are released only after sufficient votes
   - Built-in checks prevent double-completion of milestones

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 Error Codes Reference

- `ERR-NOT-AUTHORIZED (u100)`: User not authorized for this action
- `ERR-INVALID-MILESTONE (u101)`: Invalid milestone ID or data
- `ERR-ALREADY-COMPLETED (u102)`: Milestone already completed
- `ERR-INSUFFICIENT-VOTES (u103)`: Not enough votes for completion
- `ERR-INVALID-PROJECT-ID (u104)`: Invalid project ID
- `ERR-INVALID-MILESTONE-ID (u105)`: Invalid milestone ID format
- `ERR-INVALID-MIN-VOTES (u106)`: Invalid minimum votes threshold

## 📝 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 🙏 Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Clarity language documentation and community
- DAO governance best practices research

## ⚠️ Disclaimer

This smart contract is provided as-is. Always audit smart contracts thoroughly before deployment and use in production environments.