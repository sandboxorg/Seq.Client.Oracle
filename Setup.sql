define ORACLE_USER  = '???';  -- Set here the Oracle user who needs to send log entries to Seq
define SEQ_HOST     = '???';  -- Set here the host name (and path, if any) on which Seq is listening to
define SEQ_PORT     = 5341;   -- Set here the port number on which Seq is listening to - Default is 5341

grant execute on utl_http to &ORACLE_USER;
grant execute on dbms_lock to &ORACLE_USER;

begin
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'local_sx_acl_file.xml', 
    description  => 'A test of the ACL functionality',
    principal    => '&ORACLE_USER',
    is_grant     => TRUE, 
    privilege    => 'connect',
    start_date   => SYSTIMESTAMP,
    end_date     => NULL);
end;

begin
  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl         => 'local_sx_acl_file.xml',
    host        => '&SEQ_HOST', 
    lower_port  => &SEQ_PORT,
    upper_port  => NULL);    
end; 
