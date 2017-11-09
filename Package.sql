define ORACLE_USER         = '???';     -- Set here the Oracle user for whom package should be created
define ORACLE_PACKAGE      = 'seq_log'; -- Set here the Oracle package name for Seq client - Default is 'seq_log'
define SEQ_HOST            = '???';     -- Set here the host name on which Seq is listening to
define SEQ_PORT            = '5341';    -- Set here the port number on which Seq is listening to - Default is 5341
define SEQ_DEFAULT_API_KEY = '???';     -- Set here the default API KEY which will be used to send log events to Seq

define DOT = '.'; -- Internal use only.

create or replace package &ORACLE_USER&DOT&ORACLE_PACKAGE as

  type evt_prop is record (name nvarchar2(100), 
                           value nvarchar2(2000));
                             
  type evt_props is varray(20) of evt_prop;

  function base_url return varchar2 deterministic;
  
  function raw_events_url return varchar2 deterministic;
  
  function default_api_key return varchar2 deterministic;
  
  function clef_template return varchar2 deterministic;

  function json_escape(str in nvarchar2) return nvarchar2 deterministic;

  procedure verbose(message_template in nvarchar2,
                    event_props in evt_props);

  procedure debug(message_template in nvarchar2,
                  event_props in evt_props);
  
  procedure information(message_template in nvarchar2,
                        event_props in evt_props);

  procedure warning(message_template in nvarchar2,
                    event_props in evt_props);

  procedure error(message_template in nvarchar2,
                  event_props in evt_props);

  procedure fatal(message_template in nvarchar2,
                  event_props in evt_props);
  
  procedure send_log_event(api_key in varchar2,
                           log_level in varchar2,
                           message_template in nvarchar2,
                           event_props in evt_props,
                           owner in varchar2,
                           program_unit in varchar2,
                           line_number in number);

  procedure self_test;

end &ORACLE_PACKAGE;
/
create or replace package body &ORACLE_USER&DOT&ORACLE_PACKAGE as

  function base_url return varchar2 deterministic
  is
  begin
    return 'http://&SEQ_HOST:&SEQ_PORT/api/';
  end base_url;
  
  function raw_events_url return varchar2 deterministic
  is
  begin
    return base_url || 'events/raw?clef';
  end raw_events_url;
  
  function default_api_key return varchar2 deterministic
  is
  begin
    return '&SEQ_DEFAULT_API_KEY';
  end default_api_key;
  
  function clef_template return varchar2 deterministic
  is
  begin
    return '{"@t":"[[timestamp]]","@l":"[[log_level]]","@mt":"[[message_template]]"[[event_props]]}';
  end clef_template;
  
  function json_escape(str in nvarchar2) return nvarchar2 deterministic
  is
    esc nvarchar2(2000);  
  begin
    -- Start replacing all backslashes, to avoid replacing propers escapes.
    esc := regexp_replace(str, '' || chr(92), '\\');
    -- Then, continue with other reserved characters.
    esc := regexp_replace(esc, '' || chr(10), '\n');
    esc := regexp_replace(esc, '' || chr(13), '\r');
    esc := regexp_replace(esc, '' || chr(11), '\t');
    esc := regexp_replace(esc, '' || chr(34), '\"');
    return esc;
  end json_escape;
  
  procedure verbose(message_template in nvarchar2,
                    event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Verbose', message_template, event_props, owner, program_unit, line_number);
  end verbose;

  procedure debug(message_template in nvarchar2,
                  event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Debug', message_template, event_props, owner, program_unit, line_number);
  end debug;

  procedure information(message_template in nvarchar2,
                        event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Information', message_template, event_props, owner, program_unit, line_number);
  end information;

  procedure warning(message_template in nvarchar2,
                    event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Warning', message_template, event_props, owner, program_unit, line_number);
  end warning;

  procedure error(message_template in nvarchar2,
                  event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Error', message_template, event_props, owner, program_unit, line_number);
  end error;

  procedure fatal(message_template in nvarchar2,
                  event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Fatal', message_template, event_props, owner, program_unit, line_number);
  end fatal;
  
  procedure send_log_event(api_key in varchar2,
                           log_level in varchar2,
                           message_template in nvarchar2,
                           event_props in evt_props,
                           owner in varchar2,
                           program_unit in varchar2,
                           line_number in number)
  is
    request utl_http.req;
    response utl_http.resp;
    timestamp varchar2(100);
    event_props_json nvarchar2(2000);
    log_event nvarchar2(2000);
    buffer nvarchar2(2000);
  begin
    timestamp := to_char(systimestamp at time zone 'UTC', 'yyyy-mm-dd"T"hh24:mi:ss.ff3"Z"');
    
    select listagg(',"' || json_escape(x.name) || '":"' || json_escape(x.value) || '"') within group (order by x.name)
      into event_props_json
      from (select name, value from table(event_props)
             union all
            select to_nchar('SourceContext') name, to_nchar(upper(owner) || '.' || upper(program_unit)) value from dual
             union all
            select to_nchar('LineNumber') name, to_nchar(line_number) value from dual) x;
  
    log_event := clef_template;
    log_event := replace(log_event, '[[timestamp]]', timestamp);
    log_event := replace(log_event, '[[log_level]]', log_level);
    log_event := replace(log_event, '[[message_template]]', message_template);
    log_event := replace(log_event, '[[event_props]]', event_props_json);
  
    request := utl_http.begin_request(raw_events_url, 'POST',' HTTP/1.1');
    utl_http.set_header(request, 'User-Agent', 'Seq client for Oracle/PLSQL'); 
    utl_http.set_header(request, 'Content-Type', 'application/json'); 
    utl_http.set_header(request, 'Content-Length', length(log_event));
    utl_http.set_header(request, 'Accept', 'application/json');
    utl_http.set_header(request, 'X-Seq-ApiKey', coalesce(api_key, default_api_key));
  
    utl_http.write_text(request, log_event);
    response := utl_http.get_response(request);
    utl_http.end_response(response);    
  exception
    when others then
      null; -- Do nothing when an error happens.
  end send_log_event;

  procedure self_test
  is
  begin
    information('TEST', null);
  end self_test;
  
end &ORACLE_PACKAGE;
