define ORACLE_USER         = '???';     -- Set here the Oracle user for whom package should be created
define ORACLE_PACKAGE      = 'seq_log'; -- Set here the Oracle package name for Seq client - Default is 'seq_log'
define SEQ_HOST            = '???';     -- Set here the host name on which Seq is listening to
define SEQ_PORT            = '5341';    -- Set here the port number on which Seq is listening to - Default is 5341
define SEQ_DEFAULT_API_KEY = '???';     -- Set here the default API KEY which will be used to send log events to Seq

create package &ORACLE_USER.&ORACLE_PACKAGE as

  type evt_prop is record (name nvarchar2, 
                           value nvarchar2);
                             
  type evt_props is varray(20) of evt_prop;

  function seq_base_url return varchar2 deterministic;
  
  function seq_raw_events_url return varchar2 deterministic;
  
  function seq_default_api_key return varchar2 deterministic;
  
  function seq_clef_template return varchar2 deterministic;

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
                           event_props in evt_props);

  procedure self_test();

end &ORACLE_PACKAGE;
/
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
    return '{"@t":"[[timestamp]]","@l":"[[log_level]]","@mt":"[[message_template]]"[[event_props]]}';
  end seq_clef_template;
  
  function json_escape(str as nvarchar2(2000))
  is    
    -- Start replacing all backslashes, to avoid replacing propers escapes.
    str = regexp_replace(str, '' || chr(92), '\\');
    -- Then, continue with other reserved characters.
    str = regexp_replace(str, '' || chr(10), '\n');
    str = regexp_replace(str, '' || chr(13), '\r');
    str = regexp_replace(str, '' || chr(11), '\t');
    str = regexp_replace(str, '' || chr(34), '\"');
    return str;
  end;
  
  procedure verbose(message_template as nvarchar2(2000),
                    event_props as evt_props)
  is
    owner varchar2;
    program_unit varchar2;
    line_number number;
    caller_type varchar2;
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Verbose', message_template, event_props, owner, program_unit, line_number);
  end information;
  
  procedure debug(message_template as nvarchar2(2000),
                  event_props as evt_props)
  is
    owner varchar2;
    program_unit varchar2;
    line_number number;
    caller_type varchar2;
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Debug', message_template, event_props, program_unit, line_number);
  end information;
  
  procedure information(message_template as nvarchar2(2000),
                        event_props as evt_props)
  is
    owner varchar2;
    program_unit varchar2;
    line_number number;
    caller_type varchar2;
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Information', message_template, event_props, program_unit, line_number);
  end information;
  
  procedure warning(message_template as nvarchar2(2000),
                    event_props as evt_props)
  is
    owner varchar2;
    program_unit varchar2;
    line_number number;
    caller_type varchar2;
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Warning', message_template, event_props, program_unit, line_number);
  end information;
  
  procedure error(message_template as nvarchar2(2000),
                  event_props as evt_props)
  is
    owner varchar2;
    program_unit varchar2;
    line_number number;
    caller_type varchar2;
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Error', message_template, event_props, program_unit, line_number);
  end information;
  
  procedure fatal(message_template as nvarchar2(2000),
                  event_props as evt_props)
  is
    owner varchar2;
    program_unit varchar2;
    line_number number;
    caller_type varchar2;
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(null, 'Fatal', message_template, event_props, program_unit, line_number);
  end information;
  
  procedure send_log_event(api_key as varchar2(100),
                           log_level as varchar2(20),
                           message_template as nvarchar2(2000),
                           event_props as evt_props,
                           owner varchar2,
                           program_unit varchar2,
                           line_number number)
  is
    request utl_http.req;
    response utl_http.resp;
    timestamp varchar2(30);
    event_props_json nvarchar2(2000);
    log_event nvarchar2(2000);
    buffer nvarchar2(2000);
  begin
    api_key   := coalesce(api_key, seq_default_api_key());
    timestamp := to_char(systimestamp at time zone 'UTC', 'yyyy-mm-dd"T"hh24:mi:ss.ff3"Z"');
    
    select listagg(',"' || json_escape(x.key) || '":"' || json_escape(x.value) || '"') within group (order by x.key)
      into event_props_json
      from (select key, value from table(event_props)
             union all
            select 'SourceContext' key, (upper(owner) || '.' || upper(program_unit)) value from dual
             union all
            select 'LineNumber' key, to_char(line_number) value from dual) x;
  
    log_event := seq_clef_template();
    log_event := replace(log_event, '[[timestamp]]', timestamp);
    log_event := replace(log_event, '[[log_level]]', log_level);
    log_event := replace(log_event, '[[message_template]]', message_template);
    log_event := replace(log_event, '[[event_props]]', event_props_json);
  
    request := utl_http.begin_request(seq_raw_events_url(), 'POST',' HTTP/1.1');
    utl_http.set_header(request, 'User-Agent', 'Seq client for Oracle/PLSQL'); 
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
