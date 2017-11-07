define ORACLE_USER    = '???';            -- Set here the Oracle user for whom package should be created
define ORACLE_PACKAGE = 'PCK_SEQ_CLIENT'; -- Set here the Oracle package name for Seq client
define SEQ_HOST       = '???';            -- Set here the host name on which Seq is listening to
define SEQ_PORT       = 5341;             -- Set here the port number on which Seq is listening to - Default is 5341

CREATE PACKAGE &ORACLE_USER.&ORACLE_PACKAGE AS 
  PROCEDURE find_sal(c_id customers.id%type); 
END &ORACLE_PACKAGE;

CREATE OR REPLACE PACKAGE BODY &ORACLE_USER.&ORACLE_PACKAGE AS    
  PROCEDURE find_sal(c_id customers.id%TYPE) IS 
    c_sal customers.salary%TYPE; 
  BEGIN 
    SELECT salary INTO c_sal 
      FROM customers 
     WHERE id = c_id; 
    dbms_output.put_line('Salary: '|| c_sal); 
  END find_sal; 
END &ORACLE_PACKAGE;
