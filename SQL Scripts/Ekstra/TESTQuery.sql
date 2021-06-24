BEGIN 
/*TEST GetCurrentAvaliableSites */
SELECT * FROM dbo.GetCurrentAvaliableSites()

SELECT *
FROM Reservation
WHERE campingid IN ('73', '72', '70', '68', '67')

DECLARE @today DATE = GETDATE() /*DATEADD(DAY, -1,GETDATE());*/
SELECT cs.id
FROM CampingSite cs
JOIN CampingSiteTypes cst
ON cs.id = cst.campingid
JOIN TypeSeason ts
ON cst.typename = ts.typename
JOIN CampingSiteAdditions csa
ON cs.id = csa.campingid
JOIN CampingAddition ca
ON csa.additionname = ca.[name]
LEFT JOIN Reservation r
	ON cs.id = r.campingid
WHERE ( (r.enddate IS NULL AND r.startdate IS NULL)
		OR ( (@today > R.enddate AND @today > R.startdate)
			OR (@today <= R.startdate AND @today < R.enddate AND checkin = 0)
		   )
		OR (r.enddate = @today AND r.checkout = 1)
		)
	AND ts.seasonname = dbo.GetSeasonName(@today, @today)
	AND cs.id IN ('73', '72', '70', '68', '67')
GROUP BY cs.id

SELECT cs.id
FROM CampingSite cs
JOIN CampingSiteTypes cst
ON cs.id = cst.campingid
JOIN TypeSeason ts
ON cst.typename = ts.typename
JOIN CampingSiteAdditions csa
ON cs.id = csa.campingid
JOIN CampingAddition ca
ON csa.additionname = ca.[name]
LEFT JOIN Reservation r
	ON cs.id = r.campingid
WHERE ( (r.enddate IS NULL AND r.startdate IS NULL)
		OR ( (@today > R.enddate AND @today > R.startdate)
			OR (@today <= R.startdate AND @today < R.enddate AND checkin = 0)
		   )
		OR (r.enddate = @today AND r.checkout = 1)
		)
	AND ts.seasonname = dbo.GetSeasonName(@today, @today)
	AND cs.id IN ('73', '72', '70', '68', '67')
GROUP BY cs.id


SELECT @today, FORMAT(GETDATE(), 'yyyy-MM-dd')
END

BEGIN 
DECLARE @startdate DATE
	, @enddate DATE
	, @typename VARCHAR(40)
	, @start DATE
	, @end DATE

SET @startdate = '2021-06-14'
SET @enddate = '2021-06-19' 
SET @typename = 'Luksus hytte (4-6 pers)'
SET @end = @enddate
SET @start = @startdate

SELECT dbo.GetSeasonName(@startdate, @enddate)

SELECT s.*, ts.* --, SUM(ts.price)
	FROM TypeSeason ts
	JOIN Seasons s
		ON s.[name] = dbo.GetSeasonName(@startdate, @enddate)
	WHERE ts.typename = @typename AND ts.seasonname = s.[name]

SELECT SUM(ts.price)
	FROM Seasons s
	JOIN TypeSeason ts
		ON ts.seasonname = s.[name]
	WHERE ts.typename = @typename
		AND s.[name] = dbo.GetSeasonName(@startdate, @enddate)



END

DECLARE @string VARCHAR(max),
@string2 VARCHAR(max)

SET @string = 'Voksne.4,Børn.3,Smith.78,Jr.8'
--SELECT additions.value AS V1,
--	amount.value AS V2
--FROM STRING_SPLIT(@string, ',') additions, STRING_SPLIT(@string2, ',') amount

SELECT a.value
	, PARSENAME(a.value, 2) AS addition
	, PARSENAME(a.value, 1) AS amount
	,ads.seasonname
	,ads.price

FROM STRING_SPLIT(@string, ',') a
JOIN AdditionsSeason ads
	ON PARSENAME(a.value, 2) = ads.additionname
	AND ads.seasonname = dbo.GetSeasonName(@start, @end)


;WITH additionswithamount AS(
SELECT a.value
	, PARSENAME(a.value, 2) AS addition
	, PARSENAME(a.value, 1) AS amount
	,ads.seasonname
	,ads.price
FROM STRING_SPLIT(@string, ',') a
JOIN AdditionsSeason ads
	ON PARSENAME(a.value, 2) = ads.additionname
	AND ads.seasonname = dbo.GetSeasonName(@start, @end)
	)
	SELECT SUM(awa.amount * awa.price )
	FROM additionswithamount awa
SELECT *
FROM Additions

/*** TEST CreateReservation***/
BEGIN 
DECLARE @ID INT;
EXECUTE dbo.CreateReservation 'kasperjeppesen@hotmail.dk', '4', 'Efterår', '2021-08-15', '2021-10-31', NULL, @ReservationID = @ID OUTPUT;

SELECT @ID

SELECT * FROM [dbo].[GetAvaliableSites]('2021-07-06', '2021-07-16', 'Luksus hytte (4-6 pers)')

END
;
DECLARE @id VARCHAR(3)
SET @id ='H13'
IF EXISTS
	(
		SELECT * FROM dbo.GetAvaliableSites('2021-07-06', '2021-07-16', 'Luksus hytte (4-6 pers)') WHERE id = @id
	)
	BEGIN 
	PRINT 'VIRKER';
	END

ALTER TABLE Reservation 
ADD 
	CHECK(dbo.CheckIfTypenameIsValid(typename, campingid) = 1)