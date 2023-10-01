# ethereum-gas-fee-workshop

* references
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
* gas optimisation techniques
    1. Use view and pure Functions: If a function does not modify state variables, declare it with the view or pure keyword. This allows them to be executed locally without any gas cost.
    1. Avoid Loops Whenever Possible: Loops can consume a lot of gas, especially when the number of iterations is high or unpredictable. Consider using mapping or other data structures to avoid loops.
    1. Minimize Storage Reads and Writes: Storage operations are more expensive than memory or stack operations. Minimize the number of read and write operations to storage variables.
    1. Use Structs to Group Related Data: Grouping related data into structs can reduce storage costs compared to using separate variables.
    1. Avoid Large Arrays: Operations on large arrays can be expensive. Consider using mappings or other data structures to achieve the same functionality.
    1. Limit Function Visibility: Make functions as private as possible to prevent unintended external access.
    1. Use Enums Instead of Strings: Enums are more gas-efficient compared to strings, as they represent a fixed set of values.
    1. Use Events for Logging: Events are a more efficient way to log information compared to writing to storage.
    1. Leverage Libraries: Use libraries for reusable code. This can save gas by reducing the size of your contracts.
    1. Avoid Complex Operations in Constructors: Constructors run only once during deployment. Avoid performing complex operations in them.
    1. Consider Lazy Evaluation: Delaying computations until absolutely necessary can save gas.
    1. Upgradeable Contracts: Implement a proxy pattern to separate the logic from the storage, allowing for upgrades without deploying a new contract.
    1. Gas Estimation: Be aware of the gas costs associated with different operations and functions. Tools like Remix IDE provide gas estimations for transactions.
    1. Avoid Ether Sends in Loops: Sending ether in a loop can lead to unpredictable gas costs. It's better to send ether outside of loops.
    1. Use Assembly for Gas Optimization: In some cases, low-level assembly can be used to optimize gas costs further.

* Pack your variables
    * gas cost for storage usage is calculated based on the number of storage slots used
    * Each storage slot has a size of 256 bits, and the Solidity compiler and optimizer automatically handle the packing of variables into these slots
    * you can pack multiple variables within a single storage slot, optimizing storage usage and reducing gas costs
    * minimize the number of storage slots used
* Reduce outside calls
    * it is recommended to consolidate data retrieval by calling a function that returns all the required data instead of making separate calls for each data element
    * Gas efficiency is improved by reducing the number of external contract calls and retrieving multiple data points in a single function call, resulting in cost-effective and efficient smart contracts.
* uint8 is not always cheaper than uint256
    * When working with smaller variable types like uint8, the EVM must first convert them to the more significant uint256 type to perform operations on them
    * The key lies in the concept of packing
        * In Solidity, you can pack multiple small variables into a single storage slot, optimizing storage usage and reducing gas costs
    * A smart contract's gas consumption can be higher if developers use items that are less than 32 bytes in size because the Ethereum Virtual Machine can only handle 32 bytes at a time.
    * Save on Data Types
        * For instance, in Solidity, integers can be broken down into different sizes: unit8, unit16, unit32, and so on. Since the EVM performs operations in 256-bit chunks, using uint8 means the EVM has to first convert it to uint256. This conversion costs extra gas.
* Use external function modifiers
    * In Solidity, when you define a public function that can be called from outside the contract, the input parameters of that function are automatically copied into memory and incur gas costs.
    * However, if the process is meant to be called externally, it is significant to mark it as “external” in the code. By doing so, the function parameters are not copied into memory but are read directly from the call data.
* Use the short circuit rule to your advantage
    * When using disjunction, the gas usage is reduced because if the first function evaluates to true, the second function is not executed.
    * On the other hand, in conjunction, if the first function evaluates to false, the second function is skipped entirely, further optimizing gas usage.
* Enable the Solidity Compiler Optimizer
    * an action like inlining functions can result in significantly larger code, it is frequently used because it creates the potential for additional simplifications.
    * There are several optimization tools available, such as solc optimizer, Truffle’s build optimizer, and Remix’s Solidity compiler.
* Minimize On-Chain Data
    * As defined in the Ethereum yellow paper, storage operations are over 100x more costly than memory operations. OPcodes mload and mstore only cost 3 gas units while storage operations like sload and sstore cost at least 100 units, even in the most optimistic situation.
        * Reduce Storage modifications by saving intermediate results in Memory and assign results to Storage variables only after all calculations are completed
    * saving less data in storage variables, batching operations, and avoiding looping
    * Keep all data off-chain and only save the smart contract’s critical info on-chain
    * Using events to store data is a popular, but ill-advised method for gas optimization because, while it is less expensive to store data in events relative to variables, the data in events cannot be accessed by other smart contracts on-chain.
        * as smart contracts cannot hear events on their own because contract data lives in the States trie, and event data is stored in the Transaction Receipts trie
    * example: If You know what data to hash, there is no need to consume more computational power to hash it using keccak256
        ```
        bytes32 hash = keccak256(abi.encodePacked('HashingExample')
        ```
        vs
        ```
        bytes32 hash = 'BHsbwJbdw'
        ```
        * Changing to immutable will only perform hashing on contract deployment which will save gas
            * The use of constant keccak variables results in extra hashing (and so gas).
            * This results in the keccak operation being performed whenever the variable is used, increasing gas costs relative to just storing the output hash.
    * Data that does not need to be accessed on-chain can be stored in events to save gas.
    * When you design a Dapp you don’t have to put 100% of your data on the blockchain, usually, you have part of the system (Unnecessary data (metadata, etc .. ) ) on a centralized server.
