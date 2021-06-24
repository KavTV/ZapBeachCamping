DECLARE @Additionname VARCHAR(100)
	,@additionpaytype VARCHAR(20)
	,@price NUMERIC(8,2)


SET @Additionname = 'Adgang til badeland (børn)'
SET @additionpaytype = 'Daily'
SET @price = 15


INSERT INTO Additions VALUES(@Additionname, @additionpaytype)

INSERT INTO AdditionsSeason VALUES(@Additionname, 'Højsæson', @price)
INSERT INTO AdditionsSeason VALUES(@Additionname, 'Lavsæson', @price)