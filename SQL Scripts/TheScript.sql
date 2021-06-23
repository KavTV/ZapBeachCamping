CREATE TABLE AuditTable (
	Id INT IDENTITY(0,1) PRIMARY KEY,
	TableName VARCHAR(MAX) NOT NULL,
	UserName VARCHAR(MAX) NOT NULL,
	OldContent VARCHAR(MAX) NULL,
	NewContent VARCHAR(MAX) NOT NULL,
	[Time] DateTime DEFAULT GETDATE(),
	[Type] VARCHAR(MAX) NOT NULL,
	CHECK([Type] = 'Insert' OR [Type] = 'Update')
	);

CREATE TABLE CityCode (
    postal int NOT NULL PRIMARY KEY,
    city VARCHAR(60) NOT NULL,
);

CREATE TABLE Customer (
	email VARCHAR(30) NOT NULL,
	postal int NOT NULL,
	phone VARCHAR(20) NOT NULL,
	[name] VARCHAR(100) NOT NULL,
	[address] VARCHAR(255) NOT NULL,
	FOREIGN KEY (postal) REFERENCES CityCode(postal),
	PRIMARY KEY (email)
);

CREATE TABLE Additions (
	[name] VARCHAR(100) NOT NULL,
	paytype VARCHAR(20) NOT NULL,
-- Creat check
	PRIMARY KEY ([name])
);

CREATE TABLE Campingtype (
	[name] VARCHAR(30) NOT NULL PRIMARY KEY
);

CREATE TABLE CampingSite (
	id VARCHAR(3) NOT NULL PRIMARY KEY,
	clean BIT NOT NULL DEFAULT 0
);

CREATE TABLE CampingAddition (
	[name] VARCHAR(30) NOT NULL,
	price NUMERIC(8,2) NOT NULL,
	PRIMARY KEY ([name])
);

CREATE TABLE CampingSiteAdditions (
	additionname VARCHAR(100) NOT NULL,
	campingid VARCHAR(3) NOT NULL,
	PRIMARY KEY (additionname, campingid),
	FOREIGN KEY (additionname) REFERENCES CampingAddition([name]),
	FOREIGN KEY (campingid) REFERENCES CampingSite(id)
);

-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date, ,>
-- Description:	Check if the camping site containe the specific typename
-- =============================================
CREATE OR ALTER FUNCTION IsTypenameValid 
(
	-- Add the parameters for the function here
	@typename VARCHAR(30),
	@campingid VARCHAR(3)
)
RETURNS BIT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result BIT

	-- Add the T-SQL statements to compute the return value here
	IF EXISTS (SELECT * FROM CampingSiteTypes WHERE campingid = @campingid AND typename = @typename)
		SET @Result = 1;
		ELSE SET @Result = 0;
	
	-- Return the result of the function
	RETURN @Result

END
GO



CREATE TABLE Reservation (
	ordernumber INT IDENTITY(104829,69) NOT NULL,
	email VARCHAR(30) NOT NULL,
	campingid VARCHAR(3) NOT NULL,
	typename VARCHAR(30) NOT NULL,
	[startdate] DATE NOT NULL,
	enddate DATE NOT NULL,
	--computed total_price NUMERIC(8,2) NOT NULL,
	checkin BIT DEFAULT 0,
	checkout BIT DEFAULT 0,
	PRIMARY KEY (ordernumber),
	FOREIGN KEY (email) REFERENCES Customer(email) ON UPDATE CASCADE,
	FOREIGN KEY (campingid) REFERENCES CampingSite(id),
	FOREIGN KEY (typename) REFERENCES Campingtype([name]),
	CHECK([startdate] <= enddate),
	CHECK(dbo.IsTypenameValid(typename, campingid) = 1)
);

CREATE TABLE ReservationAddition (
	ordernumber int NOT NULL,
	additionname VARCHAR(100) NOT NULL,
	amount INT NOT NULL,
	PRIMARY KEY (ordernumber, additionname),
	FOREIGN KEY (additionname) REFERENCES Additions([name]) ON UPDATE CASCADE,
	FOREIGN KEY (ordernumber) REFERENCES Reservation(ordernumber) ON DELETE CASCADE,
	CONSTRAINT CHK_IsValid CHECK(dbo.IsReservationAdditionValid(ordernumber, additionname) = 1)
);

CREATE TABLE Seasons (
	[name] VARCHAR(40) NOT NULL,
	PRIMARY KEY ([name])
);

CREATE TABLE SeasonPeriods (
	[from] DATE NOT NULL,
	[to] DATE NOT NULL,
	SeasonName VARCHAR(40) NOT NULL,
	PRIMARY KEY([from], [to]),
	FOREIGN KEY (SeasonName) REFERENCES Seasons([name])
)

CREATE TABLE AdditionsSeason (
	additionname VARCHAR(100) NOT NULL,
	seasonname VARCHAR(40) NOT NULL,
	price NUMERIC(8,2) NOT NULL,
	PRIMARY KEY (additionname, seasonname),
	FOREIGN KEY (additionname) REFERENCES Additions([name]) ON UPDATE CASCADE,
	FOREIGN KEY (seasonname) REFERENCES Seasons([name])
);

CREATE TABLE TypeSeason (
	typename VARCHAR(30) NOT NULL,
	seasonname VARCHAR(40) NOT NULL,
	price NUMERIC(8,2) NOT NULL,
	PRIMARY KEY (typename, seasonname),
	FOREIGN KEY (typename) REFERENCES CampingType([name]),
	FOREIGN KEY (seasonname) REFERENCES Seasons([name])
);

CREATE TABLE CampingSiteTypes (
	campingid VARCHAR(3) NOT NULL,
	typename VARCHAR(30) NOT NULL,
	PRIMARY KEY (campingid,typename),
	FOREIGN KEY (campingid) REFERENCES CampingSite(id),
	FOREIGN KEY (typename) REFERENCES CampingType([name])
	
);

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER PROCEDURE CreateReservation
	-- Add the parameters for the stored procedure here
	@email VARCHAR(30),
	@campingid VARCHAR(3),
	@typename VARCHAR(30),
	@startdate DATE,
	@enddate DATE,
	@additionsandamount VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ordernumber INT
	--Check if startdate is in further
	
	IF(@startdate >= GETDATE())
	BEGIN
		--insert reservation and return ordernumber
		INSERT INTO Reservation(email,campingid,typename,startdate,enddate)
		VALUES(@email, @campingid, @typename, @startdate, @enddate)
		SET @ordernumber  = SCOPE_IDENTITY()
		--Insert additions to table 
		INSERT INTO ReservationAddition(ordernumber,additionname,amount)
		SELECT @ordernumber
			,PARSENAME(a.value, 2) AS additionname
			, PARSENAME(a.value, 1) AS amount
		FROM STRING_SPLIT(@additionsandamount, ',') a
		
	END
		ELSE 
		RAISERROR('Fejl',16,1);


END
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Inline Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date,,>
-- Description:	Get sites and types and prices
-- =============================================
CREATE OR ALTER FUNCTION GetAvaliableSites
(	
	-- Add the parameters for the function here
	@StartDate DATE,
	@EndDate DATE,
	@TypeName VARCHAR(30)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT cs.id
		, SUM(ISNULL(ca.price,0)+ISNULL(ts.price,0)) AS SitePrice
	FROM CampingSite cs
	JOIN CampingSiteTypes cst
	ON cs.id = cst.campingid
	JOIN TypeSeason ts
	ON cst.typename = ts.typename
	LEFT JOIN CampingSiteAdditions csa
	ON cs.id = csa.campingid
	LEFT JOIN CampingAddition ca
	ON csa.additionname = ca.[name]
	LEFT JOIN Reservation r
		ON cs.id = r.campingid
	WHERE ts.typename = @TypeName 
		AND ( (r.enddate IS NULL AND r.startdate IS NULL)
			OR ( (@EndDate > R.enddate AND @StartDate >= R.enddate)
				OR (@EndDate <= R.startdate AND @StartDate <R.startdate)
			   )
			)
		AND ts.seasonname = dbo.GetSeasonName(@StartDate, @EndDate)
	GROUP BY cs.id
)
GO



-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: 10-06-2021
-- Description:	Function to return season name
-- =============================================
CREATE OR ALTER FUNCTION GetSeasonName 
(
	-- Add the parameters for the function here
	@start DATE,
	@end DATE
)
RETURNS VARCHAR(40)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @seasonName VARCHAR(40)

	-- Add the T-SQL statements to compute the return value here
	
	SELECT TOP(1) @seasonName = [name]
	FROM Seasons
	WHERE (FORMAT(@start, 'Md') = FORMAT([from], 'Md') and FORMAT(@end, 'Md') = FORMAT([to], 'Md')) OR
		([name] NOT IN (
			'For�r'
			,'Vinter'
			,'Efter�r'
			,'Sommer')
			AND ((FORMAT(@start, 'Md') >= FORMAT([from], 'Md') AND FORMAT(@start, 'Md') <= FORMAT([to], 'Md'))
				OR (FORMAT(@end, 'Md')>= FORMAT([from], 'Md') and FORMAT(@end, 'Md') <= FORMAT([to], 'Md'))))
	ORDER BY 
		CASE
			WHEN DATEDIFF(DAY, @start, [to]) <=0 THEN DATEDIFF(DAY, [from], @end)
			ELSE DATEDIFF(DAY, @start, [to])
		END DESC
		
	-- Return the result of the function
	RETURN ISNULL(@seasonName,'Lavs�son') --If nothing match then its lavs�son

