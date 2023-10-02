# ethereum-gas-fee-workshop

* references
    * https://www.oreilly.com/library/view/hands-on-smart-contract/9781492045250/
    * https://www.amazon.com/Solidity-Programming-Essentials-building-contracts/dp/1803231181
    * https://www.amazon.com/Beginning-Ethereum-Smart-Contracts-Programming/dp/1484292707
    * https://www.springerprofessional.de/en/ethereum-smart-contract-development-in-solidity/18334966
    * https://www.manning.com/books/blockchain-in-action
    * https://www.packtpub.com/product/mastering-blockchain-programming-with-solidity/9781839218262
    * https://ethereum.stackexchange.com/questions/594/how-do-gas-refunds-work
    * https://ethereum.stackexchange.com/questions/92965/how-are-gas-refunds-payed
    * https://ethereum.stackexchange.com/questions/125028/is-there-still-gas-refund-for-sstore-to-0-instructions
    * https://ethereum.stackexchange.com/questions/3/what-is-meant-by-the-term-gas
    * https://ethereum.stackexchange.com/questions/872/what-is-the-cost-to-store-1kb-10kb-100kb-worth-of-data-into-the-ethereum-block
    * https://medium.com/@eiki1212/what-is-ethereum-gas-simple-explanation-2f0ae62ed69c
    * https://ethereum.stackexchange.com/questions/133284/how-to-see-the-refund-of-selfdestruct
    * https://ethereum.stackexchange.com/questions/15114/if-all-nodes-execute-smart-contracts-why-do-only-block-creators-get-the-gas-fee
    * https://www.blocknative.com/blog/ethereum-transaction-gas-limit
    * https://medium.com/coinmonks/a-short-guide-to-ethereum-gas-fees-5c4c53a05feb
    * https://help.coinbase.com/en/coinbase/getting-started/crypto-education/eip-1559
    * https://medium.com/monolith/understanding-defi-ethereums-eip-1559-update-explained-a424416cbf69
    * https://medium.com/@eric.conner/fixing-the-ethereum-fee-market-eip-1559-9109f1c1814b
    * https://medium.com/@TrustlessState/eip-1559-the-final-puzzle-piece-to-ethereums-monetary-policy-58802ab28a27
    * https://consensys.net/blog/quorum/what-is-eip-1559-how-will-it-change-ethereum/
    * https://medium.com/coinmonks/learn-evm-in-depth-1-the-evm-bytecode-and-environment-b751c431f020
    * https://ethereum.org/en/developers/docs/evm/
    * https://blog.qtum.org/the-ethereum-virtual-machine-def21fdc8953
    * https://medium.com/@danielyamagata/understand-evm-opcodes-write-better-smart-contracts-e64f017b619
    * https://www.cryptopolitan.com/solidity-gas-optimization-strategies/
    * https://www.alchemy.com/overviews/solidity-gas-optimization
    * https://certik.medium.com/gas-optimization-in-ethereum-smart-contracts-10-best-practices-cbd57548bdf0
    * https://yamenmerhi.medium.com/gas-optimization-in-solidity-75945e12322f
    * https://betterprogramming.pub/solidity-gas-optimizations-and-tricks-2bcee0f9f1f2
    * https://www.rareskills.io/post/gas-optimization
    * https://coinsbench.com/comprehensive-guide-tips-and-tricks-for-gas-optimization-in-solidity-5380db734404
    * https://ethereum.stackexchange.com/questions/7949/why-do-constant-state-variables-get-initialised-every-time
    * https://ethereum.stackexchange.com/questions/141988/can-gas-refunds-for-deleted-storage-be-used-as-transient-storage
    * https://ethereum.stackexchange.com/questions/68529/solidity-modifiers-in-library
    * https://medium.com/@Ground_Zero/ethereum-l2-solutions-vs-rollups-understanding-the-difference-a93f5108bac5
    * https://medium.com/@0xegormajj/layer-2-ethereum-scaling-solutions-for-a-faster-and-more-efficient-network-9b1e9fea775e
    * https://kbaiiitmk.medium.com/scaling-the-ethereum-using-rollups-layer-2-a9b488ca2fe
    * https://medium.com/@amdeviprasad/exploring-layer-2-solutions-from-plasma-framework-to-rollups-df4a9647f587
    * https://medium.com/coinmonks/zk-rollup-optimistic-rollup-70c01295231b
    * https://medium.com/ppio/zk-rollup-making-scalable-blockchains-possible-7308b695d929
    * https://medium.com/taipei-ethereum-meetup/reason-why-you-should-use-eip1167-proxy-contract-with-tutorial-cbb776d98e53

