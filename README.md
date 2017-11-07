# Seq.Client.Oracle

Oracle PL/SQL package which sends log entries to a [Seq](https://getseq.net/) instance via its REST APIs.

## 1. Setup as DBA

Following instructions are related to [Setup.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/Setup.sql) file.

Before installing (and customising) Oracle package, some commands need to be run as DBA. Specifically, DBA needs to allow remote HTTP calls to Seq instance for a given Oracle user.

[Setup.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/Setup.sql) file contains these parameters:

| Parameter name | Default value | Meaning                                           |
| -------------- | ------------- | ------------------------------------------------- |
| ORACLE_USER    |               | Oracle user who needs to send log entries to Seq. |
| SEQ_HOST       |               | Host name on which Seq is listening to.           |
| SEQ_PORT       | 5341          | Port number on which Seq is listening to.         |

## 2. Package deploy

Following instructions are related to [Package.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/Package.sql) file.

[Package.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/Package.sql) file contains these parameters:

| Parameter name | Default value | Meaning                                         |
| -------------- | ------------- | ----------------------------------------------- |
| ORACLE_USER    |               | Oracle user for whom package should be created. |
| SEQ_HOST       |               | Host name on which Seq is listening to.         |
| SEQ_PORT       | 5341          | Port number on which Seq is listening to.       |

## 3. Add another user (optional)

Following instructions are related to [AddUser.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/AddUser.sql) file.

If more than one Oracle user needs to send log entries, then proper permissions should be added to other users. Specifically, DBA needs to allow remote HTTP calls to Seq instance for other Oracle users, reusing the same security objects defined during setup step.

[AddUser.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/AddUser.sql) file contains these parameters:

| Parameter name | Default value | Meaning                                                 |
| -------------- | ------------- | ------------------------------------------------------- |
| ORACLE_USER    |               | Other Oracle user who needs to send log entries to Seq. |
