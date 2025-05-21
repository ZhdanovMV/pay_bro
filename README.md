# README

A small financial API application using Ruby on Rails and Postgres.

Ruby version: 3.4

Rails version: 8.0.2

## Setup
To prepare this app to be launched, run the following commands after cloning the repo:
```bash
bundle install
bin/rails db:create
bin/rails db:migrate
```

To start the Rails server, run:
```bash
bin/rails server
```
The application will be accessible at `http://localhost:3000`.

To run tests, execute:
```bash
rspec
```

## Examples of CURL queries
### Signup
```bash
curl -X POST http://localhost:3000/api/v1/signup -H "Content-Type: application/json" \
-d '{"email":"user1@example.com", "password":"pass123"}'
```

### Login
```bash
curl -X POST http://localhost:3000/api/v1/login -H "Content-Type: application/json" \
-d '{"email":"user1@example.com", "password":"pass123"}'
```

### Check balance
Requires JWT token from login query response
```bash
curl -H "Authorization: Bearer <JWT>" http://localhost:3000/api/v1/accounts/balance
```

### Deposit
Requires JWT token from login query response
```bash
curl -X POST http://localhost:3000/api/v1/accounts/deposit \
-H "Authorization: Bearer <JWT>" \
-H "Content-Type: application/json" \
-d '{"amount": 100}'
```

### Withdraw
Requires JWT token from login query response
```bash
curl -X POST http://localhost:3000/api/v1/accounts/withdraw \
-H "Authorization: Bearer <JWT>" \
-H "Content-Type: application/json" \
-d '{"amount": 50}'
```

### Transfer
Requires JWT token from login query response
```bash
curl -X POST http://localhost:3000/api/v1/accounts/transfer \
-H "Authorization: Bearer <JWT>" \
-H "Content-Type: application/json" \
-d '{"recipient_email": "user2@example.com", "amount": 25}'
```
