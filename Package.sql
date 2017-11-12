define ORACLE_USER         = '???';     -- Set here the Oracle user for whom package should be created
define ORACLE_PACKAGE      = 'seq_log'; -- Set here the Oracle package name for Seq client - Default is 'seq_log'
define SEQ_HOST            = '???';     -- Set here the host name on which Seq is listening to
define SEQ_PORT            = '5341';    -- Set here the port number on which Seq is listening to - Default is 5341
define SEQ_DEFAULT_API_KEY = '???';     -- Set here the default API KEY which will be used to send log events to Seq

define DOT = '.'; -- Internal use only.

create or replace package &ORACLE_USER&DOT&ORACLE_PACKAGE as

  type evt_prop is record (name varchar2(100), 
                           value varchar2(4000));
                             
  type evt_props is varray(20) of evt_prop;

  function base_url return varchar2 deterministic;
  
  function raw_events_url return varchar2 deterministic;
  
  function default_api_key return varchar2 deterministic;
  
  function clef_template return varchar2 deterministic;

  function escape_json(str in varchar2) return varchar2 deterministic;

  procedure set_api_key(api_key in varchar2);

  procedure verbose(message in varchar2);

  procedure verbose(message_template in varchar2,
                    event_props in evt_props);

  procedure debug(message in varchar2);

  procedure debug(message_template in varchar2,
                  event_props in evt_props);

  procedure information(message in varchar2);
  
  procedure information(message_template in varchar2,
                        event_props in evt_props);

  procedure warning(message in varchar2);

  procedure warning(message_template in varchar2,
                    event_props in evt_props);

  procedure error(message in varchar2);

  procedure error(message_template in varchar2,
                  event_props in evt_props);

  procedure fatal(message in varchar2);

  procedure fatal(message_template in varchar2,
                  event_props in evt_props);
  
  procedure send_log_event(api_key in varchar2,
                           log_level in varchar2,
                           message_template in varchar2,
                           event_props in evt_props,
                           owner in varchar2,
                           program_unit in varchar2,
                           line_number in number);

  procedure self_test;