* Batching Operations
* Looping
    * Avoid looping through lengthy arrays; not only will it consume a lot of gas, but if gas prices rise too much, it can even prevent your contract from being carried out beyond the block gas limit.
    * ‍Instead of looping over an array until you locate the key you need, use mappings, which are hash tables that enable you to retrieve any value using its key in a single action.
* Free Up Unused Storage
    * Deleting your unused variables helps free up space and earns a gas refund.
    * Deleting unused variables has the same effect as reassigning the value type with its default value, such as the integer's default value of 0, or the address zero for addresses.
    * Mappings, however, are unaffected by deletion, as the keys of mappings may be arbitrary and are generally unknown.
* Use Calldata Instead of Memory
    * Instead of copying variables to memory, it is typically more cost-effective to load them immediately from calldata.
* Use immutable and constant
    * Immutable and constant are keywords that can be used on state variables to limit changes to their state.
    * Constant/Immutable variables are not stored in contract storage
        * These variables are evaluated at compile-time and are stored in the bytecode of the contract.
* Mapping vs Array
    * Mappings are more efficient and less expensive in most cases, while Arrays are iterable and packable.
    * Therefore, it is advised to utilize mappings for managing lists of data, except when iteration is required or it is possible to pack data types.
* Modifier Optimization
    * It is recommended to move the modifiers require statements into an internal virtual function
    * Putting the require in an internal function decreases contract size when a modifier is used multiple times.
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
    }

    function _onlyOwner() private {
        require(msg.sender == owner, "Only owner can call this function");
    }
    ```
* Use In-Line Assembly Code
    * In-line assembly allows developers to write low-level, efficient code that can be executed directly by the EVM without the need for expensive Solidity opcodes
    * In-line assembly also allows for more precise control over memory and storage usage, which can further reduce gas costs
* Use Layer 2 Solutions
    * Layer 2 solutions like rollups, sidechains, and state channels enable offloading of transaction processing from the main Ethereum chain, resulting in faster and cheaper transactions.
* Use Libraries
    * If you have several contracts that use the same functionalities, you can extract these common functions into a single library, and then you’re gonna deploy this library just once and all your contracts will point to this library to execute the shared functionalities.
* Avoid manipulating storage data
    * In the Second contract, before running the for loop we’re assigning the value of a storage data d to _d to avoid accessing the storage each time we iterate.
        ```
        uint _d = d;
        for (uint i = 0; i < _d; i++) {  }
        ```
    * Caching the length in for loops
        * Reading array length at each iteration of the loop takes 6 gas (three for mload and three to place memory_offset ) in the stack.
        * Caching the array length in the stack saves around 3 gas per iteration
        * If it is a storage array, this is an extra sload operation (100 additional extra gas (EIP-2929) for each iteration except for the first)
        * If it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first),
        * If it is a calldata array, this is an extra calldataload operation (3 additional gas for each iteration except for the first) These extra costs can be avoided by caching the array length (in the stack):
        * uint length = arr.length;
            * In the above example, the sload or mload or calldataload operation is only called once and subsequently replaced by a cheap dupN instruction
* Use ERC1167 To Deploy the same Contract many time
    * EIP1167 minimal proxy contract is a standardized, gas-efficient way to deploy a bunch of contract clones from a factory
    * .EIP1167 not only minimizes length, but it is also literally a “minimal” proxy that does nothing but proxying
    * Unlike other upgradable proxy contracts that rely on the honesty of their administrator (who can change the implementation), the address in EIP1167 is hardcoded in bytecode and remain unchangeable.
* Avoid assigning values that You’ll never use
    * Every variable assignment in Solidity costs gas. When initializing variables, we often waste gas by assigning default values that will never be used.
      uint256 value; is cheaper than uint256 value = 0;.
* Use storage pointers instead of memory where appropriate
    ```
    mapping(uint256 => User) public users;
    User memory _user = users[_id];
    ```
    vs
    ```
    mapping(uint256 => User) public users;
    User storage _user = users[_id];
    ```
* Memory is very cheap to allocate as long as it is small but past a certain point i.e., 32 kilobytes of memory storage in a single transaction, the memory cost enters into a quadratic section and the formula for this calculation is given in Ethereum Yellow Paper as follows
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