END
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION GetReservationTotalPrice
(
	-- Add the parameters for the function here
	@Campingid VARCHAR(3),
	@ordernumber int,
	@typename VARCHAR(30),
	@startdate DATE,
	@enddate DATE
)
RETURNS NUMERIC(8,2)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @TotalPrice NUMERIC(8,2)

	--First get Site addition price
	SELECT @TotalPrice += SUM(ca.price)
	FROM CampingAddition ca
	LEFT JOIN CampingSiteAdditions csa
		ON @Campingid = csa.campingid
		AND ca.name = csa.additionname

	--Second get site type price
	SELECT @TotalPrice += SUM(ts.price)
	FROM Seasons s
	JOIN TypeSeason ts
		ON ts.seasonname = s.[name]
	WHERE ts.typename = @typename
		AND s.[name] = dbo.GetSeasonName(@startdate, @enddate)

	--then get reservation additions price
	SELECT @TotalPrice += SUM(ads.price * ra.amount)
	FROM AdditionsSeason ads
	LEFT JOIN ReservationAddition ra
		ON ads.additionname = ra.additionname
		AND ra.ordernumber = @ordernumber
	WHERE ads.seasonname = dbo.GetSeasonName(@startdate, @enddate)


	-- Return the result of the function
	RETURN @TotalPrice;

END
GO

ALTER TABLE Reservation
ADD TotalPrice AS ([dbo].[GetReservationTotalPrice]([campingid],[ordernumber],[typename],[startdate],[enddate]))


