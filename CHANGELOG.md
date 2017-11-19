# Changelog for Seq.Client.Oracle

## v1.1.3 (2017-11-19)

* Using right property (@x) for error stack trace.

## v1.1.2 (2017-11-15)

* Made it clear in the docs that ORACLE_USER should be UPPERCASE.
* Added an error case to self_test procedure.

## v1.1.1 (2017-11-15)

* Integer property values are now sent as integers rather than strings.

## v1.1.0 (2017-11-14)

* Line number is properly sent as an integer.
* Stack trace is sent when an error is detected.

## v1.0.1 (2017-11-14)

* Source context is now set to "anonymous.block" when log is called from an anonymous block.

## v1.0.0 (2017-11-13)

* Initial release.