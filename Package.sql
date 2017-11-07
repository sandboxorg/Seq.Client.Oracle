define ORACLE_USER    = '???';            -- Set here the Oracle user for whom package should be created
define ORACLE_PACKAGE = 'pck_seq_client'; -- Set here the Oracle package name for Seq client - Default is 'pck_seq_client'
define SEQ_HOST       = '???';            -- Set here the host name on which Seq is listening to
define SEQ_PORT       = 5341;             -- Set here the port number on which Seq is listening to - Default is 5341
define SEQ_API_KEY    = '???';            -- Set here the default API KEY which will be used to send log events to Seq

create package &ORACLE_USER.&ORACLE_PACKAGE as

  function seq_base_url return varchar2 deterministic;
  
  function seq_api_key return varchar2 deterministic;
  
  procedure send_log_event();

end &ORACLE_PACKAGE;

create or replace package body &ORACLE_USER.&ORACLE_PACKAGE as

  function seq_base_url return varchar2 deterministic
  is
  begin
    return 'http://&SEQ_HOST:&SEQ_PORT/api/';
  end seq_base_url;
  
  function seq_api_key return varchar2 deterministic
  is
  begin
    return '&SEQ_API_KEY';
  end seq_api_key;
  
  procedure send_log_event()
  as
  begin
    null;
  end;
  
end &ORACLE_PACKAGE;
