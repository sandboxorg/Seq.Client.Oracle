define ORACLE_USER  = '???';  -- Set here the Oracle user who needs to send log entries to Seq
define SEQ_PORT     = 5341;   -- Set here the port number on which Seq is listening on - Default is 5341

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
    host        => 'localhost', 
    lower_port  => 5341,
    upper_port  => NULL);    
end; 
