# Seq.Client.Oracle

Oracle PL/SQL package which sends log events to a [Seq](https://getseq.net/) instance via its REST APIs.

## 1. Setup as DBA

Following instructions are related to [Setup.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/Setup.sql) file.

Before installing (and customising) Oracle package, some commands need to be run as DBA. Specifically, DBA needs to allow remote HTTP calls to Seq instance for a given Oracle user.

[Setup.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/Setup.sql) file contains these parameters:

| Parameter name | Default value | Meaning                                          |
| -------------- | ------------- | ------------------------------------------------ |
| ORACLE_USER    |               | Oracle user who needs to send log events to Seq. |
| SEQ_HOST       |               | Host name on which Seq is listening to.          |
| SEQ_PORT       | 5341          | Port number on which Seq is listening to.        |

Before going to step 2, please make sure that there are no networking or security issues blocking HTTP calls from Oracle machine to Seq machine. Using `curl` from Oracle machine, you can easily verify the connectivity with this command (please replace placeholders with proper values):

```shell
curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X GET http://{SEQ_HOST}:{SEQ_PORT}/api/
```

Result should be similar to the one described in [this Seq documentation page](https://docs.getseq.net/docs/using-the-http-api):

```js
{
  "Product": "Seq .NET Structured Event Server",
  "Version": "1.0.0.0",
  "Links": {
    "ApiKeysResources": "/api/apikeys/resources",
    "AppInstancesResources": "/api/appinstances\resources",
    "AppsResources": "/api/apps/resources",
    "EventsResources": "/api/events/resources",
    "ExpressionsResources": "/api/expressions/resources",
    "FeedsResources": "/api/feeds/resources",
    "LicensesResources": "/api/licenses/resources",
    "QueriesResources": "/api/queries/resources",
    "ReportsResources": "/api/reports/resources",
    "RetentionPoliciesResources": "/api/retentionpolicies/resources",
    "SettingsResources": "/api/settings/resources",
    "UsersResources": "/api/users/resources",
    "ViewsResources": "/api/views/resources"
  }
}
```

## 2. Package deploy

Following instructions are related to [Package.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/Package.sql) file.

[Package.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/Package.sql) file contains these parameters:

| Parameter name      | Default value | Meaning                                                           |
| ------------------- | ------------- | ----------------------------------------------------------------- |
| ORACLE_USER         |               | Oracle user for whom package should be created.                   |
| ORACLE_PACKAGE      | seq_log       | Oracle package name for Seq client.                               |
| SEQ_HOST            |               | Host name on which Seq is listening to.                           |
| SEQ_PORT            | 5341          | Port number on which Seq is listening to.                         |
| SEQ_DEFAULT_API_KEY |               | **Default** API KEY which will be used to send log events to Seq. |

## 3. Add another user (optional)

Following instructions are related to [AddUser.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/AddUser.sql) file.

If more than one Oracle user needs to send log events, then proper permissions should be added to other users. Specifically, DBA needs to allow remote HTTP calls to Seq instance for other Oracle users, reusing the same security objects defined during setup step.

[AddUser.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/AddUser.sql) file contains these parameters:

| Parameter name | Default value | Meaning                                                |
| -------------- | ------------- | ------------------------------------------------------ |
| ORACLE_USER    |               | Other Oracle user who needs to send log events to Seq. |
