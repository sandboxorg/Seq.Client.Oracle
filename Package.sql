define ORACLE_USER         = '???';     -- Set here the Oracle user for whom package should be created
define ORACLE_PACKAGE      = 'utl_seq'; -- Set here the Oracle package name for Seq client - Default is 'utl_seq'
define SEQ_HOST            = '???';     -- Set here the host name on which Seq is listening to
define SEQ_PORT            = 5341;      -- Set here the port number on which Seq is listening to - Default is 5341
define SEQ_DEFAULT_API_KEY = '???';     -- Set here the default API KEY which will be used to send log events to Seq

create package &ORACLE_USER.&ORACLE_PACKAGE as

  type evt_prop is record (name nvarchar2(100), 
                           value nvarchar2(2000));
                             
  type evt_props is varray(20) of evt_prop;

  function seq_base_url return varchar2 deterministic;
  
  function seq_raw_events_url return varchar2 deterministic;
  
  function seq_default_api_key return varchar2 deterministic;
  
  function seq_clef_template return varchar2 deterministic;
  
  procedure information(message_template as nvarchar2(2000));
  
  procedure send_log_event(api_key as varchar2(100),
                           log_level as varchar2(20),
                           message_template as nvarchar2(2000),
                           event_props as evt_props);

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
  
  function seq_default_api_key return varchar2 deterministic
  is
  begin
    return '&SEQ_DEFAULT_API_KEY';
  end seq_default_api_key;
  
  function seq_clef_template return varchar2 deterministic
  is
  begin
    return '{"@t":"[[timestamp]]","@l":"[[level]]","@mt":"[[message_template]]"[[extra_props]]}';
  end seq_clef_template;
  
  procedure information(message_template as nvarchar2(2000))
  is
  begin
    send_log_event(null, 'Information', message_template);
  end information;
  
  procedure send_log_event(api_key as varchar2(100),
                           log_level as varchar2(20),
                           message_template as nvarchar2(2000),
                           event_props as evt_props)
  is
    request utl_http.req;
    response utl_http.resp;
    timestamp varchar2(30);
    log_event nvarchar2(2000);
    buffer nvarchar2(2000);
  begin
    api_key   := coalesce(api_key, seq_default_api_key());
    timestamp := to_char(systimestamp at time zone 'UTC', 'yyyy-mm-dd"T"hh24:mi:ss.ff3"Z"');
  
    log_event := seq_clef_template();
    log_event := replace(log_event, '[[timestamp]]', timestamp);
    log_event := replace(log_event, '[[level]]', log_level);
    log_event := replace(log_event, '[[message_template]]', message_template);
    log_event := replace(log_event, '[[extra_props]]', '');
  
    request := utl_http.begin_request(seq_raw_events_url(), 'POST',' HTTP/1.1');
    utl_http.set_header(request, 'User-Agent', 'Oracle/PLSQL'); 
    utl_http.set_header(request, 'Content-Type', 'application/json'); 
    utl_http.set_header(request, 'Content-Length', length(log_event));
    utl_http.set_header(request, 'Accept', 'application/json');
    utl_http.set_header(request, 'X-Seq-ApiKey', api_key);
  
    utl_http.write_text(request, log_event);
    response := utl_http.get_response(request);
    utl_http.end_response(response);    
  exception
    when others then
      null; -- Do nothing when an error happens.
  end;
  
end &ORACLE_PACKAGE;
