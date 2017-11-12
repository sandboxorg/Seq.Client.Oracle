# Seq.Client.Oracle

*Oracle PL/SQL package which sends log events to a [Seq](https://getseq.net/) instance via its REST APIs.*

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ELJWKEYS9QGKA)

## How to install

### 1. Setup as DBA

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

```
HTTP/1.1 200 OK
Cache-Control: no-cache
Pragma: no-cache
Transfer-Encoding: chunked
Content-Type: application/json; charset=utf-8
Expires: Wed, 08 Nov 2017 14:07:40 GMT
Server: Microsoft-HTTPAPI/2.0
Date: Thu, 09 Nov 2017 14:07:40 GMT

{"Product":"Seq — structured logs for .NET apps","Version":"4.1.14.0","InstanceName":null,"Links":{"ApiKeysResources":"api/apikeys/resources","AppInstancesResources":"api/appinstances/resources","AppsResources":"api/apps/resources","BackupsResources":"api/backups/resources","DashboardsResources":"api/dashboards/resources","DataResources":"api/data/resources","DiagnosticsResources":"api/diagnostics/resources","EventsResources":"api/events/resources","ExpressionsResources":"api/expressions/resources","FeedsResources":"api/feeds/resources","LicensesResources":"api/licenses/resources","PermalinksResources":"api/permalinks/resources","RetentionPoliciesResources":"api/retentionpolicies/resources","SettingsResources":"api/settings/resources","SignalsResources":"api/signals/resources","SqlQueriesResources":"api/sqlqueries/resources","UpdatesResources":"api/updates/resources","UsersResources":"api/users/resources"}}
```

### 2. Package deploy

Following instructions are related to [Package.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/Package.sql) file.

[Package.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/Package.sql) file contains these parameters:

| Parameter name      | Default value | Meaning                                                           |
| ------------------- | ------------- | ----------------------------------------------------------------- |
| ORACLE_USER         |               | Oracle user for whom package should be created.                   |
| ORACLE_PACKAGE      | seq_log       | Oracle package name for Seq client.                               |
| SEQ_HOST            |               | Host name on which Seq is listening to.                           |
| SEQ_PORT            | 5341          | Port number on which Seq is listening to.                         |
| SEQ_DEFAULT_API_KEY |               | **Default** API KEY which will be used to send log events to Seq. |

After having installed that package, you can test that everything is working properly by running this command (please replace placeholders with proper values):

```sql
begin
  {ORACLE_USER}.{ORACLE_PACKAGE}.self_test();
end;
```

If test runs OK, then you should find two messages per log level inside your Seq instance, all related to the API KEY specified during package installation; one message is simple, while the other one uses event properties.

### 3. Add another user (optional)

Following instructions are related to [AddUser.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/AddUser.sql) file.

If more than one Oracle user needs to send log events, then proper permissions should be added to other users. Specifically, DBA needs to allow remote HTTP calls to Seq instance for other Oracle users, reusing the same security objects defined during setup step.

[AddUser.sql](https://github.com/finsaspa/Seq.Client.Oracle/blob/master/AddUser.sql) file contains these parameters:

| Parameter name | Default value | Meaning                                                |
| -------------- | ------------- | ------------------------------------------------------ |
| ORACLE_USER    |               | Other Oracle user who needs to send log events to Seq. |

## About this repository and its maintainer

Everything done on this repository is freely offered on the terms of the project license. You are free to do everything you want with the code and its related files, as long as you respect the license and use common sense while doing it :-)

I maintain this project during my spare time, so I can offer limited assistance and I can offer **no kind of warranty**.

However, if this project helps you, then you might offer me an hot cup of coffee:

[![Donate](http://pomma89.altervista.org/buy-me-a-coffee.png)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ELJWKEYS9QGKA)
