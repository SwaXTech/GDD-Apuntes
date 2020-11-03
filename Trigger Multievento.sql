-- caso 1
ALTER TRIGGER pruebaTr ON state
   INSTEAD OF INSERT, UPDATE, DELETE AS
BEGIN
--
    SET CONCAT_NULL_YIELDS_NULL OFF;  
	--
    DECLARE curInsDel CURSOR FOR
	       SELECT d.state, d.sname, i.state, i.sname
		     FROM deleted d FULL OUTER JOIN inserted i ON d.state = i.state 
	--
	DECLARE @stateD char(2), @snameD varchar(15), @stateI char(2), @snameI varchar(15)

    OPEN curInsDel
	FETCH NEXT FROM curInsDel INTO @stateD, @snameD, @stateI, @snameI
	WHILE @@FETCH_STATUS = 0 
	BEGIN
	   PRINT @stateD + ':' + @snameD + '-->' + @stateI + ':' + @snameI
	   FETCH NEXT FROM curInsDel INTO @stateD, @snameD, @stateI, @snameI
	END

	CLOSE curInsDel
	DEALLOCATE curInsDel
--
end

-- *****************************************************************\
-- caso 2
ALTER TRIGGER pruebaTr ON state
   INSTEAD OF INSERT, UPDATE, DELETE AS
BEGIN
--
    SET CONCAT_NULL_YIELDS_NULL OFF; 

    DECLARE curIns CURSOR FOR
	       SELECT state, sname FROM inserted; 
	--
	DECLARE curDel CURSOR FOR
	       SELECT * FROM deleted; 
	--
	DECLARE @state char(2), @sname varchar(15)

	print 'Se insertan'
    OPEN curIns
	FETCH NEXT FROM curIns INTO @state, @sname
	WHILE @@FETCH_STATUS = 0 
	BEGIN
	   PRINT @state + ':' + @sname
	   FETCH NEXT FROM curIns INTO @state, @sname
	END

	CLOSE curIns
	DEALLOCATE curIns
	--
	PRINT 'Se BORRAN'
	OPEN curDel
	FETCH NEXT FROM curDel INTO @state, @sname
	WHILE @@FETCH_STATUS = 0 
	BEGIN
	   PRINT @state + ':' + @sname
	   FETCH NEXT FROM curDel INTO @state, @sname
	END

	CLOSE curDel
	DEALLOCATE curDel
--
END
-- *******************************************************

update state set state = 'ZZ'
where state < 'b'

DELETE state
where state < 'b';