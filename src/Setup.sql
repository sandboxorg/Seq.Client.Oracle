define ORACLE_USER = '???';  -- Set here the Oracle user who needs to send log events to Seq
define SEQ_HOST    = '???';  -- Set here the host name on which Seq is listening to
define SEQ_PORT    = '5341'; -- Set here the port number on which Seq is listening to - Default is 5341

-- Remove following grants if user is SYS
grant execute on utl_http to &ORACLE_USER;
/
grant execute on dbms_lock to &ORACLE_USER;
/

begin
  DBMS_NETWORK_ACL_ADMIN.create_acl(acl         => 'www.xml',
                                    description => 'WWW ACL',
                                    principal   => '&ORACLE_USER',
                                    is_grant    => true,
                                    privilege   => 'connect');
  
  DBMS_NETWORK_ACL_ADMIN.add_privilege(acl       => 'www.xml',
                                       principal => '&ORACLE_USER',
                                       is_grant  => true,
                                       privilege => 'resolve');

  DBMS_NETWORK_ACL_ADMIN.assign_acl(acl        => 'www.xml',
                                    host       => '&SEQ_HOST',
                                    lower_port => &SEQ_PORT,
                                    upper_port => &SEQ_PORT);
end;
/
commit;
/