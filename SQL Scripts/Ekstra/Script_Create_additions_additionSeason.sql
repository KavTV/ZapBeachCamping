DECLARE @Additionname VARCHAR(100)
	,@additionpaytype VARCHAR(20)
	,@price NUMERIC(8,2)


SET @Additionname = 'Adgang til badeland (b�rn)'
SET @additionpaytype = 'Daily'
SET @price = 15


INSERT INTO Additions VALUES(@Additionname, @additionpaytype)

INSERT INTO AdditionsSeason VALUES(@Additionname, 'H�js�son', @price)
INSERT INTO AdditionsSeason VALUES(@Additionname, 'Lavs�son', @price)