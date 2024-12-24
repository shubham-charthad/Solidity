TokenWallet smart contract is a basic implementation of a token wallet designed for use on a local blockchain. It enables users to send and receive tokens while maintaining a secure balance for each account. The contract includes basic functionality for managing token balances and ownership.

Features:

Ownership Control:

The contract creator becomes the owner with special privileges.
Certain functions can only be executed by the owner.

Token Transactions:

-Send tokens to other addresses
-Receive tokens to the owner's account.

Balance Management:

-Check the balance of any address.
-Fetch the caller’s current balance.

Event Logging:

-Emits events for token transfers and receipts for transparency and traceability.