## preface
* goals of this workshop
    * understanding
* workshop task
    * improve `Inefficient.sol`
        1. replace `compareStrings` with `keccak256`
        1. use correct qualifiers: view, calldata, etc
        1. use correct data structure: mapping

## EVM = Ethereum Virtual Machine
* refresh: virtual machine
    * is a type of simulation of a CPU
    * has predefined operations, but such operations must be understood by the virtual machine and not by the CPU
    * is a program capable of interpreting a specific language
        * transforming (indirectly) this language into machine language
        * executing what needs to be executed on the CPU.
    * language that the virtual machine understands is called bytecode
        * each virtual machine has its own bytecode with its own definitions
        * bytecode is a series of instructions that the EVM will interpret and execute
        * when we write a smart contract in Solidity or Vyper, the result must be transformed (compiled) to bytecode
        * EVM bytecode is not machine language
            * although it looks like a set of bits, it is only a representation
* Ethereum is like a single-threaded computer
    * it can process one transaction at a time
    * Sharding of blockchain would improve it and make it like a multithreaded computer
* virtual, isolated environment where code (smart contracts) can be executed
    * running on the EVM is not directly executed by any single computer, but by all nodes in the Ethereum network
    * you can think of JVM(Java Virtual Machine) as the same mechanism
* is Turing complete
    * contracts contain very little code and their methods require very few instructions to execute
        * usually less than one thousand
        * regular computers execute several billion instructions per second
    * to prevent infinite loops and resource exhaustion, the EVM requires users to pay for computation and storage
        * Ethereum Virtual Machine is seen only as quasi-Turing complete
        * payment is made in the form of "gas"
            * a unit of measurement for the amount of computational work required to execute operations
        * since the London hard fork, each block has a target size of 15 million units of gas
            * the actual size of a block will vary depending on network demand
                * protocol achieves an equilibrium block size of 15 million on average through the process of tâtonnement
                * if the block size is greater than the target block size, the protocol will increase the base fee for the following block
                * the protocol will decrease the base fee if the block size is less than the target block size
                * maximum size: 30 million gas (2x the target block size)
                    * means that a block can only contain transactions which cost 30m gas to execute
        * example
            * 3m gas is at maximum 1.5 million instructions (in a very theoretical, unrealistic scenario)
                * example
                    * MSTORE (Memory Store): around 3 gas
                    * SSTORE (Storage Operation):
                        * writing to a new storage slot: Around 20,000 gas (for a 256 bit word)
                            * a kilobyte is thus 640k gas
                                * so if gas ~ 10 gwei
                                * 1KB costs 0.0064 ETH
                                * 1GB costs 6400 eth (for eth 1.5k USD, ~ 12,000,000 USD)
                            * so a block can only contain instructions that write to storage about 150 times
                        * updating an existing storage slot: Around 5,000 gas
                    * SLOAD (Storage Load): around 200 gas
* is deterministic
    * running the same code with the same inputs will produce the same results every time
* is a stack-based machine
* operates using a set of instructions called "opcodes"
    * opcodes are predefined instructions that the EVM interprets
    * some operators have operands, but not all
        * operator that have operand: PUSH
            * push to the stack
        * operator that does not have: ADD
            * takes from the stack, add and push result
    * example
        ```
        // Solidity code
        function addIntsInMemory(uint a, uint b) public pure returns (uint) {
            uint result = a + b;
            return result;
        }
        ```
        is compiled into operands and operators (opcodes)
        ```
        PUSH1 0x20      // Load the memory slot size (32 bytes)
        MLOAD           // Load 'a' from memory
        PUSH1 0x40      // Load the memory slot size (32 bytes)
        ADD             // Add 'a' and 'b'
        MSTORE          // Store the result back in memory
        ```
    * then it is interpreted to bytecode
