--oracle
alter table F_DATACATALOG modify FieldDesc varchar2(1024);
alter table F_UNITINFO add UNITPATH VARCHAR2(1000);

update f_unitinfo t set t.unit_path = (
select b.UnitPath from (
select level as hi_level,
               t.unit_code,
               t.parent_unit,
               CONNECT_BY_ROOT t.unit_code as topunitcode,
               SYS_CONNECT_BY_PATH(t.unit_code, '/') UnitPath
          from f_unitinfo t
          start with t.parent_unit is null or not exists (select f.* from f_unitinfo f where f.unit_code=t.parent_unit)
connect by prior unit_code = parent_unit) b
where b.unit_code=t.unit_code);

--mysql
alter table F_DATACATALOG modify FieldDesc varchar(1024);
alter table F_UNITINFO add UNITPATH VARCHAR(1000);

DELIMITER $$

CREATE FUNCTION calcUnitPath (chrId varchar(32)) 
	RETURNS varchar(1000) 
BEGIN
   DECLARE sTemp VARCHAR(32);
   DECLARE sPreTemp VARCHAR(32);
   DECLARE path VARCHAR(1000);
   DECLARE rs VARCHAR(1000);   
   SET  sTemp = trim(chrId);
   SET  path = '';
   REPEAT
   	  SET  path = concat('/',sTemp, path);
   	  set sPreTemp = sTemp;
      SELECT unitcode INTO sTemp 
         FROM f_unitinfo  
         where unitcode = 
         		(select parentunit FROM f_unitinfo where unitcode = sTemp);
      until sTemp is null or sTemp='' or sPreTemp = sTemp
   END REPEAT;
  
   RETURN path;
END$$

DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
update f_unitinfo t set t.UnitPath = calcUnitPath(t.unitcode);

