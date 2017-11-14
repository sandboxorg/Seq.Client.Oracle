define ORACLE_USER         = '???';     -- Set here the Oracle user, not SYS, from whom package should be used
define ORACLE_PACKAGE      = 'seq_log'; -- Set here the Oracle package name for Seq client - Default is 'seq_log'

create or replace public synonym &ORACLE_PACKAGE for &ORACLE_PACKAGE;
/
grant execute on &ORACLE_PACKAGE to &ORACLE_USER;
/