* bytecode is a set of bytes that must be executed in order, from left to right
    * each byte can be
        * an operator (represented by a single byte)
        * a complete operand
        * part of an operand (operands can have more than just 1 byte)
            * example: `PUSH20` - used to push a 20-byte (160-bit) value onto the stack
    * example
        * `ADD` opcode is represented as `0x01`
        * `PUSH1` opcode is represented as `60` and expects a 1-byte operand
        * bytecode to analyse: `0x6001600201` -> `60 01 60 02 01`
        * byte `60` is the `PUSH1` opcode
            * adds a byte to the Stack
            * The `PUSH1` opcode is an operator that expects a 1-byte operand
            * Then the complete statement is `60 01`
        * `60 02` // similar
        * final result: number 3 on the Stack
        * digression
            * byte 01 was used both as an operand and operator
            * it’s easy to figure out what it represents in the context of how it was used
    * you cannot generate the exact original Solidity source code from the EVM bytecode
        * process of compiling involves
            * optimizations
            * transformations
            * and potentially even loss of information
                * example
                    * during complication the function names and their input parameters are hashed to generate the function selectors
                    * to compute function selector
                        1. concatenate the function name and parameter types without spaces or commas: `myFunction(uint256,address)``
                        1. calculate the keccak-256 (sha3) hash of the concatenated string
                        1. take the first 4 bytes of the hash
* can be described as a global decentralized state machine
    * more than a distributed ledger
        * analogy of a 'distributed ledger' is often used to describe blockchains like Bitcoin
            * ledger maintains a record of activity which must adhere to a set of rules that govern what someone can and cannot do to modify the ledger
                * example: Bitcoin address cannot spend more Bitcoin than it has previously received
                * Ethereum has its own native cryptocurrency (Ether) that follows almost exactly the same intuitive rules
        * it enables a much more powerful function: smart contracts
    * state = the current state of all accounts and smart contracts on the blockchain
        * includes things like account balances, contract storage, and contract code
    * each transaction on a blockchain is a transition of state
    * EVM is the engine that processes transactions and executes the corresponding smart contract code
        * leads to state changes
        * at any given block in the chain, Ethereum has one and only one 'canonical' state
            * EVM is what defines the rules for computing a new valid state from block to block

## gas
* is a measure of computational work required to execute operations or transactions on the network
    * opcodes have a base gas cost used to pay for executing the transaction
        * example: KECCAK256
            * cost: 30 + 6 for every 256 bits of data being hashed
    * there isn't any actual token for gas
        * example: you can't own 1000 gas
        * exists only inside of the Ethereum virtual machine as a count of how much work is being performed
* is the fee paid for executing transactions on the Ethereum blockchain
    * example
        * simple transaction of moving ETH between two addresses
        * we know that this transaction requires 21,000 units
        * base fee for standard speed at the moment of writing is 20 gwei
        * gas fee = gas units (limit) * gas price per unit (in gwei)
        * 21,000 * 20 = 420,000 gwei
        * 420,000 gwei is 0.00042 ETH, which is at the current prices 0.63 USD (1 ETH = $1500)
* gas prices change constantly and there are a number of websites where you can check the current price
    * https://etherscan.io/gastracker
* if Ether (ETH) was directly used as the unit of transaction cost instead of gas, it would lead to several potential problems:
    * reduced flexibility
        * gas allows for adjustments to the cost of computation without affecting the underlying value of Ether
        * if Ether were used directly
            * any change in pricing would directly impact the value of the cryptocurrency
            * it would be difficult to prevent attackers from flooding the network with low-cost transactions
            * cost of computation should not go up or down just because the price of ether changes
                * it's helpful to separate out the price of computation from the price of the ether token
    * difficulty in predictability
        * Ether's value can be volatile, which means that transaction costs would fluctuate with the market price
        * this could lead to unpredictable costs for users and could make it more challenging to budget for transactions
* is used to
    * prevent infinite loops
    * computational resource exhaustion
    * prioritize transactions on the network
    * prevent Sybil attacks
        * by discouraging the creation of a large number of malicious identities
        * solution: prevents an attacker from overwhelming the network with a massive number of transactions
            * as each transaction costs some amount of gas
    * solve halting problem
        * problem = it's generally impossible to determine whether that program will eventually halt or continue running indefinitely
        * solution: program will eventually run out of gas and the transaction will be reverted
* gas has a price, denominated in ether (ETH)
    * users set the gas price they are willing to pay to have their transaction or smart contract executed
    * miners prioritize transactions with higher gas prices because they earn the fees associated with the gas
    * analogy
        * gas price as the hourly wage for the miner
        * gas cost as their timesheet of work performed
* every operation consumes a certain amount of gas
    * is paid by users to compensate miners for the computational work they perform
    * total gas fee = gas used * gas price
* each block has a gas limit
    * maximum amount of gas that can be consumed in a block
    * transaction sender is refunded the difference between the max fee and the sum of the base fee and tip
* some operations can result in a gas refund
    * example: if a smart contract deletes a storage slot, it gets a gas refund
        * digression
            * London Upgrade through EIP-3529: remove gas refunds for `SELFDESTRUCT`, and reduce gas refunds for `SSTORE` to a lower level
            * practically speaking gas refunds for selfdestruct was not encouraging the freeing up of network space
                * was encouraging the speculation on gas prices (in an extremely inefficient manner) via GAS tokens
                * was filling the blockchain with space-consuming gastokens and transactions just to get some cheap gas back
                * example
                    1. during a period of lower gas prices you deploy contractA (called usually GasToken)
                    1. during gas prices spike you'd self-destruct contractA and receive gas refund
                    1. you can use that gas refund for paying for transaction during spike
    * refund is only applied at the end of the transaction
        * the full gas must be made available in order to execute the full transaction
* it's important to estimate the gas needed for a transaction or smart contract execution
    * if too small => the operation will be reverted and any state changes will be discarded
        * miner still includes it in the blockchain as a "failed transaction", collecting the fees for it
            * sender still pays for the gas consumed up to that point
            * the real work for the miner was in performing the computation
                * they will never get those resources back either
                * it's only fair that you pay them for the work they did, even though your badly designed transaction ran out of gas
    * if too big => the excess gas is refunded (refund = max fee - base fee + tip)
        * max fee (maxFeePerGas)
            * maximum limit to pay for their transaction to be executed
            * must exceed the sum of the base fee and the tip
        * providing too big of a fee is also different than providing too much ether
            * if you set a very high gas price, you will end up paying lots of ether for only a few operations
                * similar to super high transaction fee in bitcoin
            * if you provided a normal gas price, however, and just attached more ether than was needed to pay for the gas that your transaction consumed
                * excess amount will be refunded back to you
                * miners only charge you for the work that they actually do
* EIP-1559
    * implemented in the London Hard Fork upgrade
    * went live in August 2021
    * introduces a new fee structure that separates transaction fees
        * NOT designed to lower gas fees but to make them more transparent and predictable
        * two components
            * base fee
                * minimum fee required to include a transaction in a block
                * determined by network congestion
                    * example
                        * when the network is busy, the base fee increases
                        * when it's less congested, the base fee decreases
                    * increase/decrease is predictable and will be the same for all users
                    * removing the need for each and every wallets to generate their own individual gas estimation strategies
                * is burned
                    * removed from circulation
                    * reducing the overall supply of Ether
                    * miners have less control over manipulating transaction fees
                        * no reason into bumping base price by putting load on the network
                    * benefits all Ether holders equally, rather than exclusively benefiting validators
                        * creates what EIP-1559 coordinator Tim Beiko refers to as an “ETH buyback” mechanism
                        * ETH is paid back to the protocol and the supply gets reduced
            * priority fee
                * optional tip to incentivize miners to include their transaction in the next block
                * goes directly to the miner
    * similar to a delivery service
        * lower fee for regular delivery or a higher fee for express delivery
        * during busy times, like the holiday season, the delivery service may increase the standard delivery fee
            * increase will be set by the delivery company and will affect all customers equally
    * comparable to Bitcoin’s difficulty adjustment
    * oracles might run into issues under EIP-1559 during periods of high congestion
        * oracles are used when you require off-chain data
            * example: Oraclize or ChainLink
        * they need to provide the pricing information for nearly all of DeFi
            * example: in lending protocols, it influences interest rates and collateral ratios
        * might end up paying incredibly high fees in order to ensure the pricing information reaches the DeFi application in a timely manner
    * context: original Ethereum gas fee system
        * simple auction system: unpredictable and inefficient
            * users bid a random amount of money to pay for each transaction
                * we can see a large divergence of transaction fees paid by different users in a single block
                    * many users often overpay by more than 5x
                    * example
                        ![alt text](img/pre_eip1559_overpay.png)
            * when the network becomes busy, this system causes gas fees to become high and unpredictable
            * not easy to quick-fix
                * possible improvement: users submit bids as normal, then everyone pays only the lowest bid that was included in the block
                    * can be easily gamed by miners who will fill up their own blocks in order to increase the minimum fee
                    * gameable by transaction senders who collude with miners
        * similar to the way ride-sharing services calculate ride fees
            * when demand for rides is higher, prices go up for everyone who wants a ride
        * problem: Ethereum network becomes busy
            * example
                * CryptoKitty users have reached in excess of 1.5 million(25% of total Ethereal traffic in peak times)
                * trade on a new decentralized cryptocurrency exchange
            * result: users trying to push their transactions by paying absurdly high gas fees
                * gas fees become unpredictable
                * users must guess how much to pay for a transaction
        * as Ethereum has gained new users, the network has become more congested
            * gas fees have become more volatile
            * many users have inadvertently overpaid for their transactions

## solidity
1. minimize on-chain data
    * storage operations are over 100x more costly than memory operations
        * OPcodes `mload` and `mstore` only cost `3` gas units while storage operations
        * `sload` and `sstore` cost at least 100 units
    * keep all data off-chain
        * save the smart contract’s critical info on-chain
        * save part of the system (metadata, etc .. ) on a centralized server
    * data that does not need to be accessed on-chain can be stored in events
1. minimize storage read/writes
    * save intermediate results in memory and assign results to storage after all calculations
    * caching the length in for loops
        * reading array length at each iteration of the loop takes 6 gas
            * 3 for mload and 3 to place memory_offset in the stack.
        * caching the array length in the stack saves around 3 gas per iteration
            * storage => extra sload operation
                * 100 additional extra gas (EIP-2929) for each iteration except for the first
            * memory => extra mload operation
                * 3 additional gas for each iteration except for the first
            * calldata => extra calldataload operation
                * 3 additional gas for each iteration except for the first) These
            * extra costs can be avoided by caching the array length (in the stack)
                ```
                uint _length = arr.length
                ```
1. use storage pointers instead of memory
    * example
        ```
        mapping(uint256 => User) public users;
        User storage _user = users[_id];
        ```
        is cheaper
        ```
        mapping(uint256 => User) public users;
        User memory _user = users[_id]; // involves copying
        ```
1. use calldata instead of memory
    * more cost-effective to load them immediately from calldata
        * does not require copying variables to memory
1. avoid loops
    * it consumes a lot of gas
    * it can prevent contract from being carried out beyond the block gas limit
    * use mappings
        * except when iteration is required or it is possible to pack data types (arrays are iterable and packable)
1. minimize the number of storage slots used
    * gas cost for storage usage is calculated based on the number of storage slots used
    * each storage slot has a size of 256 bits
    * you can pack multiple variables within a single storage slot
1. use 256 byte types
    * example: `uint256`
    * EVM performs operations in 256-bit chunks
        * using uint8 means the EVM has to first convert it to uint256
        * conversion costs extra gas
1. get gas refund for free up storage
    * has the same effect as reassigning the value type with its default value
    * mappings are unaffected by deletion
        * slots of values are random (based on key hash) and generally unknown
1. use immutable and constant
    * evaluated at compile-time and are stored in the bytecode of the contract
1. enable the Compiler Optimizer
    * several optimization tools available: solc optimizer, Truffle’s build optimizer, and Remix’s Solidity compiler
1. use short circuit rule
    * disjunction: if the first function evaluates to true, the second function is not executed
    * conjunction: if the first function evaluates to false, the second function is skipped entirely
1. move the modifiers require statements into an internal virtual function
    * modifier code is substituted by compiler to every method that uses this modifier
    * example
        ```
        modifier onlyOwner() {
            require(msg.sender == owner, "Only owner can call this function");
            _;
        }
        ```
        into
        ```
        modifier onlyOwner() {
            _onlyOwner();
            _;

        function _onlyOwner() private {
            require(msg.sender == owner, "Only owner can call this function");
        }
        ```
1. use Libraries
    * extract common functions into a single library and then deploy this library just once
1. use layer 2 solutions
    * works by creating a network of payment channels on top of a blockchain network
    * enable offloading of transaction processing from the main Ethereum chain
    * solutions
        * rollups
            * transactions occur off-chain on the rollup chain itself
                * only a summary or commitment of the transactions is recorded on the Ethereum mainnet
                    * smart contract on the Ethereum mainnet checks that the commitment is valid
            * smart contract part can be imagined as ERC20
                * balance of each participant is recorded in the contract
                * hundreds "transfer" would be packaged into one transaction
                    * contract can disassemble these "transfer" and verify
                * two merkle trees are used for the record
                    1. one is to record addresses, so only an index can represent an address
                        * in rollup transaction recipient's address is replaced by an index value much smaller
                    1. the other tree records balance and nonce
                        * rollup transaction does not require a nonce value since it can be computed from the previous state
            * can be further categorized into two types
                * optimistic rollups
                    * assume transaction validity by default unless proven otherwise
                        * require dispute resolution mechanisms in case of fraud or incorrect transaction execution
                    * example: Optimism
                * zero-knowledge (zk)-rollups
                    * use advanced cryptographic techniques to validate transactions
                    * compress and store the user state on-chain in a Merkle tree
                    * transfer the state transition of the user states to the off-chain
                        * zkSNARK proof is used to ensure the correctness of the off-chain state transition
                    * example: ZK-Sync
        * sidechains
            * separate blockchains that are interoperable with the Ethereum mainnet
                * has its own consensus mechanism and can have different rules and features
            * to move assets between the main chain and a sidechain, you typically need to use a bridge
                * involves locking assets on the main chain and minting corresponding tokens on the sidechain
            * example: Polygon, xDai
        * channels
            * parties can exchange an unlimited amount of transactions off-chain
                * example
                    * Alice sends a signed message to Bob saying "I send you 1 ETH"
                    * Bob counter-signs the message, indicating his agreement to the new state
            * only submitting two transactions to the mainchain
                * open the channel
                    * deploy a smart contract
                    * fund smart contract with an initial deposit
                * close the channel
                    * submitting the final state to the smart contract on the mainnet
                    * smart contract verifies the final state and distributes the funds accordingly
            * example: Raiden, Celer Network, Connext
1. use in-line assembly code
    * efficient code that can be executed directly by the EVM without the need for expensive Solidity opcodes
    * more precise control over memory and storage usage
1. don't assigning default values
    * every variable assignment in Solidity costs gas
    * example
        ```
        uint256 value
        ```
        is cheaper than
        ```
        uint256 value = 0
        ```
1. memory is very cheap to allocate as long as it is small
    * past a certain point (32 kilobytes) in a single transaction, the memory cost enters into a quadratic section
    * example
        ```
        contract smallArraySize {
            // Function Execution Cost = 21,903
            function checkArray() external {
                uint256[100] memory myArr;
            }
        }
        contract LargeArraySize {
            // Function Execution Cost = 276,750
            function checkArray() external {
                uint256[10000] memory myArr;
            }
        }
        contract VeryLargeArraySize {
            // Function Execution Cost = 20,154,094
            function checkArray() external {
                uint256[100000] memory myArr;
            }
        ```
1. batching
    * consolidate data retrieval by calling a function that returns all the required data instead of making separate calls for each data element
1. use external function modifiers
    * function parameters are not copied into memory but are read directly from the call data
1. use erc1167 to deploy the same contract many time
    * standardized, gas-efficient way to deploy a bunch of contract clones from a factory
    * not only minimizes length, but it is also literally a “minimal” proxy that does nothing but proxying
    * address in EIP1167 is hardcoded in bytecode and remain unchangeable
    * example
        * one of the most famous proxy contract users is Uniswap
            * has a factory pattern to create exchanges for each ERC20 tokens
            * has one exchange instance that contains full bytecode as the program logic, and the remainders are all proxies
            * https://etherscan.io/address/0x09cabec1ead1c0ba254b09efb3ee13841712be14#code
                * a short bytecode, which is unlikely an implementation of an exchange
                * what it does is blindly relay every incoming transaction to the reference contract by delegatecall
            * every proxy is a 100% replica of that contract but serving for different tokens
            * length of the creation code of Uniswap exchange implementation is 12468 bytes
                * proxy contract, however, has only 46 bytes