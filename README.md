# PaymentChallange

## Platform
A phoneix web app utilizing the Heex templating engine. 

## Scrapper
Provided a Transaction hash, the application retrieves the respective HTML page from Ethersacan and parses it for getting number of block confirmations for the transaction.

Scrapping is used over Etherscan's developers API because the `transaction` endpoints do not respond with the number of block confirmations for a transaction, just the status code.

`Floki` is used for parsing the html document.

## (Pending) Payemnt Observer
The payment observer worker is a `GenServer` which, after an interval, looks for transactions with status `pending` and tries to update their status by retrieving their number of block confirmation from Etherscan. 

A GenServer is used as it is an independant process which works as a background job and it's the most appropriate tool for this purpose in the OTP toolkit.

The worker has it's own supervisor (in the supervision tree) which makes the system more fault tolerant in case the worker crashes. 


## Payment Store
For in memory and non-persistant storage an `Agent` is used over ETS as it fits our purpose and low work load.


## Payment Context
Context layer which exposes our business logic to the rest of the application.

