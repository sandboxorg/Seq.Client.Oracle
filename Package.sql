define ORACLE_USER    = '???';     -- Set here the Oracle user for whom package should be created
define ORACLE_PACKAGE = 'utl_seq'; -- Set here the Oracle package name for Seq client - Default is 'utl_seq'
define SEQ_HOST       = '???';     -- Set here the host name on which Seq is listening to
define SEQ_PORT       = 5341;      -- Set here the port number on which Seq is listening to - Default is 5341
define SEQ_API_KEY    = '???';     -- Set here the default API KEY which will be used to send log events to Seq

create package &ORACLE_USER.&ORACLE_PACKAGE as

  function seq_base_url return varchar2 deterministic;
  
  function seq_raw_events_url return varchar2 deterministic;
  
  function seq_api_key return varchar2 deterministic;
  
  function seq_clef_template return varchar2 deterministic;
  
  procedure send_log_event();

end &ORACLE_PACKAGE;

create or replace package body &ORACLE_USER.&ORACLE_PACKAGE as

  function seq_base_url return varchar2 deterministic
  is
  begin
    return 'http://&SEQ_HOST:&SEQ_PORT/api/';
  end seq_base_url;
  
  function seq_raw_events_url return varchar2 deterministic
  is
  begin
    return seq_base_url || 'events/raw?clef';
  end seq_raw_events_url;
  
  function seq_api_key return varchar2 deterministic
  is
  begin
    return '&SEQ_API_KEY';
  end seq_api_key;
  
  function seq_clef_template return varchar2 deterministic
  is
  begin
    return '{"@t":"[[timestamp]]","@l":"[[level]]","@mt":"[[message_template]]"[[extra_props]]}';
  end seq_clef_template;
  
  procedure send_log_event()
  is
    request utl_http.req;
    response utl_http.resp;
    log_event varchar2(4000);
    buffer varchar2(4000);
  begin
    log_event := seq_clef_template();
    log_event := replace(log_event, '[[timestamp]]', '123');
    log_event := replace(log_event, '[[level]]', 'Debug');
    log_event := replace(log_event, '[[message_template]]', 'TEST 123');
    log_event := replace(log_event, '[[extra_props]]', '');
  
    request := utl_http.begin_request(seq_raw_events_url(), 'POST',' HTTP/1.1');
    utl_http.set_header(request, 'User-Agent', 'Oracle/PLSQL'); 
    utl_http.set_header(request, 'Content-Type', 'application/json'); 
    utl_http.set_header(request, 'Content-Length', length(log_event));
    utl_http.set_header(request, 'Accept', 'application/json');
  
    utl_http.write_text(request, log_event);
    response := utl_http.get_response(request);
    utl_http.end_response(response);    
  exception
    when others then
      null; -- Do nothing when an error happens.
  end;
  
end &ORACLE_PACKAGE;
