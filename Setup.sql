-- Replace $ORACLE_USER$ with the Oracle user who needs to send log messages to Seq.


grant execute on utl_http to wc;
grant execute on dbms_lock to wc;
 
BEGIN
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'local_sx_acl_file.xml', 
    description  => 'A test of the ACL functionality',
    principal    => 'WC',
    is_grant     => TRUE, 
    privilege    => 'connect',
    start_date   => SYSTIMESTAMP,
    end_date     => NULL);
end;
 
begin
  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl         => 'local_sx_acl_file.xml',
    host        => 'localhost', 
    lower_port  => 9002,
    upper_port  => NULL);    
end; 