end &ORACLE_PACKAGE;
/
create or replace package body &ORACLE_USER&DOT&ORACLE_PACKAGE as

  custom_api_key varchar2(100);

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
    return '{"@t":"[[timestamp]]","@l":"[[log_level]]","[[message_type]]":"[[message_template]]"[[event_props]]}';
  end clef_template;
  
  function escape_json(str in varchar2) return varchar2 deterministic
  is
    esc varchar2(32767);  
  begin
    -- Start replacing all backslashes, to avoid replacing propers escapes.
    esc := regexp_replace(str, '\\', '\\\');
    -- Then, continue with other reserved characters.
    esc := regexp_replace(esc, '' || chr(10), '\n');
    esc := regexp_replace(esc, '' || chr(13), '\r');
    esc := regexp_replace(esc, '' || chr(11), '\t');
    esc := regexp_replace(esc, '' || chr(34), '\"');
    return '"' || esc || '"';
  end escape_json;

  procedure set_api_key(api_key in varchar2)
  is
  begin
    custom_api_key := api_key;
  end set_api_key;
  
  procedure verbose(message in varchar2)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Verbose', message, null, owner, program_unit, line_number);
  end verbose;

  procedure verbose(message_template in varchar2,
                    event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Verbose', message_template, event_props, owner, program_unit, line_number);
  end verbose;
  
  procedure debug(message in varchar2)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Debug', message, null, owner, program_unit, line_number);
  end debug;

  procedure debug(message_template in varchar2,
                  event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Debug', message_template, event_props, owner, program_unit, line_number);
  end debug;
  
  procedure information(message in varchar2)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Information', message, null, owner, program_unit, line_number);
  end information;

  procedure information(message_template in varchar2,
                        event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Information', message_template, event_props, owner, program_unit, line_number);
  end information;
  
  procedure warning(message in varchar2)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Warning', message, null, owner, program_unit, line_number);
  end warning;

  procedure warning(message_template in varchar2,
                    event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Warning', message_template, event_props, owner, program_unit, line_number);
  end warning;
  
  procedure error(message in varchar2)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Error', message, null, owner, program_unit, line_number);
  end error;

  procedure error(message_template in varchar2,
                  event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Error', message_template, event_props, owner, program_unit, line_number);
  end error;
  
  procedure fatal(message in varchar2)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Fatal', message, null, owner, program_unit, line_number);
  end fatal;

  procedure fatal(message_template in varchar2,
                  event_props in evt_props)
  is
    owner varchar2(100);
    program_unit varchar2(100);
    line_number number(10);
    caller_type varchar2(100);
  begin
    owa_util.who_called_me(owner, program_unit, line_number, caller_type);
    send_log_event(custom_api_key, 'Fatal', message_template, event_props, owner, program_unit, line_number);
  end fatal;
  
  procedure send_log_event(api_key in varchar2,
                           log_level in varchar2,
                           message_template in varchar2,
                           event_props in evt_props,
                           owner in varchar2,
                           program_unit in varchar2,
                           line_number in number)
  is
    request utl_http.req;
    response utl_http.resp;
    timestamp varchar2(100);
    message_type varchar(3);
    event_props_json varchar2(32767);
    log_event varchar2(32767);
    buffer varchar2(32767);
  begin
    timestamp := to_char(systimestamp at time zone 'UTC', 'yyyy-mm-dd"T"hh24:mi:ss.ff3"Z"');

    event_props_json := ',' || escape_json('SourceContext') || ':' || escape_json(lower(owner) || '.' || lower(program_unit));
    event_props_json := event_props_json || ',' || escape_json('LineNumber') || ':' || escape_json(to_char(line_number));

    if event_props is not null and event_props.count > 0 
    then
        message_type := '@mt';
        for evp in 1 .. event_props.count 
        loop
          event_props_json := event_props_json || ',' || escape_json(event_props(evp).name) || ':' || escape_json(event_props(evp).value);
        end loop;
    else
        message_type := '@m';
    end if;
  
    log_event := clef_template;
    log_event := replace(log_event, '[[timestamp]]', timestamp);
    log_event := replace(log_event, '[[log_level]]', log_level);
    log_event := replace(log_event, '[[message_type]]', message_type);
    log_event := replace(log_event, '[[message_template]]', message_template);
    log_event := replace(log_event, '[[event_props]]', event_props_json);
  
    request := utl_http.begin_request(raw_events_url, 'POST',' HTTP/1.1');
    utl_http.set_header(request, 'User-Agent', 'Mozilla/4.0'); 
    utl_http.set_header(request, 'Content-Type', 'application/json;charset=utf-8'); 
    utl_http.set_header(request, 'Content-Length', length(log_event));
    utl_http.set_header(request, 'Accept', 'application/json');
    utl_http.set_header(request, 'X-Seq-ApiKey', coalesce(api_key, default_api_key));
  
    utl_http.write_text(request, log_event);
    response := utl_http.get_response(request);

    -- Process the response from the HTTP call.
    begin
      loop
        utl_http.read_line(response, buffer);
        dbms_output.put_line(buffer);
      end loop;
      utl_http.end_response(response);
    exception
      when utl_http.end_of_body then
        utl_http.end_response(response);
    end;   
  exception
    when others then
      null; -- Do nothing when an error happens.
  end send_log_event;

  procedure self_test
  is
    test_log_level evt_prop;
    test_number evt_prop;
  begin
    test_log_level.name := 'TestLogLevel';
    test_number.name := 'TestNumber';
  
    test_log_level.value := 'VERBOSE';
    test_number.value := '1';
    verbose('Verbose test message from Seq client for Oracle');
    verbose('{TestLogLevel} test template message from Seq client for Oracle - {TestNumber}', evt_props(test_log_level, test_number));

    test_log_level.value := 'DEBUG';
    test_number.value := '2';
    debug('Debug test message from Seq client for Oracle');
    debug('{TestLogLevel} test template message from Seq client for Oracle - {TestNumber}', evt_props(test_log_level, test_number));

    test_log_level.value := 'INFORMATION';
    test_number.value := '3';
    information('Information test message from Seq client for Oracle');
    information('{TestLogLevel} test template message from Seq client for Oracle - {TestNumber}', evt_props(test_log_level, test_number));

    test_log_level.value := 'WARNING';
    test_number.value := '4';
    warning('Warning test message from Seq client for Oracle');
    warning('{TestLogLevel} test template message from Seq client for Oracle - {TestNumber}', evt_props(test_log_level, test_number));

    test_log_level.value := 'ERROR';
    test_number.value := '5';
    error('Error test message from Seq client for Oracle');
    error('{TestLogLevel} test template message from Seq client for Oracle - {TestNumber}', evt_props(test_log_level, test_number));

    test_log_level.value := 'FATAL';
    test_number.value := '6';
    fatal('Fatal test message from Seq client for Oracle');
    fatal('{TestLogLevel} test template message from Seq client for Oracle - {TestNumber}', evt_props(test_log_level, test_number));
  end self_test;
  
end &ORACLE_PACKAGE;