INSERT INTO CityCode (postal, city) VALUES (555, 'Scanning');
INSERT INTO CityCode (postal, city) VALUES (783, 'Facility');
INSERT INTO CityCode (postal, city) VALUES (800, 'H�je Taastrup');
INSERT INTO CityCode (postal, city) VALUES (877, 'K�benhavn C');
INSERT INTO CityCode (postal, city) VALUES (892, 'Sj�lland USF P');
INSERT INTO CityCode (postal, city) VALUES (893, 'Sj�lland USF B');
INSERT INTO CityCode (postal, city) VALUES (894, 'Udbetaling');
INSERT INTO CityCode (postal, city) VALUES (899, 'Kommuneservice');
INSERT INTO CityCode (postal, city) VALUES (900, 'K�benhavn C');
INSERT INTO CityCode (postal, city) VALUES (910, 'K�benhavn C');
INSERT INTO CityCode (postal, city) VALUES (913, 'K�benhavns Pakkecenter');
INSERT INTO CityCode (postal, city) VALUES (914, 'K�benhavns Pakkecenter');
INSERT INTO CityCode (postal, city) VALUES (917, 'K�benhavns Pakkecenter');
INSERT INTO CityCode (postal, city) VALUES (918, 'K�benhavns Pakke BRC');
INSERT INTO CityCode (postal, city) VALUES (919, 'Returprint BRC');
INSERT INTO CityCode (postal, city) VALUES (929, 'K�benhavn C');
INSERT INTO CityCode (postal, city) VALUES (960, 'Internationalt Postcenter');
INSERT INTO CityCode (postal, city) VALUES (999, 'K�benhavn C');
INSERT INTO CityCode (postal, city) VALUES (1001, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1002, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1003, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1004, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1005, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1006, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1007, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1008, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1009, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1010, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1011, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1012, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1013, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1014, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1015, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1016, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1017, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1018, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1019, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1020, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1021, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1022, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1023, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1024, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1025, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1026, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1045, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1050, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1051, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1052, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1053, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1054, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1055, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1056, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1057, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1058, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1059, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1060, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1061, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1062, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1063, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1064, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1065, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1066, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1067, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1068, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1069, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1070, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1071, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1072, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1073, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1074, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1092, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1093, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1095, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1098, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1100, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1101, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1102, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1103, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1104, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1105, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1106, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1107, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1110, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1111, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1112, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1113, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1114, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1115, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1116, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1117, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1118, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1119, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1120, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1121, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1122, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1123, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1124, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1125, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1126, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1127, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1128, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1129, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1130, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1131, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1140, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1147, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1148, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1150, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1151, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1152, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1153, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1154, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1155, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1156, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1157, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1158, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1159, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1160, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1161, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1162, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1164, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1165, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1166, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1167, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1168, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1169, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1170, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1171, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1172, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1173, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1174, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1175, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1200, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1201, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1202, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1203, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1204, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1205, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1206, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1207, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1208, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1209, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1210, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1211, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1212, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1213, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1214, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1215, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1216, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1217, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1218, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1219, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1220, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1221, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1240, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1250, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1251, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1252, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1253, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1254, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1255, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1256, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1257, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1260, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1261, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1263, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1264, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1265, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1266, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1267, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1268, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1270, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1271, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1300, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1301, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1302, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1303, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1304, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1306, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1307, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1308, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1309, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1310, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1311, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1312, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1313, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1314, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1315, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1316, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1317, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1318, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1319, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1320, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1321, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1322, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1323, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1324, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1325, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1326, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1327, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1328, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1329, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1350, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1352, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1353, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1354, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1355, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1356, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1357, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1358, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1359, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1360, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1361, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1362, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1363, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1364, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1365, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1366, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1367, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1368, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1369, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1370, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1371, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1400, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1401, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1402, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1403, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1406, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1407, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1408, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1409, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1410, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1411, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1412, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1413, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1414, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1415, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1416, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1417, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1418, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1419, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1420, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1421, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1422, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1423, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1424, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1425, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1426, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1427, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1428, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1429, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1430, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1432, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1433, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1434, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1435, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1436, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1437, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1438, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1439, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1440, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1441, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1448, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1450, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1451, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1452, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1453, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1454, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1455, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1456, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1457, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1458, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1459, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1460, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1461, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1462, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1463, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1464, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1465, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1466, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1467, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1468, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1470, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1471, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1472, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1473, 'K�benhavn K');
INSERT INTO CityCode (postal, city) VALUES (1500, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1501, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1502, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1503, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1504, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1505, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1506, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1507, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1508, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1509, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1510, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1512, 'Returpost');
INSERT INTO CityCode (postal, city) VALUES (1513, 'Flytninger og Nejtak');
INSERT INTO CityCode (postal, city) VALUES (1532, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1533, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1550, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1551, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1552, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1553, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1554, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1555, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1556, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1557, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1558, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1559, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1560, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1561, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1562, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1563, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1564, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1567, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1568, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1569, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1570, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1571, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1572, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1573, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1574, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1575, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1576, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1577, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1592, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1599, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1600, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1601, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1602, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1603, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1604, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1605, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1606, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1607, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1608, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1609, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1610, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1611, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1612, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1613, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1614, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1615, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1616, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1617, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1618, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1619, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1620, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1621, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1622, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1623, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1624, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1630, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1631, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1632, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1633, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1634, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1635, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1650, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1651, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1652, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1653, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1654, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1655, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1656, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1657, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1658, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1659, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1660, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1661, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1662, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1663, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1664, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1665, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1666, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1667, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1668, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1669, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1670, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1671, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1672, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1673, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1674, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1675, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1676, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1677, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1699, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1700, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1701, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1702, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1703, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1704, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1705, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1706, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1707, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1708, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1709, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1710, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1711, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1712, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1714, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1715, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1716, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1717, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1718, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1719, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1720, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1721, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1722, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1723, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1724, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1725, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1726, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1727, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1728, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1729, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1730, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1731, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1732, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1733, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1734, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1735, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1736, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1737, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1738, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1739, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1749, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1750, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1751, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1752, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1753, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1754, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1755, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1756, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1757, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1758, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1759, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1760, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1761, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1762, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1763, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1764, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1765, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1766, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1770, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1771, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1772, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1773, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1774, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1775, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1777, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1780, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1782, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1785, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1786, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1787, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1790, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1799, 'K�benhavn V');
INSERT INTO CityCode (postal, city) VALUES (1800, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1801, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1802, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1803, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1804, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1805, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1806, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1807, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1808, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1809, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1810, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1811, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1812, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1813, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1814, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1815, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1816, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1817, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1818, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1819, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1820, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1822, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1823, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1824, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1825, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1826, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1827, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1828, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1829, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1835, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1850, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1851, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1852, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1853, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1854, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1855, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1856, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1857, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1860, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1861, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1862, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1863, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1864, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1865, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1866, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1867, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1868, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1870, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1871, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1872, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1873, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1874, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1875, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1876, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1877, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1878, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1879, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1900, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1901, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1902, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1903, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1904, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1905, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1906, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1908, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1909, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1910, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1911, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1912, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1913, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1914, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1915, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1916, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1917, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1920, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1921, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1922, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1923, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1924, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1925, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1926, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1927, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1928, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1931, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1950, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1951, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1952, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1953, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1954, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1955, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1956, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1957, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1958, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1959, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1960, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1961, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1962, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1963, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1964, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1965, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1966, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1967, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1970, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1971, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1972, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1973, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (1974, 'Frederiksberg C');
INSERT INTO CityCode (postal, city) VALUES (2000, 'Frederiksberg');
INSERT INTO CityCode (postal, city) VALUES (2100, 'K�benhavn �');
INSERT INTO CityCode (postal, city) VALUES (2150, 'Nordhavn');
INSERT INTO CityCode (postal, city) VALUES (2200, 'K�benhavn ');
INSERT INTO CityCode (postal, city) VALUES (2300, 'K�benhavn S');
INSERT INTO CityCode (postal, city) VALUES (2400, 'K�benhavn NV');
INSERT INTO CityCode (postal, city) VALUES (2412, 'Gr�nland');
INSERT INTO CityCode (postal, city) VALUES (2450, 'K�benhavn SV');
INSERT INTO CityCode (postal, city) VALUES (2500, 'Valby');
INSERT INTO CityCode (postal, city) VALUES (2600, 'Glostrup');
INSERT INTO CityCode (postal, city) VALUES (2605, 'Br�ndby');
INSERT INTO CityCode (postal, city) VALUES (2610, 'R�dovre');
INSERT INTO CityCode (postal, city) VALUES (2620, 'Albertslund');
INSERT INTO CityCode (postal, city) VALUES (2625, 'Vallensb�k');
INSERT INTO CityCode (postal, city) VALUES (2630, 'Taastrup');
INSERT INTO CityCode (postal, city) VALUES (2635, 'Ish�j');
INSERT INTO CityCode (postal, city) VALUES (2640, 'Hedehusene');
INSERT INTO CityCode (postal, city) VALUES (2650, 'Hvidovre');
INSERT INTO CityCode (postal, city) VALUES (2660, 'Br�ndby Strand');
INSERT INTO CityCode (postal, city) VALUES (2665, 'Vallensb�k Strand');
INSERT INTO CityCode (postal, city) VALUES (2670, 'Greve');
INSERT INTO CityCode (postal, city) VALUES (2680, 'Solr�d Strand');
INSERT INTO CityCode (postal, city) VALUES (2690, 'Karlslunde');
INSERT INTO CityCode (postal, city) VALUES (2700, 'Br�nsh�j');
INSERT INTO CityCode (postal, city) VALUES (2720, 'Vanl�se');
INSERT INTO CityCode (postal, city) VALUES (2730, 'Herlev');
INSERT INTO CityCode (postal, city) VALUES (2740, 'Skovlunde');
INSERT INTO CityCode (postal, city) VALUES (2750, 'Ballerup');
INSERT INTO CityCode (postal, city) VALUES (2760, 'M�l�v');
INSERT INTO CityCode (postal, city) VALUES (2765, 'Sm�rum');
INSERT INTO CityCode (postal, city) VALUES (2770, 'Kastrup');
INSERT INTO CityCode (postal, city) VALUES (2791, 'Drag�r');
INSERT INTO CityCode (postal, city) VALUES (2800, 'Kongens Lyngby');
INSERT INTO CityCode (postal, city) VALUES (2820, 'Gentofte');
INSERT INTO CityCode (postal, city) VALUES (2830, 'Virum');
INSERT INTO CityCode (postal, city) VALUES (2840, 'Holte');
INSERT INTO CityCode (postal, city) VALUES (2850, 'N�rum');
INSERT INTO CityCode (postal, city) VALUES (2860, 'S�borg');
INSERT INTO CityCode (postal, city) VALUES (2870, 'Dysseg�rd');
INSERT INTO CityCode (postal, city) VALUES (2880, 'Bagsv�rd');
INSERT INTO CityCode (postal, city) VALUES (2900, 'Hellerup');
INSERT INTO CityCode (postal, city) VALUES (2920, 'Charlottenlund');
INSERT INTO CityCode (postal, city) VALUES (2930, 'Klampenborg');
INSERT INTO CityCode (postal, city) VALUES (2942, 'Skodsborg');
INSERT INTO CityCode (postal, city) VALUES (2950, 'Vedb�k');
INSERT INTO CityCode (postal, city) VALUES (2960, 'Rungsted Kyst');
INSERT INTO CityCode (postal, city) VALUES (2970, 'H�rsholm');
INSERT INTO CityCode (postal, city) VALUES (2980, 'Kokkedal');
INSERT INTO CityCode (postal, city) VALUES (2990, 'Niv�');
INSERT INTO CityCode (postal, city) VALUES (3000, 'Helsing�r');
INSERT INTO CityCode (postal, city) VALUES (3050, 'Humleb�k');
INSERT INTO CityCode (postal, city) VALUES (3060, 'Esperg�rde');
INSERT INTO CityCode (postal, city) VALUES (3070, 'Snekkersten');
INSERT INTO CityCode (postal, city) VALUES (3080, 'Tik�b');
INSERT INTO CityCode (postal, city) VALUES (3100, 'Hornb�k');
INSERT INTO CityCode (postal, city) VALUES (3120, 'Dronningm�lle');
INSERT INTO CityCode (postal, city) VALUES (3140, '�lsg�rde');
INSERT INTO CityCode (postal, city) VALUES (3150, 'Helleb�k');
INSERT INTO CityCode (postal, city) VALUES (3200, 'Helsinge');
INSERT INTO CityCode (postal, city) VALUES (3210, 'Vejby');
INSERT INTO CityCode (postal, city) VALUES (3220, 'Tisvildeleje');
INSERT INTO CityCode (postal, city) VALUES (3230, 'Gr�sted');
INSERT INTO CityCode (postal, city) VALUES (3250, 'Gilleleje');
INSERT INTO CityCode (postal, city) VALUES (3300, 'Frederiksv�rk');
INSERT INTO CityCode (postal, city) VALUES (3310, '�lsted');
INSERT INTO CityCode (postal, city) VALUES (3320, 'Sk�vinge');
INSERT INTO CityCode (postal, city) VALUES (3330, 'G�rl�se');
INSERT INTO CityCode (postal, city) VALUES (3360, 'Liseleje');
INSERT INTO CityCode (postal, city) VALUES (3370, 'Melby');
INSERT INTO CityCode (postal, city) VALUES (3390, 'Hundested');
INSERT INTO CityCode (postal, city) VALUES (3400, 'Hiller�d');
INSERT INTO CityCode (postal, city) VALUES (3450, 'Aller�d');
INSERT INTO CityCode (postal, city) VALUES (3460, 'Birker�d');
INSERT INTO CityCode (postal, city) VALUES (3480, 'Fredensborg');
INSERT INTO CityCode (postal, city) VALUES (3490, 'Kvistg�rd');
INSERT INTO CityCode (postal, city) VALUES (3500, 'V�rl�se');
INSERT INTO CityCode (postal, city) VALUES (3520, 'Farum');
INSERT INTO CityCode (postal, city) VALUES (3540, 'Lynge');
INSERT INTO CityCode (postal, city) VALUES (3550, 'Slangerup');
INSERT INTO CityCode (postal, city) VALUES (3600, 'Frederikssund');
INSERT INTO CityCode (postal, city) VALUES (3630, 'J�gerspris');
INSERT INTO CityCode (postal, city) VALUES (3650, '�lstykke');
INSERT INTO CityCode (postal, city) VALUES (3660, 'Stenl�se');
INSERT INTO CityCode (postal, city) VALUES (3670, 'Veks� Sj�lland');
INSERT INTO CityCode (postal, city) VALUES (3700, 'R�nne');
INSERT INTO CityCode (postal, city) VALUES (3720, 'Aakirkeby');
INSERT INTO CityCode (postal, city) VALUES (3730, 'Nex�');
INSERT INTO CityCode (postal, city) VALUES (3740, 'Svaneke');
INSERT INTO CityCode (postal, city) VALUES (3751, '�stermarie');
INSERT INTO CityCode (postal, city) VALUES (3760, 'Gudhjem');
INSERT INTO CityCode (postal, city) VALUES (3770, 'Allinge');
INSERT INTO CityCode (postal, city) VALUES (3782, 'Klemensker');
INSERT INTO CityCode (postal, city) VALUES (3790, 'Hasle');
INSERT INTO CityCode (postal, city) VALUES (4000, 'Roskilde');
INSERT INTO CityCode (postal, city) VALUES (4030, 'Tune');
INSERT INTO CityCode (postal, city) VALUES (4040, 'Jyllinge');
INSERT INTO CityCode (postal, city) VALUES (4050, 'Skibby');
INSERT INTO CityCode (postal, city) VALUES (4060, 'Kirke S�by');
INSERT INTO CityCode (postal, city) VALUES (4070, 'Kirke Hyllinge');
INSERT INTO CityCode (postal, city) VALUES (4100, 'Ringsted');
INSERT INTO CityCode (postal, city) VALUES (4129, 'Ringsted');
INSERT INTO CityCode (postal, city) VALUES (4130, 'Viby Sj�lland');
INSERT INTO CityCode (postal, city) VALUES (4140, 'Borup');
INSERT INTO CityCode (postal, city) VALUES (4160, 'Herlufmagle');
INSERT INTO CityCode (postal, city) VALUES (4171, 'Glums�');
INSERT INTO CityCode (postal, city) VALUES (4173, 'Fjenneslev');
INSERT INTO CityCode (postal, city) VALUES (4174, 'Jystrup Midtsj');
INSERT INTO CityCode (postal, city) VALUES (4180, 'Sor�');
INSERT INTO CityCode (postal, city) VALUES (4190, 'Munke Bjergby');
INSERT INTO CityCode (postal, city) VALUES (4200, 'Slagelse');
INSERT INTO CityCode (postal, city) VALUES (4220, 'Kors�r');
INSERT INTO CityCode (postal, city) VALUES (4230, 'Sk�lsk�r');
INSERT INTO CityCode (postal, city) VALUES (4241, 'Vemmelev');
INSERT INTO CityCode (postal, city) VALUES (4242, 'Boeslunde');
INSERT INTO CityCode (postal, city) VALUES (4243, 'Rude');
INSERT INTO CityCode (postal, city) VALUES (4244, 'Agers�');
INSERT INTO CityCode (postal, city) VALUES (4245, 'Om�');
INSERT INTO CityCode (postal, city) VALUES (4250, 'Fuglebjerg');
INSERT INTO CityCode (postal, city) VALUES (4261, 'Dalmose');
INSERT INTO CityCode (postal, city) VALUES (4262, 'Sandved');
INSERT INTO CityCode (postal, city) VALUES (4270, 'H�ng');
INSERT INTO CityCode (postal, city) VALUES (4281, 'G�rlev');
INSERT INTO CityCode (postal, city) VALUES (4291, 'Ruds Vedby');
INSERT INTO CityCode (postal, city) VALUES (4293, 'Dianalund');
INSERT INTO CityCode (postal, city) VALUES (4295, 'Stenlille');
INSERT INTO CityCode (postal, city) VALUES (4296, 'Nyrup');
INSERT INTO CityCode (postal, city) VALUES (4300, 'Holb�k');
INSERT INTO CityCode (postal, city) VALUES (4305, 'Or�');
INSERT INTO CityCode (postal, city) VALUES (4320, 'Lejre');
INSERT INTO CityCode (postal, city) VALUES (4330, 'Hvals�');
INSERT INTO CityCode (postal, city) VALUES (4340, 'T�ll�se');
INSERT INTO CityCode (postal, city) VALUES (4350, 'Ugerl�se');
INSERT INTO CityCode (postal, city) VALUES (4360, 'Kirke Eskilstrup');
INSERT INTO CityCode (postal, city) VALUES (4370, 'Store Merl�se');
INSERT INTO CityCode (postal, city) VALUES (4390, 'Vipper�d');
INSERT INTO CityCode (postal, city) VALUES (4400, 'Kalundborg');
INSERT INTO CityCode (postal, city) VALUES (4420, 'Regstrup');
INSERT INTO CityCode (postal, city) VALUES (4440, 'M�rk�v');
INSERT INTO CityCode (postal, city) VALUES (4450, 'Jyderup');
INSERT INTO CityCode (postal, city) VALUES (4460, 'Snertinge');
INSERT INTO CityCode (postal, city) VALUES (4470, 'Sveb�lle');
INSERT INTO CityCode (postal, city) VALUES (4480, 'Store Fuglede');
INSERT INTO CityCode (postal, city) VALUES (4490, 'Jerslev Sj�lland');
INSERT INTO CityCode (postal, city) VALUES (4500, 'Nyk�bing Sj');
INSERT INTO CityCode (postal, city) VALUES (4520, 'Svinninge');
INSERT INTO CityCode (postal, city) VALUES (4532, 'Gislinge');
INSERT INTO CityCode (postal, city) VALUES (4534, 'H�rve');
INSERT INTO CityCode (postal, city) VALUES (4540, 'F�revejle');
INSERT INTO CityCode (postal, city) VALUES (4550, 'Asn�s');
INSERT INTO CityCode (postal, city) VALUES (4560, 'Vig');
INSERT INTO CityCode (postal, city) VALUES (4571, 'Grevinge');
INSERT INTO CityCode (postal, city) VALUES (4572, 'N�rre Asmindrup');
INSERT INTO CityCode (postal, city) VALUES (4573, 'H�jby');
INSERT INTO CityCode (postal, city) VALUES (4581, 'R�rvig');
INSERT INTO CityCode (postal, city) VALUES (4583, 'Sj�llands Odde');
INSERT INTO CityCode (postal, city) VALUES (4591, 'F�llenslev');
INSERT INTO CityCode (postal, city) VALUES (4592, 'Sejer�');
INSERT INTO CityCode (postal, city) VALUES (4593, 'Eskebjerg');
INSERT INTO CityCode (postal, city) VALUES (4600, 'K�ge');
INSERT INTO CityCode (postal, city) VALUES (4621, 'Gadstrup');
INSERT INTO CityCode (postal, city) VALUES (4622, 'Havdrup');
INSERT INTO CityCode (postal, city) VALUES (4623, 'Lille Skensved');
INSERT INTO CityCode (postal, city) VALUES (4632, 'Bj�verskov');
INSERT INTO CityCode (postal, city) VALUES (4640, 'Faxe');
INSERT INTO CityCode (postal, city) VALUES (4652, 'H�rlev');
INSERT INTO CityCode (postal, city) VALUES (4653, 'Karise');
INSERT INTO CityCode (postal, city) VALUES (4654, 'Faxe Ladeplads');
INSERT INTO CityCode (postal, city) VALUES (4660, 'Store Heddinge');
INSERT INTO CityCode (postal, city) VALUES (4671, 'Str�by');
INSERT INTO CityCode (postal, city) VALUES (4672, 'Klippinge');
INSERT INTO CityCode (postal, city) VALUES (4673, 'R�dvig Stevns');
INSERT INTO CityCode (postal, city) VALUES (4681, 'Herf�lge');
INSERT INTO CityCode (postal, city) VALUES (4682, 'Tureby');
INSERT INTO CityCode (postal, city) VALUES (4683, 'R�nnede');
INSERT INTO CityCode (postal, city) VALUES (4684, 'Holmegaard');
INSERT INTO CityCode (postal, city) VALUES (4690, 'Haslev');
INSERT INTO CityCode (postal, city) VALUES (4700, 'N�stved');
INSERT INTO CityCode (postal, city) VALUES (4720, 'Pr�st�');
INSERT INTO CityCode (postal, city) VALUES (4733, 'Tappern�je');
INSERT INTO CityCode (postal, city) VALUES (4735, 'Mern');
INSERT INTO CityCode (postal, city) VALUES (4736, 'Karreb�ksminde');
INSERT INTO CityCode (postal, city) VALUES (4750, 'Lundby');
INSERT INTO CityCode (postal, city) VALUES (4760, 'Vordingborg');
INSERT INTO CityCode (postal, city) VALUES (4771, 'Kalvehave');
INSERT INTO CityCode (postal, city) VALUES (4772, 'Langeb�k');
INSERT INTO CityCode (postal, city) VALUES (4773, 'Stensved');
INSERT INTO CityCode (postal, city) VALUES (4780, 'Stege');
INSERT INTO CityCode (postal, city) VALUES (4791, 'Borre');
INSERT INTO CityCode (postal, city) VALUES (4792, 'Askeby');
INSERT INTO CityCode (postal, city) VALUES (4793, 'Bog� By');
INSERT INTO CityCode (postal, city) VALUES (4800, 'Nyk�bing F');
INSERT INTO CityCode (postal, city) VALUES (4840, 'N�rre Alslev');
INSERT INTO CityCode (postal, city) VALUES (4850, 'Stubbek�bing');
INSERT INTO CityCode (postal, city) VALUES (4862, 'Guldborg');
INSERT INTO CityCode (postal, city) VALUES (4863, 'Eskilstrup');
INSERT INTO CityCode (postal, city) VALUES (4871, 'Horbelev');
INSERT INTO CityCode (postal, city) VALUES (4872, 'Idestrup');
INSERT INTO CityCode (postal, city) VALUES (4873, 'V�ggerl�se');
INSERT INTO CityCode (postal, city) VALUES (4874, 'Gedser');
INSERT INTO CityCode (postal, city) VALUES (4880, 'Nysted');
INSERT INTO CityCode (postal, city) VALUES (4891, 'Toreby L');
INSERT INTO CityCode (postal, city) VALUES (4892, 'Kettinge');
INSERT INTO CityCode (postal, city) VALUES (4894, '�ster Ulslev');
INSERT INTO CityCode (postal, city) VALUES (4895, 'Errindlev');
INSERT INTO CityCode (postal, city) VALUES (4900, 'Nakskov');
INSERT INTO CityCode (postal, city) VALUES (4912, 'Harpelunde');
INSERT INTO CityCode (postal, city) VALUES (4913, 'Horslunde');
INSERT INTO CityCode (postal, city) VALUES (4920, 'S�llested');
INSERT INTO CityCode (postal, city) VALUES (4930, 'Maribo');
INSERT INTO CityCode (postal, city) VALUES (4941, 'Bandholm');
INSERT INTO CityCode (postal, city) VALUES (4942, 'Ask� og Lille�');
INSERT INTO CityCode (postal, city) VALUES (4943, 'Torrig L');
INSERT INTO CityCode (postal, city) VALUES (4944, 'Fej�');
INSERT INTO CityCode (postal, city) VALUES (4945, 'Fem�');
INSERT INTO CityCode (postal, city) VALUES (4951, 'N�rreballe');
INSERT INTO CityCode (postal, city) VALUES (4952, 'Stokkemarke');
INSERT INTO CityCode (postal, city) VALUES (4953, 'Vesterborg');
INSERT INTO CityCode (postal, city) VALUES (4960, 'Holeby');
INSERT INTO CityCode (postal, city) VALUES (4970, 'R�dby');
INSERT INTO CityCode (postal, city) VALUES (4983, 'Dannemare');
INSERT INTO CityCode (postal, city) VALUES (4990, 'Saksk�bing');
INSERT INTO CityCode (postal, city) VALUES (4992, 'Midtsj�lland USF P');
INSERT INTO CityCode (postal, city) VALUES (5000, 'Odense C');
INSERT INTO CityCode (postal, city) VALUES (5029, 'Odense C');
INSERT INTO CityCode (postal, city) VALUES (5100, 'Odense C');
INSERT INTO CityCode (postal, city) VALUES (5200, 'Odense V');
INSERT INTO CityCode (postal, city) VALUES (5210, 'Odense NV');
INSERT INTO CityCode (postal, city) VALUES (5220, 'Odense S�');
INSERT INTO CityCode (postal, city) VALUES (5230, 'Odense M');
INSERT INTO CityCode (postal, city) VALUES (5240, 'Odense N�');
INSERT INTO CityCode (postal, city) VALUES (5250, 'Odense SV');
INSERT INTO CityCode (postal, city) VALUES (5260, 'Odense S');
INSERT INTO CityCode (postal, city) VALUES (5270, 'Odense ');
INSERT INTO CityCode (postal, city) VALUES (5290, 'Marslev');
INSERT INTO CityCode (postal, city) VALUES (5300, 'Kerteminde');
INSERT INTO CityCode (postal, city) VALUES (5320, 'Agedrup');
INSERT INTO CityCode (postal, city) VALUES (5330, 'Munkebo');
INSERT INTO CityCode (postal, city) VALUES (5350, 'Rynkeby');
INSERT INTO CityCode (postal, city) VALUES (5370, 'Mesinge');
INSERT INTO CityCode (postal, city) VALUES (5380, 'Dalby');
INSERT INTO CityCode (postal, city) VALUES (5390, 'Martofte');
INSERT INTO CityCode (postal, city) VALUES (5400, 'Bogense');
INSERT INTO CityCode (postal, city) VALUES (5450, 'Otterup');
INSERT INTO CityCode (postal, city) VALUES (5462, 'Morud');
INSERT INTO CityCode (postal, city) VALUES (5463, 'Harndrup');
INSERT INTO CityCode (postal, city) VALUES (5464, 'Brenderup Fyn');
INSERT INTO CityCode (postal, city) VALUES (5466, 'Asperup');
INSERT INTO CityCode (postal, city) VALUES (5471, 'S�nders�');
INSERT INTO CityCode (postal, city) VALUES (5474, 'Veflinge');
INSERT INTO CityCode (postal, city) VALUES (5485, 'Skamby');
INSERT INTO CityCode (postal, city) VALUES (5491, 'Blommenslyst');
INSERT INTO CityCode (postal, city) VALUES (5492, 'Vissenbjerg');
INSERT INTO CityCode (postal, city) VALUES (5500, 'Middelfart');
INSERT INTO CityCode (postal, city) VALUES (5540, 'Ullerslev');
INSERT INTO CityCode (postal, city) VALUES (5550, 'Langeskov');
INSERT INTO CityCode (postal, city) VALUES (5560, 'Aarup');
INSERT INTO CityCode (postal, city) VALUES (5580, 'N�rre Aaby');
INSERT INTO CityCode (postal, city) VALUES (5591, 'Gelsted');
INSERT INTO CityCode (postal, city) VALUES (5592, 'Ejby');
INSERT INTO CityCode (postal, city) VALUES (5600, 'Faaborg');
INSERT INTO CityCode (postal, city) VALUES (5601, 'Ly�');
INSERT INTO CityCode (postal, city) VALUES (5602, 'Avernak�');
INSERT INTO CityCode (postal, city) VALUES (5603, 'Bj�rn�');
INSERT INTO CityCode (postal, city) VALUES (5610, 'Assens');
INSERT INTO CityCode (postal, city) VALUES (5620, 'Glamsbjerg');
INSERT INTO CityCode (postal, city) VALUES (5631, 'Ebberup');
INSERT INTO CityCode (postal, city) VALUES (5642, 'Millinge');
INSERT INTO CityCode (postal, city) VALUES (5672, 'Broby');
INSERT INTO CityCode (postal, city) VALUES (5683, 'Haarby');
INSERT INTO CityCode (postal, city) VALUES (5690, 'Tommerup');
INSERT INTO CityCode (postal, city) VALUES (5700, 'Svendborg');
INSERT INTO CityCode (postal, city) VALUES (5750, 'Ringe');
INSERT INTO CityCode (postal, city) VALUES (5762, 'Vester Skerninge');
INSERT INTO CityCode (postal, city) VALUES (5771, 'Stenstrup');
INSERT INTO CityCode (postal, city) VALUES (5772, 'Kv�rndrup');
INSERT INTO CityCode (postal, city) VALUES (5792, '�rslev');
INSERT INTO CityCode (postal, city) VALUES (5800, 'Nyborg');
INSERT INTO CityCode (postal, city) VALUES (5853, '�rb�k');
INSERT INTO CityCode (postal, city) VALUES (5854, 'Gislev');
INSERT INTO CityCode (postal, city) VALUES (5856, 'Ryslinge');
INSERT INTO CityCode (postal, city) VALUES (5863, 'Ferritslev Fyn');
INSERT INTO CityCode (postal, city) VALUES (5871, 'Fr�rup');
INSERT INTO CityCode (postal, city) VALUES (5874, 'Hesselager');
INSERT INTO CityCode (postal, city) VALUES (5881, 'Sk�rup Fyn');
INSERT INTO CityCode (postal, city) VALUES (5882, 'Vejstrup');
INSERT INTO CityCode (postal, city) VALUES (5883, 'Oure');
INSERT INTO CityCode (postal, city) VALUES (5884, 'Gudme');
INSERT INTO CityCode (postal, city) VALUES (5892, 'Gudbjerg Sydfyn');
INSERT INTO CityCode (postal, city) VALUES (5900, 'Rudk�bing');
INSERT INTO CityCode (postal, city) VALUES (5932, 'Humble');
INSERT INTO CityCode (postal, city) VALUES (5935, 'Bagenkop');
INSERT INTO CityCode (postal, city) VALUES (5943, 'Stryn�');
INSERT INTO CityCode (postal, city) VALUES (5953, 'Tranek�r');
INSERT INTO CityCode (postal, city) VALUES (5960, 'Marstal');
INSERT INTO CityCode (postal, city) VALUES (5965, 'Birkholm');
INSERT INTO CityCode (postal, city) VALUES (5970, '�r�sk�bing');
INSERT INTO CityCode (postal, city) VALUES (5985, 'S�by �r�');
INSERT INTO CityCode (postal, city) VALUES (6000, 'Kolding');
INSERT INTO CityCode (postal, city) VALUES (6040, 'Egtved');
INSERT INTO CityCode (postal, city) VALUES (6051, 'Almind');
INSERT INTO CityCode (postal, city) VALUES (6052, 'Viuf');
INSERT INTO CityCode (postal, city) VALUES (6064, 'Jordrup');
INSERT INTO CityCode (postal, city) VALUES (6070, 'Christiansfeld');
INSERT INTO CityCode (postal, city) VALUES (6091, 'Bjert');
INSERT INTO CityCode (postal, city) VALUES (6092, 'S�nder Stenderup');
INSERT INTO CityCode (postal, city) VALUES (6093, 'Sj�lund');
INSERT INTO CityCode (postal, city) VALUES (6094, 'Hejls');
INSERT INTO CityCode (postal, city) VALUES (6100, 'Haderslev');
INSERT INTO CityCode (postal, city) VALUES (6200, 'Aabenraa');
INSERT INTO CityCode (postal, city) VALUES (6210, 'Bars�');
INSERT INTO CityCode (postal, city) VALUES (6230, 'R�dekro');
INSERT INTO CityCode (postal, city) VALUES (6240, 'L�gumkloster');
INSERT INTO CityCode (postal, city) VALUES (6261, 'Bredebro');
INSERT INTO CityCode (postal, city) VALUES (6270, 'T�nder');
INSERT INTO CityCode (postal, city) VALUES (6280, 'H�jer');
INSERT INTO CityCode (postal, city) VALUES (6300, 'Gr�sten');
INSERT INTO CityCode (postal, city) VALUES (6310, 'Broager');
INSERT INTO CityCode (postal, city) VALUES (6320, 'Egernsund');
INSERT INTO CityCode (postal, city) VALUES (6330, 'Padborg');
INSERT INTO CityCode (postal, city) VALUES (6340, 'Krus�');
INSERT INTO CityCode (postal, city) VALUES (6360, 'Tinglev');
INSERT INTO CityCode (postal, city) VALUES (6372, 'Bylderup-Bov');
INSERT INTO CityCode (postal, city) VALUES (6392, 'Bolderslev');
INSERT INTO CityCode (postal, city) VALUES (6400, 'S�nderborg');
INSERT INTO CityCode (postal, city) VALUES (6430, 'Nordborg');
INSERT INTO CityCode (postal, city) VALUES (6440, 'Augustenborg');
INSERT INTO CityCode (postal, city) VALUES (6470, 'Sydals');
INSERT INTO CityCode (postal, city) VALUES (6500, 'Vojens');
INSERT INTO CityCode (postal, city) VALUES (6510, 'Gram');
INSERT INTO CityCode (postal, city) VALUES (6520, 'Toftlund');
INSERT INTO CityCode (postal, city) VALUES (6534, 'Agerskov');
INSERT INTO CityCode (postal, city) VALUES (6535, 'Branderup J');
INSERT INTO CityCode (postal, city) VALUES (6541, 'Bevtoft');
INSERT INTO CityCode (postal, city) VALUES (6560, 'Sommersted');
INSERT INTO CityCode (postal, city) VALUES (6580, 'Vamdrup');
INSERT INTO CityCode (postal, city) VALUES (6600, 'Vejen');
INSERT INTO CityCode (postal, city) VALUES (6621, 'Gesten');
INSERT INTO CityCode (postal, city) VALUES (6622, 'B�kke');
INSERT INTO CityCode (postal, city) VALUES (6623, 'Vorbasse');
INSERT INTO CityCode (postal, city) VALUES (6630, 'R�dding');
INSERT INTO CityCode (postal, city) VALUES (6640, 'Lunderskov');
INSERT INTO CityCode (postal, city) VALUES (6650, 'Br�rup');
INSERT INTO CityCode (postal, city) VALUES (6660, 'Lintrup');
INSERT INTO CityCode (postal, city) VALUES (6670, 'Holsted');
INSERT INTO CityCode (postal, city) VALUES (6682, 'Hovborg');
INSERT INTO CityCode (postal, city) VALUES (6683, 'F�vling');
INSERT INTO CityCode (postal, city) VALUES (6690, 'G�rding');
INSERT INTO CityCode (postal, city) VALUES (6700, 'Esbjerg');
INSERT INTO CityCode (postal, city) VALUES (6701, 'Esbjerg');
INSERT INTO CityCode (postal, city) VALUES (6705, 'Esbjerg �');
INSERT INTO CityCode (postal, city) VALUES (6710, 'Esbjerg V');
INSERT INTO CityCode (postal, city) VALUES (6715, 'Esbjerg ');
INSERT INTO CityCode (postal, city) VALUES (6720, 'Fan�');
INSERT INTO CityCode (postal, city) VALUES (6731, 'Tj�reborg');
INSERT INTO CityCode (postal, city) VALUES (6740, 'Bramming');
INSERT INTO CityCode (postal, city) VALUES (6752, 'Glejbjerg');
INSERT INTO CityCode (postal, city) VALUES (6753, 'Agerb�k');
INSERT INTO CityCode (postal, city) VALUES (6760, 'Ribe');
INSERT INTO CityCode (postal, city) VALUES (6771, 'Gredstedbro');
INSERT INTO CityCode (postal, city) VALUES (6780, 'Sk�rb�k');
INSERT INTO CityCode (postal, city) VALUES (6792, 'R�m�');
INSERT INTO CityCode (postal, city) VALUES (6800, 'Varde');
INSERT INTO CityCode (postal, city) VALUES (6818, '�rre');
INSERT INTO CityCode (postal, city) VALUES (6823, 'Ansager');
INSERT INTO CityCode (postal, city) VALUES (6830, 'N�rre Nebel');
INSERT INTO CityCode (postal, city) VALUES (6840, 'Oksb�l');
INSERT INTO CityCode (postal, city) VALUES (6851, 'Janderup Vestj');
INSERT INTO CityCode (postal, city) VALUES (6852, 'Billum');
INSERT INTO CityCode (postal, city) VALUES (6853, 'Vejers Strand');
INSERT INTO CityCode (postal, city) VALUES (6854, 'Henne');
INSERT INTO CityCode (postal, city) VALUES (6855, 'Outrup');
INSERT INTO CityCode (postal, city) VALUES (6857, 'Bl�vand');
INSERT INTO CityCode (postal, city) VALUES (6862, 'Tistrup');
INSERT INTO CityCode (postal, city) VALUES (6870, '�lgod');
INSERT INTO CityCode (postal, city) VALUES (6880, 'Tarm');
INSERT INTO CityCode (postal, city) VALUES (6893, 'Hemmet');
INSERT INTO CityCode (postal, city) VALUES (6900, 'Skjern');
INSERT INTO CityCode (postal, city) VALUES (6920, 'Videb�k');
INSERT INTO CityCode (postal, city) VALUES (6933, 'Kib�k');
INSERT INTO CityCode (postal, city) VALUES (6940, 'Lem St');
INSERT INTO CityCode (postal, city) VALUES (6950, 'Ringk�bing');
INSERT INTO CityCode (postal, city) VALUES (6960, 'Hvide Sande');
INSERT INTO CityCode (postal, city) VALUES (6971, 'Spjald');
INSERT INTO CityCode (postal, city) VALUES (6973, '�rnh�j');
INSERT INTO CityCode (postal, city) VALUES (6980, 'Tim');
INSERT INTO CityCode (postal, city) VALUES (6990, 'Ulfborg');
INSERT INTO CityCode (postal, city) VALUES (7000, 'Fredericia');
INSERT INTO CityCode (postal, city) VALUES (7007, 'Fredericia');
INSERT INTO CityCode (postal, city) VALUES (7017, 'Taulov Pakkecenter');
INSERT INTO CityCode (postal, city) VALUES (7018, 'Pakker TLP');
INSERT INTO CityCode (postal, city) VALUES (7029, 'Fredericia');
INSERT INTO CityCode (postal, city) VALUES (7080, 'B�rkop');
INSERT INTO CityCode (postal, city) VALUES (7100, 'Vejle');
INSERT INTO CityCode (postal, city) VALUES (7120, 'Vejle �st');
INSERT INTO CityCode (postal, city) VALUES (7130, 'Juelsminde');
INSERT INTO CityCode (postal, city) VALUES (7140, 'Stouby');
INSERT INTO CityCode (postal, city) VALUES (7150, 'Barrit');
INSERT INTO CityCode (postal, city) VALUES (7160, 'T�rring');
INSERT INTO CityCode (postal, city) VALUES (7171, 'Uldum');
INSERT INTO CityCode (postal, city) VALUES (7173, 'Vonge');
INSERT INTO CityCode (postal, city) VALUES (7182, 'Bredsten');
INSERT INTO CityCode (postal, city) VALUES (7183, 'Randb�l');
INSERT INTO CityCode (postal, city) VALUES (7184, 'Vandel');
INSERT INTO CityCode (postal, city) VALUES (7190, 'Billund');
INSERT INTO CityCode (postal, city) VALUES (7200, 'Grindsted');
INSERT INTO CityCode (postal, city) VALUES (7250, 'Hejnsvig');
INSERT INTO CityCode (postal, city) VALUES (7260, 'S�nder Omme');
INSERT INTO CityCode (postal, city) VALUES (7270, 'Stakroge');
INSERT INTO CityCode (postal, city) VALUES (7280, 'S�nder Felding');
INSERT INTO CityCode (postal, city) VALUES (7300, 'Jelling');
INSERT INTO CityCode (postal, city) VALUES (7321, 'Gadbjerg');
INSERT INTO CityCode (postal, city) VALUES (7323, 'Give');
INSERT INTO CityCode (postal, city) VALUES (7330, 'Brande');
INSERT INTO CityCode (postal, city) VALUES (7361, 'Ejstrupholm');
INSERT INTO CityCode (postal, city) VALUES (7362, 'Hampen');
INSERT INTO CityCode (postal, city) VALUES (7400, 'Herning');
INSERT INTO CityCode (postal, city) VALUES (7429, 'Herning');
INSERT INTO CityCode (postal, city) VALUES (7430, 'Ikast');
INSERT INTO CityCode (postal, city) VALUES (7441, 'Bording');
INSERT INTO CityCode (postal, city) VALUES (7442, 'Engesvang');
INSERT INTO CityCode (postal, city) VALUES (7451, 'Sunds');
INSERT INTO CityCode (postal, city) VALUES (7470, 'Karup J');
INSERT INTO CityCode (postal, city) VALUES (7480, 'Vildbjerg');
INSERT INTO CityCode (postal, city) VALUES (7490, 'Aulum');
INSERT INTO CityCode (postal, city) VALUES (7500, 'Holstebro');
INSERT INTO CityCode (postal, city) VALUES (7540, 'Haderup');
INSERT INTO CityCode (postal, city) VALUES (7550, 'S�rvad');
INSERT INTO CityCode (postal, city) VALUES (7560, 'Hjerm');
INSERT INTO CityCode (postal, city) VALUES (7570, 'Vemb');
INSERT INTO CityCode (postal, city) VALUES (7600, 'Struer');
INSERT INTO CityCode (postal, city) VALUES (7620, 'Lemvig');
INSERT INTO CityCode (postal, city) VALUES (7650, 'B�vlingbjerg');
INSERT INTO CityCode (postal, city) VALUES (7660, 'B�kmarksbro');
INSERT INTO CityCode (postal, city) VALUES (7673, 'Harbo�re');
INSERT INTO CityCode (postal, city) VALUES (7680, 'Thybor�n');
INSERT INTO CityCode (postal, city) VALUES (7700, 'Thisted');
INSERT INTO CityCode (postal, city) VALUES (7730, 'Hanstholm');
INSERT INTO CityCode (postal, city) VALUES (7741, 'Fr�strup');
INSERT INTO CityCode (postal, city) VALUES (7742, 'Vesl�s');
INSERT INTO CityCode (postal, city) VALUES (7752, 'Snedsted');
INSERT INTO CityCode (postal, city) VALUES (7755, 'Bedsted Thy');
INSERT INTO CityCode (postal, city) VALUES (7760, 'Hurup Thy');
INSERT INTO CityCode (postal, city) VALUES (7770, 'Vestervig');
INSERT INTO CityCode (postal, city) VALUES (7790, 'Thyholm');
INSERT INTO CityCode (postal, city) VALUES (7800, 'Skive');
INSERT INTO CityCode (postal, city) VALUES (7830, 'Vinderup');
INSERT INTO CityCode (postal, city) VALUES (7840, 'H�jslev');
INSERT INTO CityCode (postal, city) VALUES (7850, 'Stoholm Jyll');
INSERT INTO CityCode (postal, city) VALUES (7860, 'Sp�ttrup');
INSERT INTO CityCode (postal, city) VALUES (7870, 'Roslev');
INSERT INTO CityCode (postal, city) VALUES (7884, 'Fur');
INSERT INTO CityCode (postal, city) VALUES (7900, 'Nyk�bing M');
INSERT INTO CityCode (postal, city) VALUES (7950, 'Erslev');
INSERT INTO CityCode (postal, city) VALUES (7960, 'Karby');
INSERT INTO CityCode (postal, city) VALUES (7970, 'Redsted M');
INSERT INTO CityCode (postal, city) VALUES (7980, 'Vils');
INSERT INTO CityCode (postal, city) VALUES (7990, '�ster Assels');
INSERT INTO CityCode (postal, city) VALUES (7992, 'Sydjylland/Fyn USF P');
INSERT INTO CityCode (postal, city) VALUES (7993, 'Sydjylland/Fyn USF B');
INSERT INTO CityCode (postal, city) VALUES (7996, 'Fakturaservice');
INSERT INTO CityCode (postal, city) VALUES (7997, 'Fakturascanning');
INSERT INTO CityCode (postal, city) VALUES (7998, 'Statsservice');
INSERT INTO CityCode (postal, city) VALUES (7999, 'Kommunepost');
INSERT INTO CityCode (postal, city) VALUES (8000, 'Aarhus C');
INSERT INTO CityCode (postal, city) VALUES (8100, 'Aarhus C');
INSERT INTO CityCode (postal, city) VALUES (8200, 'Aarhus ');
INSERT INTO CityCode (postal, city) VALUES (8210, 'Aarhus V');
INSERT INTO CityCode (postal, city) VALUES (8220, 'Brabrand');
INSERT INTO CityCode (postal, city) VALUES (8229, 'Risskov �');
INSERT INTO CityCode (postal, city) VALUES (8230, '�byh�j');
INSERT INTO CityCode (postal, city) VALUES (8240, 'Risskov');
INSERT INTO CityCode (postal, city) VALUES (8245, 'Risskov �');
INSERT INTO CityCode (postal, city) VALUES (8250, 'Eg�');
INSERT INTO CityCode (postal, city) VALUES (8260, 'Viby J');
INSERT INTO CityCode (postal, city) VALUES (8270, 'H�jbjerg');
INSERT INTO CityCode (postal, city) VALUES (8300, 'Odder');
INSERT INTO CityCode (postal, city) VALUES (8305, 'Sams�');
INSERT INTO CityCode (postal, city) VALUES (8310, 'Tranbjerg J');
INSERT INTO CityCode (postal, city) VALUES (8320, 'M�rslet');
INSERT INTO CityCode (postal, city) VALUES (8330, 'Beder');
INSERT INTO CityCode (postal, city) VALUES (8340, 'Malling');
INSERT INTO CityCode (postal, city) VALUES (8350, 'Hundslund');
INSERT INTO CityCode (postal, city) VALUES (8355, 'Solbjerg');
INSERT INTO CityCode (postal, city) VALUES (8361, 'Hasselager');
INSERT INTO CityCode (postal, city) VALUES (8362, 'H�rning');
INSERT INTO CityCode (postal, city) VALUES (8370, 'Hadsten');
INSERT INTO CityCode (postal, city) VALUES (8380, 'Trige');
INSERT INTO CityCode (postal, city) VALUES (8381, 'Tilst');
INSERT INTO CityCode (postal, city) VALUES (8382, 'Hinnerup');
INSERT INTO CityCode (postal, city) VALUES (8400, 'Ebeltoft');
INSERT INTO CityCode (postal, city) VALUES (8410, 'R�nde');
INSERT INTO CityCode (postal, city) VALUES (8420, 'Knebel');
INSERT INTO CityCode (postal, city) VALUES (8444, 'Balle');
INSERT INTO CityCode (postal, city) VALUES (8450, 'Hammel');
INSERT INTO CityCode (postal, city) VALUES (8462, 'Harlev J');
INSERT INTO CityCode (postal, city) VALUES (8464, 'Galten');
INSERT INTO CityCode (postal, city) VALUES (8471, 'Sabro');
INSERT INTO CityCode (postal, city) VALUES (8472, 'Sporup');
INSERT INTO CityCode (postal, city) VALUES (8500, 'Grenaa');
INSERT INTO CityCode (postal, city) VALUES (8520, 'Lystrup');
INSERT INTO CityCode (postal, city) VALUES (8530, 'Hjortsh�j');
INSERT INTO CityCode (postal, city) VALUES (8541, 'Sk�dstrup');
INSERT INTO CityCode (postal, city) VALUES (8543, 'Hornslet');
INSERT INTO CityCode (postal, city) VALUES (8544, 'M�rke');
INSERT INTO CityCode (postal, city) VALUES (8550, 'Ryomg�rd');
INSERT INTO CityCode (postal, city) VALUES (8560, 'Kolind');
INSERT INTO CityCode (postal, city) VALUES (8570, 'Trustrup');
INSERT INTO CityCode (postal, city) VALUES (8581, 'Nimtofte');
INSERT INTO CityCode (postal, city) VALUES (8585, 'Glesborg');
INSERT INTO CityCode (postal, city) VALUES (8586, '�rum Djurs');
INSERT INTO CityCode (postal, city) VALUES (8592, 'Anholt');
INSERT INTO CityCode (postal, city) VALUES (8600, 'Silkeborg');
INSERT INTO CityCode (postal, city) VALUES (8620, 'Kjellerup');
INSERT INTO CityCode (postal, city) VALUES (8632, 'Lemming');
INSERT INTO CityCode (postal, city) VALUES (8641, 'Sorring');
INSERT INTO CityCode (postal, city) VALUES (8643, 'Ans By');
INSERT INTO CityCode (postal, city) VALUES (8653, 'Them');
INSERT INTO CityCode (postal, city) VALUES (8654, 'Bryrup');
INSERT INTO CityCode (postal, city) VALUES (8660, 'Skanderborg');
INSERT INTO CityCode (postal, city) VALUES (8670, 'L�sby');
INSERT INTO CityCode (postal, city) VALUES (8680, 'Ry');
INSERT INTO CityCode (postal, city) VALUES (8700, 'Horsens');
INSERT INTO CityCode (postal, city) VALUES (8721, 'Daug�rd');
INSERT INTO CityCode (postal, city) VALUES (8722, 'Hedensted');
INSERT INTO CityCode (postal, city) VALUES (8723, 'L�sning');
INSERT INTO CityCode (postal, city) VALUES (8732, 'Hovedg�rd');
INSERT INTO CityCode (postal, city) VALUES (8740, 'Br�dstrup');
INSERT INTO CityCode (postal, city) VALUES (8751, 'Gedved');
INSERT INTO CityCode (postal, city) VALUES (8752, '�stbirk');
INSERT INTO CityCode (postal, city) VALUES (8762, 'Flemming');
INSERT INTO CityCode (postal, city) VALUES (8763, 'Rask M�lle');
INSERT INTO CityCode (postal, city) VALUES (8765, 'Klovborg');
INSERT INTO CityCode (postal, city) VALUES (8766, 'N�rre Snede');
INSERT INTO CityCode (postal, city) VALUES (8781, 'Stenderup');
INSERT INTO CityCode (postal, city) VALUES (8783, 'Hornsyld');
INSERT INTO CityCode (postal, city) VALUES (8789, 'Endelave');
INSERT INTO CityCode (postal, city) VALUES (8799, 'Tun�');
INSERT INTO CityCode (postal, city) VALUES (8800, 'Viborg');
INSERT INTO CityCode (postal, city) VALUES (8830, 'Tjele');
INSERT INTO CityCode (postal, city) VALUES (8831, 'L�gstrup');
INSERT INTO CityCode (postal, city) VALUES (8832, 'Skals');
INSERT INTO CityCode (postal, city) VALUES (8840, 'R�dk�rsbro');
INSERT INTO CityCode (postal, city) VALUES (8850, 'Bjerringbro');
INSERT INTO CityCode (postal, city) VALUES (8860, 'Ulstrup');
INSERT INTO CityCode (postal, city) VALUES (8870, 'Lang�');
INSERT INTO CityCode (postal, city) VALUES (8881, 'Thors�');
INSERT INTO CityCode (postal, city) VALUES (8882, 'F�rvang');
INSERT INTO CityCode (postal, city) VALUES (8883, 'Gjern');
INSERT INTO CityCode (postal, city) VALUES (8900, 'Randers C');
INSERT INTO CityCode (postal, city) VALUES (8920, 'Randers NV');
INSERT INTO CityCode (postal, city) VALUES (8930, 'Randers N�');
INSERT INTO CityCode (postal, city) VALUES (8940, 'Randers SV');
INSERT INTO CityCode (postal, city) VALUES (8950, '�rsted');
INSERT INTO CityCode (postal, city) VALUES (8960, 'Randers S�');
INSERT INTO CityCode (postal, city) VALUES (8961, 'Alling�bro');
INSERT INTO CityCode (postal, city) VALUES (8963, 'Auning');
INSERT INTO CityCode (postal, city) VALUES (8970, 'Havndal');
INSERT INTO CityCode (postal, city) VALUES (8981, 'Spentrup');
INSERT INTO CityCode (postal, city) VALUES (8983, 'Gjerlev J');
INSERT INTO CityCode (postal, city) VALUES (8990, 'F�rup');
INSERT INTO CityCode (postal, city) VALUES (9000, 'Aalborg');
INSERT INTO CityCode (postal, city) VALUES (9029, 'Aalborg');
INSERT INTO CityCode (postal, city) VALUES (9100, 'Aalborg');
INSERT INTO CityCode (postal, city) VALUES (9200, 'Aalborg SV');
INSERT INTO CityCode (postal, city) VALUES (9210, 'Aalborg S�');
INSERT INTO CityCode (postal, city) VALUES (9220, 'Aalborg �st');
INSERT INTO CityCode (postal, city) VALUES (9230, 'Svenstrup J');
INSERT INTO CityCode (postal, city) VALUES (9240, 'Nibe');
INSERT INTO CityCode (postal, city) VALUES (9260, 'Gistrup');
INSERT INTO CityCode (postal, city) VALUES (9270, 'Klarup');
INSERT INTO CityCode (postal, city) VALUES (9280, 'Storvorde');
INSERT INTO CityCode (postal, city) VALUES (9293, 'Kongerslev');
INSERT INTO CityCode (postal, city) VALUES (9300, 'S�by');
INSERT INTO CityCode (postal, city) VALUES (9310, 'Vodskov');
INSERT INTO CityCode (postal, city) VALUES (9320, 'Hjallerup');
INSERT INTO CityCode (postal, city) VALUES (9330, 'Dronninglund');
INSERT INTO CityCode (postal, city) VALUES (9340, 'Asaa');
INSERT INTO CityCode (postal, city) VALUES (9352, 'Dybvad');
INSERT INTO CityCode (postal, city) VALUES (9362, 'Gandrup');
INSERT INTO CityCode (postal, city) VALUES (9370, 'Hals');
INSERT INTO CityCode (postal, city) VALUES (9380, 'Vestbjerg');
INSERT INTO CityCode (postal, city) VALUES (9381, 'Sulsted');
INSERT INTO CityCode (postal, city) VALUES (9382, 'Tylstrup');
INSERT INTO CityCode (postal, city) VALUES (9400, 'N�rresundby');
INSERT INTO CityCode (postal, city) VALUES (9430, 'Vadum');
INSERT INTO CityCode (postal, city) VALUES (9440, 'Aabybro');
INSERT INTO CityCode (postal, city) VALUES (9460, 'Brovst');
INSERT INTO CityCode (postal, city) VALUES (9480, 'L�kken');
INSERT INTO CityCode (postal, city) VALUES (9490, 'Pandrup');
INSERT INTO CityCode (postal, city) VALUES (9492, 'Blokhus');
INSERT INTO CityCode (postal, city) VALUES (9493, 'Saltum');
INSERT INTO CityCode (postal, city) VALUES (9500, 'Hobro');
INSERT INTO CityCode (postal, city) VALUES (9510, 'Arden');
INSERT INTO CityCode (postal, city) VALUES (9520, 'Sk�rping');
INSERT INTO CityCode (postal, city) VALUES (9530, 'St�vring');
INSERT INTO CityCode (postal, city) VALUES (9541, 'Suldrup');
INSERT INTO CityCode (postal, city) VALUES (9550, 'Mariager');
INSERT INTO CityCode (postal, city) VALUES (9560, 'Hadsund');
INSERT INTO CityCode (postal, city) VALUES (9574, 'B�lum');
INSERT INTO CityCode (postal, city) VALUES (9575, 'Terndrup');
INSERT INTO CityCode (postal, city) VALUES (9600, 'Aars');
INSERT INTO CityCode (postal, city) VALUES (9610, 'N�rager');
INSERT INTO CityCode (postal, city) VALUES (9620, 'Aalestrup');
INSERT INTO CityCode (postal, city) VALUES (9631, 'Gedsted');
INSERT INTO CityCode (postal, city) VALUES (9632, 'M�ldrup');
INSERT INTO CityCode (postal, city) VALUES (9640, 'Fars�');
INSERT INTO CityCode (postal, city) VALUES (9670, 'L�gst�r');
INSERT INTO CityCode (postal, city) VALUES (9681, 'Ranum');
INSERT INTO CityCode (postal, city) VALUES (9690, 'Fjerritslev');
INSERT INTO CityCode (postal, city) VALUES (9700, 'Br�nderslev');
INSERT INTO CityCode (postal, city) VALUES (9740, 'Jerslev J');
INSERT INTO CityCode (postal, city) VALUES (9750, '�stervr�');
INSERT INTO CityCode (postal, city) VALUES (9760, 'Vr�');
INSERT INTO CityCode (postal, city) VALUES (9800, 'Hj�rring');
INSERT INTO CityCode (postal, city) VALUES (9830, 'T�rs');
INSERT INTO CityCode (postal, city) VALUES (9850, 'Hirtshals');
INSERT INTO CityCode (postal, city) VALUES (9870, 'Sindal');
INSERT INTO CityCode (postal, city) VALUES (9881, 'Bindslev');
INSERT INTO CityCode (postal, city) VALUES (9900, 'Frederikshavn');
INSERT INTO CityCode (postal, city) VALUES (9940, 'L�s�');
INSERT INTO CityCode (postal, city) VALUES (9970, 'Strandby');
INSERT INTO CityCode (postal, city) VALUES (9981, 'Jerup');
INSERT INTO CityCode (postal, city) VALUES (9982, '�lb�k');
INSERT INTO CityCode (postal, city) VALUES (9990, 'Skagen');
INSERT INTO CityCode (postal, city) VALUES (9992, 'Jylland USF P');
INSERT INTO CityCode (postal, city) VALUES (9993, 'Jylland USF B');
INSERT INTO CityCode (postal, city) VALUES (9996, 'Fakturaservice');
INSERT INTO CityCode (postal, city) VALUES (9997, 'Fakturascanning');
INSERT INTO CityCode (postal, city) VALUES (9998, 'Borgerservice');




CREATE OR ALTER PROCEDURE CreateCustomer 
	-- Add the parameters for the stored procedure here
	@email VARCHAR(30),
	@postal INT,
	@phone VARCHAR(20),
	@address VARCHAR(255),
	@name VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO Customer VALUES(@email, @postal, @phone, @address, @name)
END
GO

-- ================================================
-- Template generated from Template Explorer using:
-- Create Scalar Function (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date, ,>
-- Description:	Return 1 if it valid Check if reservation 
-- =============================================
CREATE OR ALTER FUNCTION IsReservationAdditionValid
(
	-- Add the parameters for the function here
	@ordernumber INT,
	@additionname VARCHAR(MAX)
)
RETURNS BIT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @IsValid BIT
	SET @IsValid = 1

	-- Add the T-SQL statements to compute the return value here
	IF (@additionname = '1 uges plads inkl. 4 personer, 6 x morgenmad og billetter til badeland hele ugen')
		BEGIN 
		IF NOT EXISTS (SELECT * FROM Reservation r JOIN CampingSiteTypes cst ON r.campingid = cst.campingid WHERE cst.typename = @additionname)
			SET @IsValid = 0
		END
	-- Return the result of the function
	RETURN @IsValid;

END
GO


