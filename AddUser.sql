define ORACLE_USER = '???'; -- Set here the other Oracle user who needs to send log events to Seq

grant execute on utl_http to &ORACLE_USER;
/
grant execute on dbms_lock to &ORACLE_USER;
/
begin
  DBMS_NETWORK_ACL_ADMIN.add_privilege(acl       => 'www.xml',
                                       principal => '&ORACLE_USER',
                                       is_grant  => true,
                                       privilege => 'connect');
  
  DBMS_NETWORK_ACL_ADMIN.add_privilege(acl       => 'www.xml',
                                       principal => '&ORACLE_USER',
                                       is_grant  => true,
                                       privilege => 'resolve');
end;
/
commit;
