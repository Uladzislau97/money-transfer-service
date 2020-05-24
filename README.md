# Money Transfer Service

#### Main commands
- ```make setup``` to create database, run migrations and populate db with test users.
- ```make console``` ro tun rails console
- ```make test``` to run tests

#### Structure
- [Transfer Service](https://github.com/Uladzislau97/money-transfer-service/blob/master/app/models/user.rb) - implementation of user model and TransferService
- [Transfer Service Spec](https://github.com/Uladzislau97/money-transfer-service/blob/master/spec/services/transfer_service_spec.rb) - tests for TransferService