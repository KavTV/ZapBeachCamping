--BENJAMIN, KASPER & PHILIP
USE [master]
GO
/****** Object:  Database [ZAP_Base]    Script Date: 24/06/2021 15.08.37 ******/
CREATE DATABASE [ZAP_Base]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ZAP_Base', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.ZAPSQLSERVER\MSSQL\DATA\ZAP_Base.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ZAP_Base_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.ZAPSQLSERVER\MSSQL\DATA\ZAP_Base_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [ZAP_Base] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ZAP_Base].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ZAP_Base] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ZAP_Base] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ZAP_Base] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ZAP_Base] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ZAP_Base] SET ARITHABORT OFF 
GO
ALTER DATABASE [ZAP_Base] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ZAP_Base] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ZAP_Base] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ZAP_Base] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ZAP_Base] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ZAP_Base] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ZAP_Base] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ZAP_Base] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ZAP_Base] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ZAP_Base] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ZAP_Base] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ZAP_Base] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ZAP_Base] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ZAP_Base] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ZAP_Base] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ZAP_Base] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ZAP_Base] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ZAP_Base] SET RECOVERY FULL 
GO
ALTER DATABASE [ZAP_Base] SET  MULTI_USER 
GO
ALTER DATABASE [ZAP_Base] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ZAP_Base] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ZAP_Base] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ZAP_Base] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ZAP_Base] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ZAP_Base] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'ZAP_Base', N'ON'
GO
ALTER DATABASE [ZAP_Base] SET QUERY_STORE = OFF
GO
USE [ZAP_Base]
GO
/****** Object:  User [ZapReception]    Script Date: 24/06/2021 15.08.37 ******/
CREATE USER [ZapReception] FOR LOGIN [ZapReception] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [ZapHjemmeside]    Script Date: 24/06/2021 15.08.37 ******/
CREATE USER [ZapHjemmeside] FOR LOGIN [ZapHjemmeside] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [ZapHjemmeside]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [ZapHjemmeside]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAdditionsAsString]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date, ,>
-- Description:	Additions in this format "Amount:AdditionName:price,Amount:AdditionName:price"
-- =============================================
CREATE   FUNCTION [dbo].[GetAdditionsAsString]
(
	-- Add the parameters for the function here
	@ordernumber INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @str_additions VARCHAR(MAX)

	-- Add the T-SQL statements to compute the return value here
	SELECT @str_additions = STRING_AGG(CONCAT(ra.amount, ':', ra.additionname, ':', ads.price), ',')
	FROM Reservation r
	JOIN ReservationAddition ra
		ON r.ordernumber = ra.ordernumber
	JOIN AdditionsSeason ads
		ON ra.additionname = ads.additionname
	WHERE r.ordernumber = @ordernumber AND ads.seasonname = dbo.GetSeasonName(r.startdate, r.enddate)
	GROUP BY r.ordernumber

	-- Return the result of the function
	RETURN @str_additions
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetReservationTotalPrice]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*	=============================================
	Author:		Philip
	Create date: <Create Date, ,>
	Description:	Calculate reservation additions, campingsite additions and the campingsite price where every 4 day is free
	
	ALTER TABLE Reservation
	DROP COLUMN TotalPrice

	ALTER TABLE Reservation
	ADD TotalPrice AS ([dbo].[GetReservationTotalPrice]([campingid],[ordernumber],[typename],[startdate],[enddate]))
	
	============================================= */
CREATE   FUNCTION [dbo].[GetReservationTotalPrice]
(
	-- Add the parameters for the function here
	@Campingid VARCHAR(3),
	@ordernumber INT,
	@typename VARCHAR(30),
	@startdate DATE,
	@enddate DATE
)
RETURNS NUMERIC(8,2)
AS
BEGIN
	--Implement isnull on every place where it set @Totalprice
	-- Calculate the days the customer should pay for
	DECLARE @DaysToPayForPlace INT
	-- Actual days minus the free days, ever 4 day is free, Always ROUND DOWN 
	--Round is not needed Datediff always ROUND DOWN the output
	SET @DaysToPayForPlace = DATEDIFF(DAY, @startdate, @enddate) - ROUND((DATEDIFF(DAY, @startdate, @enddate) / 4), 0, 0) 
	--Round(the number, how many decimals, above 0 the function truncate)
	-- Declare the return variable here
	DECLARE @TotalPrice NUMERIC(8,2)

	--First get Site addition price
	--ISNULL is needed så the output not return NULL
	SELECT @TotalPrice = ISNULL(SUM(ca.price * DATEDIFF(DAY, @startdate, @enddate)), 0)
	FROM CampingSiteAdditions csa
	JOIN CampingAddition ca
		ON csa.additionname = ca.[name]
	WHERE csa.campingid = @Campingid

	-- if the reservation not containe a special season type like discount then it should calculate the sitetype price
	IF NOT EXISTS (SELECT * FROM ReservationAddition ra JOIN AdditionsSeason ads ON ra.additionname = ads.additionname WHERE ra.ordernumber = @ordernumber AND ads.seasonname = 'Special')
		BEGIN
			-- Set the totalprice from (site price * days)
			SELECT @TotalPrice = 
				CASE
					WHEN @typename IN ( 'Forår', 'Efterår', 'Sommer', 'Vinter')
						THEN @TotalPrice + ISNULL(ts.price, 0) --for season then it one time pay
					WHEN @Campingid IN ( 'H1', 'H2', 'H3', 'H4', 'H5', 'H7', 'H8', 'H10', 'H11', 'H12', 'H13', 'H14', 'H15')
						THEN @TotalPrice + ISNULL(ts.price, 0) * DATEDIFF(DAY, @startdate, @enddate) --For hytter everyday should be payed 
					ELSE 
						@TotalPrice + ISNULL((ts.price), 0) * @DaysToPayForPlace --every 4 day its its free 
				END
			FROM SeasonPeriods ps
			JOIN TypeSeason ts
				ON ts.seasonname = ps.SeasonName
			WHERE ts.typename = @typename
				AND ps.SeasonName = dbo.GetSeasonName(@startdate, @enddate)
		END

	--then get reservation additions price
	--Declare a table to insert price for each paytype in addition
	DECLARE @t TABLE(price NUMERIC(18,2))
	INSERT INTO @t
	SELECT CASE a.paytype
		WHEN 'OneTime'
			THEN ISNULL(SUM(ads.price * ra.amount), 0)
		WHEN 'Daily'
			THEN (ISNULL(SUM(ads.price * ra.amount), 0) * DATEDIFF(DAY, @startdate, @enddate))
		END AS price
	FROM AdditionsSeason ads
	JOIN Additions a
		ON ads.additionname = a.[name]
	JOIN ReservationAddition ra
		ON ads.additionname = ra.additionname
	WHERE ra.ordernumber = @ordernumber 
		AND (ads.seasonname = dbo.GetSeasonName(@startdate, @enddate)
			OR ads.seasonname = 'Special' )
	GROUP BY a.paytype
	-- Return the result of the function
	--Set the totalprice to sum of the paytype prices
	SELECT @TotalPrice = @TotalPrice + ISNULL(SUM(price),0) FROM @t
	-- Return the result of the function
	RETURN @TotalPrice;

END
GO
/****** Object:  UserDefinedFunction [dbo].[GetSeasonName]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: 10-06-2021
-- Description:	Function to return season name
-- =============================================
CREATE   FUNCTION [dbo].[GetSeasonName] 
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
	
	SELECT TOP(1) @seasonName = SeasonName
	FROM SeasonPeriods
	WHERE (FORMAT(@start, 'Md') = FORMAT([from], 'Md') and FORMAT(@end, 'Md') = FORMAT([to], 'Md')) OR
		(SeasonName NOT IN (
			'Forår'
			,'Vinter'
			,'Efterår'
			,'Sommer'
			,'Special')
			AND ((FORMAT(@start, 'Md') >= FORMAT([from], 'Md') AND FORMAT(@start, 'Md') < FORMAT([to], 'Md'))
				OR (FORMAT(@end, 'Md')>= FORMAT([from], 'Md') and FORMAT(@end, 'Md') <= FORMAT([to], 'Md'))))
	ORDER BY 
		CASE
			WHEN @start < [from] THEN DATEDIFF(DAY, [from], @end)
			ELSE DATEDIFF(DAY, @start, [to]) 
		END DESC
		
	-- Return the result of the function
	RETURN ISNULL(@seasonName,'Lavsæson') --If nothing match then its lavsæson

END
GO
/****** Object:  UserDefinedFunction [dbo].[IsReservationAdditionValid]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* =============================================
	Author:		Philip
	Create date: <Create Date, ,>
	Description:	Return 1 if it valid Check if reservation 
	ALTER TABLE ReservationAddition
	DROP [CHK_IsValid]

	ALTER TABLE ReservationAddition
	ADD CONSTRAINT CHK_IsValid CHECK(dbo.IsReservationAdditionValid(ordernumber, additionname) = 1)

   ============================================= */
CREATE   FUNCTION [dbo].[IsReservationAdditionValid]
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
	IF (@additionname = '1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen')
		BEGIN 
		IF NOT EXISTS (SELECT * FROM Reservation r JOIN CampingSiteTypes cst ON r.campingid = cst.campingid WHERE cst.typename = 'Lille campingplads' AND r.ordernumber = @ordernumber)
			SET @IsValid = 0
		END
	-- Return the result of the function
	RETURN @IsValid;

END
GO
/****** Object:  UserDefinedFunction [dbo].[IsTypenameValid]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date, ,>
-- Description:	Check if the camping site containe the specific typename
-- =============================================
CREATE   FUNCTION [dbo].[IsTypenameValid] 
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
/****** Object:  Table [dbo].[Additions]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Additions](
	[name] [varchar](100) NOT NULL,
	[paytype] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AdditionsSeason]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdditionsSeason](
	[additionname] [varchar](100) NOT NULL,
	[seasonname] [varchar](40) NOT NULL,
	[price] [numeric](8, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[additionname] ASC,
	[seasonname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAdditions]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date,,>
-- Description:	Get all additions the user can add to reservation 
-- =============================================
CREATE   FUNCTION [dbo].[GetAdditions] 
(	
	-- Add the parameters for the function here
	@startdato DATE
	,@enddate DATE
	, @typeName VARCHAR(30)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT a.[name]
		, ads.seasonname
		, ads.price
		, paytype
	FROM Additions a
	JOIN AdditionsSeason ads
		ON a.[name] = ads.additionname
	WHERE ads.seasonname = dbo.GetSeasonName(@startdato, @enddate)
		AND a.[name] != CASE WHEN @typeName  NOT LIKE '%hytte%' THEN 'Slutrengøring' ELSE '' END

)
GO
/****** Object:  Table [dbo].[Reservation]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reservation](
	[ordernumber] [int] IDENTITY(104829,69) NOT NULL,
	[email] [varchar](30) NOT NULL,
	[campingid] [varchar](3) NOT NULL,
	[typename] [varchar](30) NOT NULL,
	[startdate] [date] NOT NULL,
	[enddate] [date] NOT NULL,
	[checkin] [bit] NULL,
	[checkout] [bit] NULL,
	[TotalPrice]  AS ([dbo].[GetReservationTotalPrice]([campingid],[ordernumber],[typename],[startdate],[enddate])),
PRIMARY KEY CLUSTERED 
(
	[ordernumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetReservation]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date,,>
-- Description:	Get reservation from ordernumber
-- =============================================
CREATE FUNCTION [dbo].[GetReservation]
(	
	-- Add the parameters for the function here
	@ordernumber INT
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT r.ordernumber
		, r.email
		, r.campingid
		, r.typename
		, r.startdate
		, r.enddate
		, r.TotalPrice
		, dbo.GetAdditionsAsString(ordernumber) AS ReservationAdditions
	FROM Reservation r
	WHERE ordernumber = @ordernumber
)
GO
/****** Object:  Table [dbo].[CampingSite]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CampingSite](
	[id] [varchar](3) NOT NULL,
	[clean] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetCurrentAvaliableSites]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date,,>
-- Description:	When execute the procedure do it like this:
-- SELECT dbo.GetCurrentAvaliableSites(DEFAULT) 
-- The default value is need to specified to retrieve the value
-- =============================================
CREATE   FUNCTION [dbo].[GetCurrentAvaliableSites]()
RETURNS TABLE 
AS
RETURN 
(
	SELECT cs.id
		, CASE
			WHEN ordernumber IS NULL 
			THEN 'TRUE'
			ELSE 'FALSE'
		END AS [Value]
	FROM CampingSite cs
	LEFT JOIN Reservation r
		ON cs.id = r.campingid
		AND (( (FORMAT(GETDATE(), 'yyyy-MM-dd') < R.enddate AND FORMAT(GETDATE(), 'yyyy-MM-dd') > R.startdate)
				OR (FORMAT(GETDATE(), 'yyyy-MM-dd') >= R.startdate AND FORMAT(GETDATE(), 'yyyy-MM-dd') < R.enddate)
				--OR (FORMAT(GETDATE(), 'yyyy-MM-dd') >= R.startdate AND FORMAT(GETDATE(), 'yyyy-MM-dd') < R.enddate AND checkin = 1)
			   )
			OR (r.enddate = FORMAT(GETDATE(), 'yyyy-MM-dd') AND r.checkout != 1))
	WHERE cs.id IN ('73', '72', '70', '68', '67') --Linjen kan fjernes men er her da vi har valgt kun at tjekke følgende pladser
)
GO
/****** Object:  Table [dbo].[Campingtype]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Campingtype](
	[name] [varchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TypeSeason]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TypeSeason](
	[typename] [varchar](30) NOT NULL,
	[seasonname] [varchar](40) NOT NULL,
	[price] [numeric](8, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[typename] ASC,
	[seasonname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetCampingTypes]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date,,>
-- Description:	Get all camping sites
-- CALL:
-- SELECT * FROM dbo.GetCampingTypes() ORDER BY [name] ASC
-- =============================================
CREATE   FUNCTION [dbo].[GetCampingTypes](@IsSeasonType BIT, @IsSale BIT)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT DISTINCT ct.[name]
	FROM Campingtype ct
	JOIN TypeSeason ts
		ON ct.[name] = ts.typename
	WHERE (@IsSeasonType = 0 AND @IsSale = 0 AND ts.seasonname IN ('Højsæson', 'Lavsæson'))
		OR (@IsSeasonType = 1 AND ts.seasonname NOT IN ('Højsæson', 'Lavsæson'))
		OR (@IsSeasonType = 0 AND @IsSale = 1 AND ct.[name] IN ('Teltplads', 'Lille campingplads') AND ts.seasonname IN ('Højsæson', 'Lavsæson'))

)
GO
/****** Object:  Table [dbo].[CampingSiteTypes]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CampingSiteTypes](
	[campingid] [varchar](3) NOT NULL,
	[typename] [varchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[campingid] ASC,
	[typename] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CampingAddition]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CampingAddition](
	[name] [varchar](30) NOT NULL,
	[price] [numeric](8, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CampingSiteAdditions]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CampingSiteAdditions](
	[additionname] [varchar](30) NOT NULL,
	[campingid] [varchar](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[additionname] ASC,
	[campingid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAvaliableSites]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date,,>
-- Description:	Get sites and types and prices
-- SELECT * FROM dbo.GetAvaliableSites(sdato,edato, type) ORDER BY LEN(id), id
-- =============================================
CREATE   FUNCTION [dbo].[GetAvaliableSites]
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

WITH tempreservation AS (
-- Get all camping id which have a reservation
	SELECT campingid
	FROM Reservation R
	WHERE NOT ( (@EndDate > R.enddate AND @StartDate > R.enddate)
				OR (@EndDate < R.startdate AND @StartDate <R.startdate)
			   )
)
	SELECT cs.id
		, SUM(ISNULL(ca.price,0)+ISNULL(ts.price,0)) AS SitePrice
		, STRING_AGG(ca.[name], ',') AS Campingadditions
	FROM CampingSite cs
	JOIN CampingSiteTypes cst
		ON cs.id = cst.campingid
	JOIN TypeSeason ts
		ON cst.typename = ts.typename
	LEFT JOIN CampingSiteAdditions csa
		ON cs.id = csa.campingid
	LEFT JOIN CampingAddition ca
		ON csa.additionname = ca.[name]
	WHERE ts.typename = CASE WHEN @TypeName IS NULL THEN ts.typename ELSE @TypeName END
		AND	cs.id NOT IN (SELECT campingid FROM tempreservation)
		AND ts.seasonname = dbo.GetSeasonName(@StartDate, @EndDate)
	GROUP BY cs.id
)
GO
/****** Object:  UserDefinedFunction [dbo].[GetCampingSite]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date,,>
-- Description:	Get the camping site customer have selected
-- =============================================
CREATE   FUNCTION [dbo].[GetCampingSite]
(	
	-- Add the parameters for the function here
	@CampingID VARCHAR(3),
	@typename VARCHAR(30),
	@StartDate DATE,
	@EndDate DATE
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT id AS CampingID
		, cst.typename
		, SitePrice
		, Campingadditions
	FROM dbo.GetAvaliableSites(@StartDate, @EndDate, @typename)
	JOIN CampingSiteTypes cst
		ON id = cst.campingid
	WHERE id = @CampingID AND cst.typename = @typename
)
GO
/****** Object:  Table [dbo].[SeasonPeriods]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SeasonPeriods](
	[from] [date] NOT NULL,
	[to] [date] NOT NULL,
	[SeasonName] [varchar](40) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[from] ASC,
	[to] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetSeasonDates]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   FUNCTION [dbo].[GetSeasonDates]
(	
	-- Add the parameters for the function here
	@Typename VARCHAR(30)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT [from], [to]
	FROM SeasonPeriods
	WHERE SeasonName = @Typename
)
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[email] [varchar](30) NOT NULL,
	[postal] [int] NOT NULL,
	[phone] [varchar](20) NOT NULL,
	[address] [varchar](255) NOT NULL,
	[name] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ReservationOverview]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ReservationOverview]
AS
SELECT dbo.Reservation.ordernumber, dbo.Reservation.email, dbo.Customer.name, dbo.Customer.phone, dbo.Reservation.campingid, dbo.Reservation.startdate, dbo.Reservation.enddate, dbo.Reservation.TotalPrice
FROM     dbo.Reservation INNER JOIN
                  dbo.Customer ON dbo.Reservation.email = dbo.Customer.email
GO
/****** Object:  View [dbo].[CurrentReservationCustomers]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CurrentReservationCustomers]
AS
SELECT dbo.Customer.email, dbo.Customer.name, dbo.Customer.phone, dbo.Reservation.campingid, dbo.Reservation.checkin, dbo.Reservation.checkout, dbo.Reservation.ordernumber
FROM     dbo.Reservation INNER JOIN
                  dbo.Customer ON dbo.Customer.email = dbo.Reservation.email
WHERE  (dbo.Reservation.startdate <= GETDATE()) AND (dbo.Reservation.enddate >= GETDATE())
GO
/****** Object:  View [dbo].[NextWeekReservationCustomers]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[NextWeekReservationCustomers]
AS
SELECT dbo.Customer.email, dbo.Customer.name, dbo.Customer.phone
FROM     dbo.Customer INNER JOIN
                  dbo.Reservation ON dbo.Customer.email = dbo.Reservation.email
WHERE  (dbo.Reservation.startdate <= GETDATE() + 7) AND (dbo.Reservation.enddate >= GETDATE() + 7)
GO
/****** Object:  View [dbo].[TodaysCustomers]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TodaysCustomers]
AS
SELECT dbo.Customer.email, dbo.Customer.name, dbo.Customer.phone
FROM     dbo.Customer INNER JOIN
                  dbo.Reservation ON dbo.Customer.email = dbo.Reservation.email
WHERE  (dbo.Reservation.startdate = CONVERT(date, GETDATE()))
GO
/****** Object:  View [dbo].[BungalowsToClean]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BungalowsToClean]
AS
SELECT dbo.CampingSite.id AS Hytte, dbo.CampingSite.clean
FROM     dbo.CampingSite INNER JOIN
                  dbo.CampingSiteTypes ON dbo.CampingSite.id = dbo.CampingSiteTypes.campingid
WHERE  (dbo.CampingSite.clean = 0) AND (dbo.CampingSiteTypes.typename = 'Standard hytte (4 pers.)') OR
                  (dbo.CampingSiteTypes.typename = 'Luksus hytte (4-6 pers)')
GO
/****** Object:  Table [dbo].[AuditTable]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditTable](
	[Id] [int] IDENTITY(0,1) NOT NULL,
	[TableName] [varchar](max) NOT NULL,
	[UserName] [varchar](max) NOT NULL,
	[NewContent] [varchar](max) NOT NULL,
	[Time] [datetime] NULL,
	[Type] [varchar](max) NOT NULL,
	[OldContent] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CityCode]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CityCode](
	[postal] [int] NOT NULL,
	[city] [varchar](60) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[postal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DebugTable]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DebugTable](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[sql] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReservationAddition]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReservationAddition](
	[ordernumber] [int] NOT NULL,
	[additionname] [varchar](100) NOT NULL,
	[amount] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ordernumber] ASC,
	[additionname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Seasons]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Seasons](
	[name] [varchar](40) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[Additions] ([name], [paytype]) VALUES (N'1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen', N'OneTime')
INSERT [dbo].[Additions] ([name], [paytype]) VALUES (N'Adgang til badeland (børn)', N'Daily')
INSERT [dbo].[Additions] ([name], [paytype]) VALUES (N'Adgang til badeland (voksen)', N'Daily')
INSERT [dbo].[Additions] ([name], [paytype]) VALUES (N'Børn', N'Daily')
INSERT [dbo].[Additions] ([name], [paytype]) VALUES (N'Morgenkomplet(børn)', N'Daily')
INSERT [dbo].[Additions] ([name], [paytype]) VALUES (N'Morgenkomplet(voksen)', N'Daily')
INSERT [dbo].[Additions] ([name], [paytype]) VALUES (N'Sengelinned', N'Daily')
INSERT [dbo].[Additions] ([name], [paytype]) VALUES (N'Slutrengøring', N'OneTime')
INSERT [dbo].[Additions] ([name], [paytype]) VALUES (N'Strøm', N'OneTime')
INSERT [dbo].[Additions] ([name], [paytype]) VALUES (N'Voksne', N'Daily')
GO
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen', N'Special', CAST(1099.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Adgang til badeland (børn)', N'Højsæson', CAST(15.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Adgang til badeland (børn)', N'Lavsæson', CAST(15.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Adgang til badeland (voksen)', N'Højsæson', CAST(30.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Adgang til badeland (voksen)', N'Lavsæson', CAST(30.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Børn', N'Højsæson', CAST(42.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Børn', N'Lavsæson', CAST(49.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Morgenkomplet(børn)', N'Højsæson', CAST(50.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Morgenkomplet(børn)', N'Lavsæson', CAST(50.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Morgenkomplet(voksen)', N'Højsæson', CAST(75.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Morgenkomplet(voksen)', N'Lavsæson', CAST(75.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Sengelinned', N'Højsæson', CAST(30.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Sengelinned', N'Lavsæson', CAST(30.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Slutrengøring', N'Højsæson', CAST(150.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Slutrengøring', N'Lavsæson', CAST(150.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Strøm', N'Efterår', CAST(3.75 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Strøm', N'Forår', CAST(3.75 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Strøm', N'Sommer', CAST(3.75 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Strøm', N'Vinter', CAST(3.75 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Voksne', N'Højsæson', CAST(82.00 AS Numeric(8, 2)))
INSERT [dbo].[AdditionsSeason] ([additionname], [seasonname], [price]) VALUES (N'Voksne', N'Lavsæson', CAST(87.00 AS Numeric(8, 2)))
GO
SET IDENTITY_INSERT [dbo].[AuditTable] ON 

INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (6, N'Reservation', N'dbo', N'Ordernumber:104829 Email:kasperjeppesen@hotmail.dk Campingid:44 typename:Stor campingplads startdate:2021-06-11 enddate2021-06-18 totalprice:401.00 checkin:1 checkout:0', CAST(N'2021-06-11T12:24:37.160' AS DateTime), N'Update', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (7, N'Customer', N'dbo', N'Email:kasperjeppesen@hotmail.dk Postal:4100 Phone:22343021 Name:Kasper Legendensen Address:sejvej 25', CAST(N'2021-06-11T12:32:54.227' AS DateTime), N'Update', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (10, N'Customer', N'dbo', N'Email:kasperjeppesen@hotmail.dk Postal:4600 Phone:22343021 Name:Kasper Legendensen Address:sejvej 25', CAST(N'2021-06-11T12:33:59.397' AS DateTime), N'Update', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (12, N'Customer', N'dbo', N'Email:test Postal:4450 Phone:23434 Name:test); DROP TABLE #temptest Address:test', CAST(N'2021-06-11T15:16:16.163' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (13, N'Reservation', N'dbo', N'Ordernumber:105174 Email:kasperjeppesen@hotmail.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-11T15:35:22.010' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (14, N'Reservation', N'dbo', N'Ordernumber:105243 Email:kasperjeppesen@hotmail.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-11T15:36:59.470' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (15, N'Reservation', N'dbo', N'Ordernumber:105312 Email:kasperjeppesen@hotmail.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-11T15:38:07.163' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (16, N'Reservation', N'dbo', N'Ordernumber:105381 Email:kasperjeppesen@hotmail.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-11T15:39:57.120' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (17, N'Reservation', N'dbo', N'Ordernumber:105450 Email:kasperjeppesen@hotmail.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-11T15:39:58.287' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (18, N'Reservation', N'dbo', N'Ordernumber:105519 Email:kasperjeppesen@hotmail.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-11T15:39:59.040' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (19, N'Reservation', N'dbo', N'Ordernumber:105588 Email:kasperjeppesen@hotmail.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-11T15:41:04.850' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (20, N'Reservation', N'dbo', N'Ordernumber:105657 Email:kasperjeppesen@hotmail.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-11T15:41:14.570' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (21, N'Reservation', N'dbo', N'Ordernumber:105726 Email:kasperjeppesen@hotmail.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-11T15:42:35.040' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (22, N'Customer', N'dbo', N'Email:test@test.test Postal:4450 Phone:65465466 Name:Test Address:Jens', CAST(N'2021-06-14T08:32:13.513' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (23, N'Customer', N'dbo', N'Email:test234 Postal:4450 Phone:65465466 Name:Test Address:Jens', CAST(N'2021-06-14T08:32:21.080' AS DateTime), N'Update', N'Email:test@test.test Postal:4450 Phone:65465466 Name:Test Address:Jens')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (24, N'Customer', N'dbo', N'Email:hje Postal:4450 Phone:546565 Name:FSDCF Address:dscdc', CAST(N'2021-06-14T08:42:23.353' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (25, N'Customer', N'dbo', N'Email:hjeK Postal:4450 Phone:546565 Name:FSDCF Address:dscdc', CAST(N'2021-06-14T08:42:27.013' AS DateTime), N'Update', N'Email:hje Postal:4450 Phone:546565 Name:FSDCF Address:dscdc')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (26, N'Reservation', N'dbo', N'Ordernumber:105174 Email:kasperjeppesen@mænd.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice:1297.00 checkin:0 checkout:0', CAST(N'2021-06-14T08:50:40.370' AS DateTime), N'Update', N'Ordernumber:105174 Email:kasperjeppesen@hotmail.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice:1297.00 checkin:0 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (27, N'Customer', N'dbo', N'Email:kasperjeppesen@mænd.dk Postal:4600 Phone:22343021 Name:Kasper Legendensen Address:sejvej 25', CAST(N'2021-06-14T08:50:40.370' AS DateTime), N'Update', N'Email:kasperjeppesen@hotmail.dk Postal:4600 Phone:22343021 Name:Kasper Legendensen Address:sejvej 25')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (28, N'Reservation', N'dbo', N'Ordernumber:105174 Email:kasperjeppesen@hotmail.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice:1297.00 checkin:0 checkout:0', CAST(N'2021-06-14T08:53:52.077' AS DateTime), N'Update', N'Ordernumber:105174 Email:kasperjeppesen@mænd.dk Campingid:H13 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice:1297.00 checkin:0 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (29, N'Customer', N'dbo', N'Email:kasperjeppesen@hotmail.dk Postal:4600 Phone:22343021 Name:Kasper Legendensen Address:sejvej 25', CAST(N'2021-06-14T08:53:52.077' AS DateTime), N'Update', N'Email:kasperjeppesen@mænd.dk Postal:4600 Phone:22343021 Name:Kasper Legendensen Address:sejvej 25')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (30, N'Reservation', N'dbo', N'Ordernumber:105795 Email:kasperjeppesen@hotmail.dk Campingid:175 typename:Stor campingplads startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-14T16:34:34.200' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (31, N'Reservation', N'dbo', N'Ordernumber:105864 Email:kasperjeppesen@hotmail.dk Campingid:175 typename:Stor campingplads startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-14T16:38:36.250' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (32, N'Reservation', N'dbo', N'Ordernumber:105933 Email:kasperjeppesen@hotmail.dk Campingid:175 typename:Stor campingplads startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-14T16:41:01.670' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (33, N'Reservation', N'dbo', N'Ordernumber:106002 Email:kasperjeppesen@hotmail.dk Campingid:175 typename:Stor campingplads startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-14T16:42:22.700' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (34, N'Reservation', N'dbo', N'Ordernumber:106071 Email:kasperjeppesen@hotmail.dk Campingid:175 typename:Stor campingplads startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-14T16:45:03.510' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (50, N'Reservation', N'dbo', N'Ordernumber:107175 Email:kasperjeppesen@hotmail.dk Campingid:10 typename:Lille campingplads startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-14T17:36:10.893' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (51, N'Reservation', N'dbo', N'Ordernumber:107244 Email:kasperjeppesen@hotmail.dk Campingid:170 typename:Stor campingplads startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-14T17:38:55.540' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (52, N'Reservation', N'dbo', N'Ordernumber:107313 Email:kasperjeppesen@hotmail.dk Campingid:170 typename:Stor campingplads startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-14T17:45:38.877' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (55, N'Reservation', N'dbo', N'Ordernumber:107520 Email:kasperjeppesen@hotmail.dk Campingid:10 typename:Lille campingplads startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-14T17:53:22.723' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (56, N'Reservation', N'dbo', N'Ordernumber:107589 Email:kasperjeppesen@hotmail.dk Campingid:170 typename:Stor campingplads startdate:2021-07-06 enddate2021-07-16 totalprice: checkin:0 checkout:0', CAST(N'2021-06-14T17:53:59.520' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (58, N'Customer', N'dbo', N'Email:kavmail@gmail.com Postal:4600 Phone:22334455 Name:Kav Address:dendervej 12', CAST(N'2021-06-15T08:58:47.880' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (59, N'Reservation', N'dbo', N'Ordernumber:107727 Email:kasperjeppesen@hotmail.dk Campingid:H14 typename:Luksus hytte (4-6 pers) startdate:2021-07-06 enddate2021-07-16 totalprice:6800.00 checkin:0 checkout:0', CAST(N'2021-06-15T09:11:56.570' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (60, N'Customer', N'dbo', N'Email:jensesmail@gmail.com Postal:4600 Phone:22334455 Name:Kav Address:dendervej 12', CAST(N'2021-06-15T12:23:24.053' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (61, N'Customer', N'dbo', N'Email:Detteerenmail@gmail.com Postal:4100 Phone:22334455 Name:Philip Address:Kaspvejen 21', CAST(N'2021-06-15T13:08:09.587' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (62, N'Customer', N'dbo', N'Email:dennyemail@gmail.com Postal:4100 Phone:22334455 Name:mand Address:Kaspvejen 21', CAST(N'2021-06-15T13:22:34.737' AS DateTime), N'Update', N'Email:Detteerenmail@gmail.com Postal:4100 Phone:22334455 Name:Philip Address:Kaspvejen 21')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (64, N'Reservation', N'dbo', N'Ordernumber:107865 Email:dennyemail@gmail.com Campingid:100 typename:Lille campingplads startdate:2021-06-16 enddate2021-06-21 totalprice:200.00 checkin:0 checkout:0', CAST(N'2021-06-15T13:56:37.033' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (65, N'Reservation', N'dbo', N'Ordernumber:107934 Email:dennyemail@gmail.com Campingid:101 typename:Lille campingplads startdate:2021-06-16 enddate2021-06-21 totalprice:200.00 checkin:0 checkout:0', CAST(N'2021-06-15T14:08:32.610' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (66, N'Reservation', N'dbo', N'Ordernumber:108003 Email:dennyemail@gmail.com Campingid:102 typename:Lille campingplads startdate:2021-06-16 enddate2021-06-21 totalprice:200.00 checkin:0 checkout:0', CAST(N'2021-06-15T14:08:54.970' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (67, N'Reservation', N'dbo', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:0 checkout:0', CAST(N'2021-06-15T17:13:48.810' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (68, N'Reservation', N'dbo', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:1 checkout:1', CAST(N'2021-06-15T17:23:26.263' AS DateTime), N'Update', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:0 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (69, N'Reservation', N'dbo', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:1 checkout:0', CAST(N'2021-06-15T18:04:55.617' AS DateTime), N'Update', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:1 checkout:1')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (70, N'Reservation', N'dbo', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:0 checkout:0', CAST(N'2021-06-15T18:04:57.900' AS DateTime), N'Update', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (71, N'Reservation', N'dbo', N'Ordernumber:108210 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-10 enddate2021-06-15 totalprice:855.00 checkin:0 checkout:0', CAST(N'2021-06-15T18:07:01.807' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (72, N'Reservation', N'dbo', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:1 checkout:0', CAST(N'2021-06-15T18:17:20.777' AS DateTime), N'Update', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:0 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (73, N'Reservation', N'dbo', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:1 checkout:1', CAST(N'2021-06-16T08:49:27.800' AS DateTime), N'Update', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (74, N'Reservation', N'dbo', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:1 checkout:0', CAST(N'2021-06-16T08:50:46.353' AS DateTime), N'Update', N'Ordernumber:108141 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-14 enddate2021-06-16 totalprice:250.00 checkin:1 checkout:1')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (75, N'Customer', N'sa', N'Email:jenshansensemail@gmail.com Postal:4100 Phone:22334455 Name:mand Address:Kvejen 21', CAST(N'2021-06-16T11:58:59.470' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (76, N'Customer', N'sa', N'Email:1234@hotmail.com Postal:4100 Phone:22694455 Name:mand Address:Kvejen 21', CAST(N'2021-06-16T12:04:00.233' AS DateTime), N'Update', N'Email:jenshansensemail@gmail.com Postal:4100 Phone:22334455 Name:mand Address:Kvejen 21')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (77, N'Reservation', N'sa', N'Ordernumber:108279 Email:1234@hotmail.com Campingid:104 typename:Lille campingplads startdate:2021-06-17 enddate2021-06-30 totalprice:500.00 checkin:0 checkout:0', CAST(N'2021-06-16T12:07:08.193' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (78, N'Reservation', N'sa', N'Ordernumber:108348 Email:1234@hotmail.com Campingid:105 typename:Lille campingplads startdate:2021-06-17 enddate2021-06-30 totalprice:500.00 checkin:0 checkout:0', CAST(N'2021-06-16T12:12:37.140' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (79, N'Reservation', N'sa', N'Ordernumber:108417 Email:1234@hotmail.com Campingid:106 typename:Lille campingplads startdate:2021-06-17 enddate2021-06-30 totalprice:500.00 checkin:0 checkout:0', CAST(N'2021-06-16T12:14:10.243' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (80, N'Reservation', N'sa', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-17 totalprice:250.00 checkin:1 checkout:0', CAST(N'2021-06-17T12:35:25.260' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (81, N'Reservation', N'sa', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-17 totalprice:250.00 checkin:0 checkout:0', CAST(N'2021-06-17T12:41:44.290' AS DateTime), N'Update', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-17 totalprice:250.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (82, N'Reservation', N'sa', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-17 totalprice:250.00 checkin:1 checkout:0', CAST(N'2021-06-17T12:42:54.157' AS DateTime), N'Update', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-17 totalprice:250.00 checkin:0 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (83, N'Reservation', N'admin', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:0', CAST(N'2021-06-18T08:01:49.930' AS DateTime), N'Update', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-17 totalprice:250.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (84, N'Reservation', N'admin', N'Ordernumber:108693 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-18 enddate2021-06-22 totalprice:450.00 checkin:0 checkout:0', CAST(N'2021-06-18T08:20:55.040' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (85, N'Reservation', N'admin', N'Ordernumber:108693 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-18 enddate2021-06-22 totalprice:450.00 checkin:1 checkout:0', CAST(N'2021-06-18T08:40:36.937' AS DateTime), N'Update', N'Ordernumber:108693 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-18 enddate2021-06-22 totalprice:450.00 checkin:0 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (86, N'Reservation', N'admin', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:1', CAST(N'2021-06-18T08:40:50.590' AS DateTime), N'Update', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (87, N'Reservation', N'admin', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:0', CAST(N'2021-06-18T08:43:04.010' AS DateTime), N'Update', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:1')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (88, N'Reservation', N'admin', N'Ordernumber:108693 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-18 enddate2021-06-22 totalprice:450.00 checkin:0 checkout:0', CAST(N'2021-06-18T09:26:24.867' AS DateTime), N'Update', N'Ordernumber:108693 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-18 enddate2021-06-22 totalprice:450.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (89, N'Reservation', N'admin', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:1', CAST(N'2021-06-18T09:26:37.133' AS DateTime), N'Update', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (90, N'Reservation', N'admin', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:0', CAST(N'2021-06-18T09:26:42.107' AS DateTime), N'Update', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:1')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (91, N'Reservation', N'admin', N'Ordernumber:108693 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-18 enddate2021-06-22 totalprice:450.00 checkin:1 checkout:0', CAST(N'2021-06-18T09:26:44.110' AS DateTime), N'Update', N'Ordernumber:108693 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-18 enddate2021-06-22 totalprice:450.00 checkin:0 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (92, N'Reservation', N'admin', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:1', CAST(N'2021-06-18T10:19:28.287' AS DateTime), N'Update', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (93, N'Reservation', N'admin', N'Ordernumber:108693 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-18 enddate2021-06-22 totalprice:450.00 checkin:0 checkout:0', CAST(N'2021-06-18T10:19:35.257' AS DateTime), N'Update', N'Ordernumber:108693 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-18 enddate2021-06-22 totalprice:450.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (94, N'Reservation', N'admin', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:0', CAST(N'2021-06-18T10:19:41.077' AS DateTime), N'Update', N'Ordernumber:108624 Email:kasperjeppesen@hotmail.dk Campingid:70 typename:Lille campingplads startdate:2021-06-15 enddate2021-06-18 totalprice:375.00 checkin:1 checkout:1')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (95, N'Reservation', N'admin', N'Ordernumber:108693 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-18 enddate2021-06-22 totalprice:450.00 checkin:1 checkout:0', CAST(N'2021-06-18T10:19:43.790' AS DateTime), N'Update', N'Ordernumber:108693 Email:kasperjeppesen@hotmail.dk Campingid:72 typename:Lille campingplads startdate:2021-06-18 enddate2021-06-22 totalprice:450.00 checkin:0 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (96, N'Customer', N'sa', N'Email:test@test.test Postal:4450 Phone:8888888 Name:hrdfg Address:sdfds', CAST(N'2021-06-21T08:32:42.780' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (97, N'Reservation', N'sa', N'Ordernumber:108762 Email:test@test.test Campingid:128 typename:Lille campingplads startdate:2021-06-22 enddate2021-06-29 totalprice:825.00 checkin:0 checkout:0', CAST(N'2021-06-21T16:37:11.693' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (99, N'Reservation', N'sa', N'Ordernumber:108900 Email:test@test.test Campingid:70 typename:Lille campingplads startdate:2021-06-22 enddate2021-07-01 totalprice:1025.00 checkin:0 checkout:0', CAST(N'2021-06-21T16:59:21.500' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (100, N'Reservation', N'sa', N'Ordernumber:108969 Email:kasperjeppesen@hotmail.dk Campingid:102 typename:Lille campingplads startdate:2021-06-23 enddate2021-06-30 totalprice:300.00 checkin:0 checkout:0', CAST(N'2021-06-22T09:40:02.877' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (101, N'Reservation', N'sa', N'Ordernumber:109038 Email:kasperjeppesen@hotmail.dk Campingid:101 typename:Lille campingplads startdate:2021-06-23 enddate2021-06-30 totalprice:300.00 checkin:0 checkout:0', CAST(N'2021-06-22T09:42:57.423' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (102, N'Customer', N'sa', N'Email:ny@email.dk Postal:4400 Phone:52525252 Name:jens Address:minvej 13', CAST(N'2021-06-22T13:49:48.510' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (105, N'Reservation', N'sa', N'Ordernumber:109245 Email:ny@email.dk Campingid:153 typename:Lille campingplads startdate:2021-06-23 enddate2021-06-30 totalprice:825.00 checkin:0 checkout:0', CAST(N'2021-06-22T14:23:06.160' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (106, N'Reservation', N'sa', N'Ordernumber:109314 Email:ny@email.dk Campingid:60 typename:Stor campingplads startdate:2021-06-23 enddate2021-06-25 totalprice:310.00 checkin:0 checkout:0', CAST(N'2021-06-22T14:41:30.853' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (113, N'Reservation', N'sa', N'Ordernumber:109797 Email:ny@email.dk Campingid:152 typename:Lille campingplads startdate:2021-06-30 enddate2021-07-03 totalprice:375.00 checkin:0 checkout:0', CAST(N'2021-06-22T17:11:10.837' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (117, N'Reservation', N'sa', N'Ordernumber:110073 Email:test@test.test Campingid:156 typename:Lille campingplads startdate:2021-06-23 enddate2021-07-03 totalprice:1150.00 checkin:0 checkout:0', CAST(N'2021-06-22T19:49:20.627' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (119, N'Reservation', N'sa', N'Ordernumber:110211 Email:test@test.test Campingid:155 typename:Lille campingplads startdate:2021-06-25 enddate2021-07-02 totalprice:825.00 checkin:0 checkout:0', CAST(N'2021-06-23T08:55:17.127' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (121, N'Reservation', N'sa', N'Ordernumber:110349 Email:ny@email.dk Campingid:158 typename:Lille campingplads startdate:2021-06-24 enddate2021-07-01 totalprice:825.00 checkin:0 checkout:0', CAST(N'2021-06-23T09:18:49.157' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (122, N'Reservation', N'sa', N'Ordernumber:110418 Email:kasperjeppesen@hotmail.dk Campingid:H12 typename:Luksus hytte (4-6 pers) startdate:2021-06-24 enddate2021-07-01 totalprice:5950.00 checkin:0 checkout:0', CAST(N'2021-06-23T09:21:47.353' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (123, N'Reservation', N'sa', N'Ordernumber:110487 Email:test@test.test Campingid:160 typename:Lille campingplads startdate:2021-06-25 enddate2021-06-30 totalprice:575.00 checkin:0 checkout:0', CAST(N'2021-06-23T09:21:50.890' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (124, N'Reservation', N'sa', N'Ordernumber:110556 Email:ny@email.dk Campingid:201 typename:Lille campingplads startdate:2021-06-25 enddate2021-06-30 totalprice:200.00 checkin:0 checkout:0', CAST(N'2021-06-23T09:22:36.007' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (127, N'Reservation', N'sa', N'Ordernumber:110763 Email:ny@email.dk Campingid:202 typename:Lille campingplads startdate:2021-06-25 enddate2021-06-30 totalprice:200.00 checkin:0 checkout:0', CAST(N'2021-06-23T09:41:06.610' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (128, N'Reservation', N'sa', N'Ordernumber:110832 Email:test@test.test Campingid:151 typename:Lille campingplads startdate:2021-07-01 enddate2021-07-08 totalprice:825.00 checkin:0 checkout:0', CAST(N'2021-06-23T10:20:25.183' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (129, N'Reservation', N'sa', N'Ordernumber:110901 Email:ny@email.dk Campingid:149 typename:Lille campingplads startdate:2021-06-25 enddate2021-06-30 totalprice:575.00 checkin:0 checkout:0', CAST(N'2021-06-23T10:28:56.807' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (134, N'Reservation', N'sa', N'Ordernumber:111246 Email:kasperjeppesen@hotmail.dk Campingid:4 typename:Lille campingplads startdate:2021-06-24 enddate2021-06-27 totalprice:150.00 checkin:0 checkout:0', CAST(N'2021-06-23T12:56:55.623' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (135, N'Reservation', N'admin', N'Ordernumber:111315 Email:kasperjeppesen@hotmail.dk Campingid:4 typename:Efterår startdate:2021-08-15 enddate2021-10-31 totalprice:2900.00 checkin:0 checkout:0', CAST(N'2021-06-23T12:57:12.640' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (150, N'Reservation', N'admin', N'Ordernumber:112350 Email:kasperjeppesen@hotmail.dk Campingid:4 typename:Efterår startdate:2021-08-15 enddate2021-10-31 totalprice:2900.00 checkin:0 checkout:0', CAST(N'2021-06-23T15:31:50.420' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (155, N'Reservation', N'sa', N'Ordernumber:112695 Email:test@test.test Campingid:12 typename:Efterår startdate:2021-08-15 enddate2021-10-31 totalprice:2900.00 checkin:0 checkout:0', CAST(N'2021-06-23T16:02:53.247' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (156, N'Customer', N'sa', N'Email:SnitzelKlaus@gmail.com Postal:4700 Phone:12345678 Name:Benjamin Hoffmeyer Address:Næstvedvej 30', CAST(N'2021-06-24T08:36:19.503' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (157, N'Customer', N'sa', N'Email:Testc@mping.dk Postal:4733 Phone:12345678 Name:Benjamin Hoffmeyer Address:Tappernøje', CAST(N'2021-06-24T08:44:36.277' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (158, N'Customer', N'sa', N'Email:testingc@mping.dk Postal:4700 Phone:12345678 Name:Test tester Address:Næstvedvej 30', CAST(N'2021-06-24T08:49:40.057' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (164, N'Customer', N'sa', N'Email:Camping@gmail.com Postal:4760 Phone:12222222 Name:Benjamin Hoffmeyer Address:Kildemarksvej 16D', CAST(N'2021-06-24T09:18:03.890' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (165, N'Reservation', N'sa', N'Ordernumber:112764 Email:kasperjeppesen@hotmail.dk Campingid:3 typename:Lille campingplads startdate:2021-06-25 enddate2021-06-27 totalprice:100.00 checkin:0 checkout:0', CAST(N'2021-06-24T09:20:36.300' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (166, N'Reservation', N'sa', N'Ordernumber:112833 Email:Testc@mping.dk Campingid:2 typename:Lille campingplads startdate:2021-06-25 enddate2021-06-27 totalprice:100.00 checkin:0 checkout:0', CAST(N'2021-06-24T09:22:13.793' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (167, N'Reservation', N'sa', N'Ordernumber:112902 Email:Testc@mping.dk Campingid:3 typename:Efterår startdate:2021-08-15 enddate2021-10-31 totalprice:2900.00 checkin:0 checkout:0', CAST(N'2021-06-24T09:23:14.577' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (168, N'Reservation', N'sa', N'Ordernumber:112971 Email:Testc@mping.dk Campingid:H15 typename:Luksus hytte (4-6 pers) startdate:2021-07-05 enddate2021-07-08 totalprice:2550.00 checkin:0 checkout:0', CAST(N'2021-06-24T09:24:21.810' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (169, N'Reservation', N'sa', N'Ordernumber:113040 Email:testingc@mping.dk Campingid:15 typename:Teltplads startdate:2021-06-25 enddate2021-06-30 totalprice:140.00 checkin:0 checkout:0', CAST(N'2021-06-24T09:25:24.293' AS DateTime), N'Insert', NULL)
GO
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (170, N'Reservation', N'sa', N'Ordernumber:113109 Email:Testc@mping.dk Campingid:74 typename:Teltplads startdate:2021-06-28 enddate2021-06-30 totalprice:220.00 checkin:0 checkout:0', CAST(N'2021-06-24T09:30:47.600' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (171, N'Reservation', N'sa', N'Ordernumber:113178 Email:testingc@mping.dk Campingid:H1 typename:Standard hytte (4 pers.) startdate:2021-06-30 enddate2021-07-08 totalprice:4000.00 checkin:0 checkout:0', CAST(N'2021-06-24T09:41:55.303' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (172, N'Reservation', N'sa', N'Ordernumber:113247 Email:testingc@mping.dk Campingid:4 typename:Lille campingplads startdate:2021-06-30 enddate2021-07-06 totalprice:250.00 checkin:0 checkout:0', CAST(N'2021-06-24T09:57:06.073' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (173, N'Reservation', N'sa', N'Ordernumber:113316 Email:testingc@mping.dk Campingid:6 typename:Lille campingplads startdate:2021-06-25 enddate2021-06-26 totalprice:50.00 checkin:0 checkout:0', CAST(N'2021-06-24T10:21:18.600' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (174, N'Reservation', N'sa', N'Ordernumber:113385 Email:testingc@mping.dk Campingid:11 typename:Sommer startdate:2021-04-01 enddate2021-09-30 totalprice:9300.00 checkin:0 checkout:0', CAST(N'2021-06-24T10:24:19.363' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (175, N'Reservation', N'sa', N'Ordernumber:113454 Email:Testc@mping.dk Campingid:31 typename:Stor campingplads startdate:2021-06-30 enddate2021-06-30 totalprice:0.00 checkin:0 checkout:0', CAST(N'2021-06-24T10:42:16.170' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (176, N'Reservation', N'sa', N'Ordernumber:113523 Email:test@test.test Campingid:10 typename:Lille campingplads startdate:2021-06-25 enddate2021-06-28 totalprice:150.00 checkin:0 checkout:0', CAST(N'2021-06-24T10:42:24.007' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (177, N'Reservation', N'sa', N'Ordernumber:113592 Email:testingc@mping.dk Campingid:13 typename:Forår startdate:2021-04-01 enddate2021-06-30 totalprice:4100.00 checkin:0 checkout:0', CAST(N'2021-06-24T10:43:49.773' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (178, N'Reservation', N'sa', N'Ordernumber:113661 Email:test@test.test Campingid:9 typename:Lille campingplads startdate:2021-06-25 enddate2021-06-25 totalprice:0.00 checkin:0 checkout:0', CAST(N'2021-06-24T10:44:14.957' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (179, N'Reservation', N'sa', N'Ordernumber:113730 Email:SnitzelKlaus@gmail.com Campingid:17 typename:Teltplads startdate:2021-06-28 enddate2021-06-30 totalprice:70.00 checkin:0 checkout:0', CAST(N'2021-06-24T10:44:30.830' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (180, N'Reservation', N'sa', N'Ordernumber:113799 Email:testingc@mping.dk Campingid:6 typename:Lille campingplads startdate:2021-07-05 enddate2021-07-07 totalprice:100.00 checkin:0 checkout:0', CAST(N'2021-06-24T10:52:09.303' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (185, N'Reservation', N'sa', N'Ordernumber:113868 Email:testingc@mping.dk Campingid:31 typename:Stor campingplads startdate:2021-06-25 enddate2021-06-29 totalprice:240.00 checkin:0 checkout:0', CAST(N'2021-06-24T12:05:37.633' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (186, N'Reservation', N'sa', N'Ordernumber:113937 Email:testingc@mping.dk Campingid:71 typename:Lille campingplads startdate:2021-06-24 enddate2021-06-25 totalprice:125.00 checkin:0 checkout:0', CAST(N'2021-06-24T12:17:04.333' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (187, N'Reservation', N'sa', N'Ordernumber:114006 Email:testingc@mping.dk Campingid:72 typename:Lille campingplads startdate:2021-06-24 enddate2021-06-25 totalprice:125.00 checkin:0 checkout:0', CAST(N'2021-06-24T12:18:07.313' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (191, N'Reservation', N'sa', N'Ordernumber:114075 Email:testingc@mping.dk Campingid:12 typename:Lille campingplads startdate:2021-06-26 enddate2021-06-30 totalprice:150.00 checkin:0 checkout:0', CAST(N'2021-06-24T12:29:18.047' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (196, N'Reservation', N'sa', N'Ordernumber:114144 Email:testingc@mping.dk Campingid:239 typename:Lille campingplads startdate:2021-06-28 enddate2021-10-22 totalprice:4350.00 checkin:0 checkout:0', CAST(N'2021-06-24T12:31:34.113' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (198, N'Reservation', N'admin', N'Ordernumber:108900 Email:test@test.test Campingid:70 typename:Lille campingplads startdate:2021-06-22 enddate2021-07-01 totalprice:2879.00 checkin:1 checkout:0', CAST(N'2021-06-24T12:34:20.500' AS DateTime), N'Update', N'Ordernumber:108900 Email:test@test.test Campingid:70 typename:Lille campingplads startdate:2021-06-22 enddate2021-07-01 totalprice:2879.00 checkin:0 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (199, N'Reservation', N'admin', N'Ordernumber:108900 Email:test@test.test Campingid:70 typename:Lille campingplads startdate:2021-06-22 enddate2021-07-01 totalprice:2879.00 checkin:1 checkout:1', CAST(N'2021-06-24T12:34:26.720' AS DateTime), N'Update', N'Ordernumber:108900 Email:test@test.test Campingid:70 typename:Lille campingplads startdate:2021-06-22 enddate2021-07-01 totalprice:2879.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (207, N'Reservation', N'sa', N'Ordernumber:104829 Email:kasperjeppesen@hotmail.dk Campingid:44 typename:Stor campingplads startdate:2021-06-11 enddate2021-06-18 totalprice:2202.00 checkin:0 checkout:0', CAST(N'2021-06-24T12:37:52.427' AS DateTime), N'Update', N'Ordernumber:104829 Email:kasperjeppesen@hotmail.dk Campingid:44 typename:Stor campingplads startdate:2021-06-11 enddate2021-06-18 totalprice:2202.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (208, N'Reservation', N'sa', N'Ordernumber:104829 Email:kasperjeppesen@hotmail.dk Campingid:44 typename:Stor campingplads startdate:2021-06-11 enddate2021-06-18 totalprice:2202.00 checkin:1 checkout:0', CAST(N'2021-06-24T12:37:55.503' AS DateTime), N'Update', N'Ordernumber:104829 Email:kasperjeppesen@hotmail.dk Campingid:44 typename:Stor campingplads startdate:2021-06-11 enddate2021-06-18 totalprice:2202.00 checkin:0 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (209, N'Reservation', N'admin', N'Ordernumber:108900 Email:test@test.test Campingid:70 typename:Lille campingplads startdate:2021-06-22 enddate2021-07-01 totalprice:2879.00 checkin:1 checkout:0', CAST(N'2021-06-24T12:40:56.800' AS DateTime), N'Update', N'Ordernumber:108900 Email:test@test.test Campingid:70 typename:Lille campingplads startdate:2021-06-22 enddate2021-07-01 totalprice:2879.00 checkin:1 checkout:1')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (211, N'Reservation', N'admin', N'Ordernumber:114006 Email:testingc@mping.dk Campingid:72 typename:Lille campingplads startdate:2021-06-24 enddate2021-06-25 totalprice:833.00 checkin:1 checkout:0', CAST(N'2021-06-24T12:41:12.480' AS DateTime), N'Update', N'Ordernumber:114006 Email:testingc@mping.dk Campingid:72 typename:Lille campingplads startdate:2021-06-24 enddate2021-06-25 totalprice:833.00 checkin:0 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (216, N'Reservation', N'sa', N'Ordernumber:104829 Email:kasperjeppesen@hotmail.dk Campingid:44 typename:Stor campingplads startdate:2021-06-11 enddate2021-06-18 totalprice:2202.00 checkin:0 checkout:0', CAST(N'2021-06-24T12:43:43.050' AS DateTime), N'Update', N'Ordernumber:104829 Email:kasperjeppesen@hotmail.dk Campingid:44 typename:Stor campingplads startdate:2021-06-11 enddate2021-06-18 totalprice:2202.00 checkin:1 checkout:0')
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (218, N'Reservation', N'sa', N'Ordernumber:114489 Email:SnitzelKlaus@gmail.com Campingid:2 typename:Lille campingplads startdate:2021-06-28 enddate2021-10-08 totalprice:3850.00 checkin:0 checkout:0', CAST(N'2021-06-24T12:46:45.567' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (220, N'Reservation', N'sa', N'Ordernumber:114558 Email:SnitzelKlaus@gmail.com Campingid:3 typename:Lille campingplads startdate:2021-06-30 enddate2021-07-10 totalprice:400.00 checkin:0 checkout:0', CAST(N'2021-06-24T12:48:48.210' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (223, N'Reservation', N'sa', N'Ordernumber:114627 Email:SnitzelKlaus@gmail.com Campingid:9 typename:Lille campingplads startdate:2021-06-30 enddate2021-07-10 totalprice:400.00 checkin:0 checkout:0', CAST(N'2021-06-24T12:50:30.703' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (228, N'Reservation', N'sa', N'Ordernumber:114696 Email:kasperjeppesen@hotmail.dk Campingid:18 typename:Lille campingplads startdate:2021-06-27 enddate2021-07-01 totalprice:150.00 checkin:0 checkout:0', CAST(N'2021-06-24T13:01:06.437' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (229, N'Reservation', N'sa', N'Ordernumber:114765 Email:kasperjeppesen@hotmail.dk Campingid:20 typename:Lille campingplads startdate:2021-06-26 enddate2021-07-03 totalprice:300.00 checkin:0 checkout:0', CAST(N'2021-06-24T13:01:39.953' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (230, N'Customer', N'sa', N'Email:Hamdennyeseje@gmail.com Postal:4600 Phone:69420969 Name:Gurli Gris Address:nicevej 21', CAST(N'2021-06-24T14:10:41.533' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (231, N'Reservation', N'sa', N'Ordernumber:114834 Email:Hamdennyeseje@gmail.com Campingid:H11 typename:Luksus hytte (4-6 pers) startdate:2021-06-26 enddate2021-07-10 totalprice:11900.00 checkin:0 checkout:0', CAST(N'2021-06-24T14:10:46.040' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (232, N'Reservation', N'sa', N'Ordernumber:114903 Email:kasperjeppesen@hotmail.dk Campingid:78 typename:Teltplads startdate:2021-06-26 enddate2021-07-03 totalprice:735.00 checkin:0 checkout:0', CAST(N'2021-06-24T14:12:10.640' AS DateTime), N'Insert', NULL)
INSERT [dbo].[AuditTable] ([Id], [TableName], [UserName], [NewContent], [Time], [Type], [OldContent]) VALUES (233, N'Reservation', N'sa', N'Ordernumber:114972 Email:kasperjeppesen@hotmail.dk Campingid:108 typename:Sommer startdate:2021-04-01 enddate2021-09-30 totalprice:9300.00 checkin:0 checkout:0', CAST(N'2021-06-24T14:20:26.527' AS DateTime), N'Insert', NULL)
SET IDENTITY_INSERT [dbo].[AuditTable] OFF
GO
INSERT [dbo].[CampingAddition] ([name], [price]) VALUES (N'Ekstra god udsigt', CAST(75.00 AS Numeric(8, 2)))
GO
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'10', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'100', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'101', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'102', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'103', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'104', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'105', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'106', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'107', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'108', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'109', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'11', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'110', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'111', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'112', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'113', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'114', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'115', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'116', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'117', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'118', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'119', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'12', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'120', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'121', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'122', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'123', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'124', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'125', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'126', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'127', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'128', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'129', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'13', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'130', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'131', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'132', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'133', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'134', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'135', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'136', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'137', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'138', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'139', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'14', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'140', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'141', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'142', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'143', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'144', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'145', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'146', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'147', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'148', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'149', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'15', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'150', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'151', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'152', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'153', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'154', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'155', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'156', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'157', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'158', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'159', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'16', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'160', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'161', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'162', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'163', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'164', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'165', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'166', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'167', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'168', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'169', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'17', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'170', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'171', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'172', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'173', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'174', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'175', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'176', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'177', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'178', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'179', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'18', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'180', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'181', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'182', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'183', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'184', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'185', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'186', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'187', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'188', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'189', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'19', 0)
GO
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'190', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'191', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'192', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'193', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'194', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'195', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'196', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'197', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'198', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'199', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'2', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'20', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'200', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'201', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'202', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'203', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'204', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'205', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'206', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'207', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'208', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'209', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'21', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'210', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'211', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'212', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'213', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'214', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'215', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'216', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'217', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'218', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'219', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'22', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'220', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'221', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'222', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'223', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'224', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'225', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'226', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'227', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'228', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'229', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'23', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'230', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'231', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'232', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'233', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'234', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'235', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'236', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'237', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'238', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'239', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'24', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'240', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'241', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'242', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'243', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'244', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'245', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'246', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'247', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'248', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'249', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'25', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'250', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'251', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'252', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'253', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'254', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'255', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'256', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'257', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'258', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'259', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'26', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'260', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'261', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'262', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'263', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'264', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'265', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'266', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'267', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'268', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'269', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'27', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'270', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'271', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'272', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'273', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'274', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'275', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'276', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'277', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'278', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'279', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'28', 0)
GO
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'280', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'281', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'282', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'283', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'284', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'285', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'286', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'287', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'288', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'289', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'29', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'290', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'291', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'292', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'293', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'294', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'295', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'296', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'297', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'298', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'299', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'3', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'30', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'300', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'301', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'302', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'303', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'304', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'305', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'306', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'307', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'308', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'309', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'31', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'32', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'33', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'34', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'35', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'36', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'37', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'38', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'39', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'4', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'40', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'41', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'42', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'43', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'44', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'45', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'46', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'47', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'48', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'49', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'50', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'51', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'52', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'53', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'54', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'55', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'56', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'57', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'58', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'59', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'6', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'60', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'61', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'62', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'63', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'64', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'65', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'66', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'67', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'68', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'69', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'70', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'71', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'72', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'73', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'74', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'75', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'76', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'77', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'78', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'79', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'80', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'81', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'82', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'83', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'84', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'85', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'86', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'87', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'88', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'89', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'9', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'90', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'91', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'92', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'93', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'94', 0)
GO
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'95', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'96', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'97', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'98', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'99', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H1', 1)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H10', 1)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H11', 1)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H12', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H13', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H14', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H15', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H2', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H3', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H4', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H5', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H7', 0)
INSERT [dbo].[CampingSite] ([id], [clean]) VALUES (N'H8', 0)
GO
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'128')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'129')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'130')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'131')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'132')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'133')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'134')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'135')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'136')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'137')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'138')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'139')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'140')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'141')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'142')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'143')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'144')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'145')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'146')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'147')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'148')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'149')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'150')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'151')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'152')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'153')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'154')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'155')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'156')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'157')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'158')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'159')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'160')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'161')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'162')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'163')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'164')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'165')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'166')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'167')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'168')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'169')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'192')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'193')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'194')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'195')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'196')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'197')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'198')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'199')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'300')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'301')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'302')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'303')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'304')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'305')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'306')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'307')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'308')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'309')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'51')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'52')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'53')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'54')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'55')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'56')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'57')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'58')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'59')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'60')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'61')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'62')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'63')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'64')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'65')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'66')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'67')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'68')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'69')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'70')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'71')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'72')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'73')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'74')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'75')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'76')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'77')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'78')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'79')
INSERT [dbo].[CampingSiteAdditions] ([additionname], [campingid]) VALUES (N'Ekstra god udsigt', N'80')
GO
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'10', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'100', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'100', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'101', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'101', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'101', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'101', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'101', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'101', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'102', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'102', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'102', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'102', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'102', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'102', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'103', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'103', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'103', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'103', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'103', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'103', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'104', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'104', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'104', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'104', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'104', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'104', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'105', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'105', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'105', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'105', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'105', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'105', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'106', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'106', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'106', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'106', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'106', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'106', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'107', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'107', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'107', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'107', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'107', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'107', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'108', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'108', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'108', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'108', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'108', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'108', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'109', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'109', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'109', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'109', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'109', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'109', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'11', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'11', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'11', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'11', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'11', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'110', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'110', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'110', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'110', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'110', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'110', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'111', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'111', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'111', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'111', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'111', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'111', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'112', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'112', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'112', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'112', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'112', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'112', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'113', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'113', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'114', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'114', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'114', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'114', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'114', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'114', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'115', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'115', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'115', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'115', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'115', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'115', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'116', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'116', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'116', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'116', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'116', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'116', N'Vinter')
GO
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'117', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'117', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'117', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'117', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'117', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'117', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'118', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'118', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'119', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'119', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'119', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'119', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'119', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'119', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'12', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'12', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'12', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'12', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'12', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'120', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'120', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'120', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'120', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'120', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'120', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'121', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'121', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'121', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'121', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'121', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'121', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'122', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'122', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'122', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'122', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'122', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'122', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'123', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'123', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'123', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'123', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'123', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'123', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'124', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'124', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'124', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'124', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'124', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'124', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'125', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'125', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'125', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'125', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'125', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'125', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'126', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'126', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'127', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'127', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'128', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'128', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'129', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'129', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'13', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'13', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'13', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'13', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'13', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'130', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'130', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'131', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'131', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'132', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'132', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'133', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'133', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'134', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'134', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'135', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'135', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'136', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'136', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'137', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'137', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'138', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'138', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'139', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'139', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'140', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'140', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'141', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'141', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'142', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'142', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'143', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'143', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'144', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'144', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'145', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'145', N'Teltplads')
GO
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'146', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'146', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'147', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'147', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'148', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'148', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'149', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'149', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'15', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'15', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'150', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'150', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'151', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'151', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'151', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'151', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'151', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'151', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'152', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'152', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'152', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'152', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'152', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'152', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'153', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'153', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'153', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'153', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'153', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'153', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'154', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'154', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'154', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'154', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'154', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'154', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'155', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'155', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'155', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'155', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'155', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'155', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'156', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'156', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'156', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'156', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'156', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'156', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'157', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'157', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'157', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'157', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'157', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'157', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'158', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'158', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'158', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'158', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'158', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'158', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'159', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'159', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'159', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'159', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'159', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'159', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'16', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'16', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'160', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'160', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'160', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'160', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'160', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'160', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'161', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'162', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'163', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'164', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'165', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'166', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'167', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'168', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'169', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'17', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'17', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'170', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'171', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'172', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'173', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'174', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'175', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'176', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'177', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'178', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'179', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'18', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'18', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'180', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'181', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'182', N'Stor campingplads')
GO
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'183', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'184', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'185', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'186', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'187', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'188', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'189', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'19', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'19', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'190', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'191', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'192', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'193', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'194', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'195', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'196', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'197', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'198', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'199', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'2', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'2', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'2', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'2', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'2', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'20', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'20', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'200', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'201', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'201', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'202', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'202', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'203', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'203', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'204', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'204', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'204', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'204', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'204', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'204', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'205', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'205', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'205', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'205', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'205', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'205', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'206', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'206', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'206', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'206', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'206', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'206', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'207', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'207', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'207', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'207', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'207', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'207', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'208', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'208', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'208', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'208', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'208', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'208', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'209', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'209', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'209', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'209', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'209', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'209', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'21', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'21', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'210', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'210', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'210', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'210', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'210', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'210', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'211', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'211', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'211', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'211', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'211', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'211', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'212', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'212', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'212', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'212', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'212', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'212', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'213', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'213', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'213', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'213', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'213', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'213', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'214', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'214', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'214', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'214', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'214', N'Teltplads')
GO
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'214', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'215', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'215', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'215', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'215', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'215', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'215', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'216', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'216', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'216', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'216', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'216', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'216', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'217', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'217', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'217', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'217', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'217', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'217', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'218', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'218', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'218', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'218', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'218', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'218', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'219', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'219', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'219', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'219', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'219', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'219', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'22', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'22', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'220', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'220', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'220', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'220', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'220', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'220', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'221', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'221', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'221', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'221', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'221', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'221', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'222', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'222', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'223', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'223', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'224', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'224', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'225', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'225', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'226', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'226', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'227', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'227', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'228', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'228', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'229', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'229', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'23', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'23', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'230', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'230', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'231', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'231', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'232', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'232', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'233', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'233', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'234', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'234', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'235', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'235', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'236', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'236', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'237', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'237', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'238', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'238', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'239', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'239', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'24', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'24', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'240', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'240', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'241', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'241', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'242', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'242', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'243', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'243', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'244', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'244', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'245', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'245', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'246', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'246', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'247', N'Lille campingplads')
GO
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'247', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'248', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'248', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'249', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'249', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'25', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'25', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'250', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'250', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'251', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'251', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'252', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'252', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'253', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'253', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'254', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'254', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'255', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'255', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'256', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'256', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'257', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'257', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'258', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'258', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'259', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'259', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'26', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'26', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'260', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'260', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'261', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'261', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'262', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'262', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'263', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'263', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'264', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'264', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'265', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'265', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'266', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'266', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'267', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'267', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'268', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'268', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'269', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'269', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'27', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'27', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'270', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'270', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'271', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'271', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'272', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'272', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'273', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'273', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'274', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'274', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'275', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'275', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'276', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'276', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'277', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'277', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'278', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'278', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'279', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'279', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'28', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'28', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'280', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'280', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'281', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'281', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'282', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'282', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'283', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'283', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'284', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'284', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'285', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'285', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'286', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'286', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'287', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'287', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'288', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'288', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'289', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'289', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'29', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'29', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'290', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'290', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'291', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'291', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'292', N'Lille campingplads')
GO
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'292', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'293', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'293', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'294', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'294', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'295', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'295', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'296', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'296', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'297', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'297', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'298', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'298', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'299', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'299', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'3', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'3', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'3', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'3', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'3', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'30', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'300', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'300', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'301', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'301', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'302', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'302', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'303', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'303', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'304', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'304', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'305', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'305', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'306', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'306', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'307', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'307', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'308', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'308', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'309', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'309', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'31', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'32', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'33', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'34', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'35', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'36', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'37', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'38', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'39', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'4', N'Efterår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'4', N'Forår')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'4', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'4', N'Sommer')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'4', N'Vinter')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'40', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'41', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'42', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'43', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'44', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'45', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'46', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'47', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'48', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'49', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'50', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'51', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'52', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'53', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'54', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'55', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'56', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'57', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'58', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'59', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'6', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'60', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'61', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'62', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'63', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'64', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'65', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'66', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'67', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'68', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'69', N'Stor campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'70', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'70', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'71', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'71', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'72', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'72', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'73', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'73', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'74', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'74', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'75', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'75', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'76', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'76', N'Teltplads')
GO
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'77', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'77', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'78', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'78', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'79', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'79', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'80', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'80', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'81', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'81', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'82', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'82', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'83', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'83', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'84', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'84', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'85', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'85', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'86', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'86', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'87', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'87', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'88', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'88', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'89', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'89', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'9', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'90', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'90', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'91', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'91', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'92', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'92', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'93', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'93', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'94', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'94', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'95', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'95', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'96', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'96', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'97', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'97', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'98', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'98', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'99', N'Lille campingplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'99', N'Teltplads')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H1', N'Standard hytte (4 pers.)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H10', N'Luksus hytte (4-6 pers)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H11', N'Luksus hytte (4-6 pers)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H12', N'Luksus hytte (4-6 pers)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H13', N'Luksus hytte (4-6 pers)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H14', N'Luksus hytte (4-6 pers)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H15', N'Luksus hytte (4-6 pers)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H2', N'Standard hytte (4 pers.)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H3', N'Standard hytte (4 pers.)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H4', N'Standard hytte (4 pers.)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H5', N'Standard hytte (4 pers.)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H7', N'Standard hytte (4 pers.)')
INSERT [dbo].[CampingSiteTypes] ([campingid], [typename]) VALUES (N'H8', N'Standard hytte (4 pers.)')
GO
INSERT [dbo].[Campingtype] ([name]) VALUES (N'Efterår')
INSERT [dbo].[Campingtype] ([name]) VALUES (N'Forår')
INSERT [dbo].[Campingtype] ([name]) VALUES (N'Lille campingplads')
INSERT [dbo].[Campingtype] ([name]) VALUES (N'Luksus hytte (4-6 pers)')
INSERT [dbo].[Campingtype] ([name]) VALUES (N'Sommer')
INSERT [dbo].[Campingtype] ([name]) VALUES (N'Standard hytte (4 pers.)')
INSERT [dbo].[Campingtype] ([name]) VALUES (N'Stor campingplads')
INSERT [dbo].[Campingtype] ([name]) VALUES (N'Teltplads')
INSERT [dbo].[Campingtype] ([name]) VALUES (N'Vinter')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (555, N'Scanning')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (783, N'Facility')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (800, N'Høje Taastrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (877, N'København C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (892, N'Sjælland USF P')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (893, N'Sjælland USF B')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (894, N'Udbetaling')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (899, N'Kommuneservice')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (900, N'København C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (910, N'København C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (913, N'Københavns Pakkecenter')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (914, N'Københavns Pakkecenter')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (917, N'Københavns Pakkecenter')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (918, N'Københavns Pakke BRC')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (919, N'Returprint BRC')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (929, N'København C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (960, N'Internationalt Postcenter')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (999, N'København C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1001, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1002, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1003, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1004, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1005, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1006, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1007, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1008, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1009, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1010, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1011, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1012, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1013, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1014, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1015, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1016, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1017, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1018, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1019, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1020, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1021, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1022, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1023, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1024, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1025, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1026, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1045, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1050, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1051, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1052, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1053, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1054, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1055, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1056, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1057, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1058, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1059, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1060, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1061, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1062, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1063, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1064, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1065, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1066, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1067, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1068, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1069, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1070, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1071, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1072, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1073, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1074, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1092, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1093, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1095, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1098, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1100, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1101, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1102, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1103, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1104, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1105, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1106, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1107, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1110, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1111, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1112, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1113, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1114, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1115, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1116, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1117, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1118, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1119, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1120, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1121, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1122, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1123, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1124, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1125, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1126, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1127, N'København K')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1128, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1129, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1130, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1131, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1140, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1147, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1148, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1150, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1151, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1152, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1153, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1154, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1155, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1156, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1157, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1158, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1159, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1160, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1161, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1162, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1164, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1165, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1166, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1167, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1168, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1169, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1170, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1171, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1172, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1173, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1174, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1175, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1200, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1201, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1202, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1203, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1204, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1205, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1206, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1207, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1208, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1209, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1210, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1211, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1212, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1213, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1214, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1215, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1216, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1217, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1218, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1219, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1220, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1221, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1240, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1250, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1251, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1252, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1253, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1254, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1255, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1256, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1257, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1260, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1261, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1263, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1264, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1265, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1266, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1267, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1268, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1270, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1271, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1300, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1301, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1302, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1303, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1304, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1306, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1307, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1308, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1309, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1310, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1311, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1312, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1313, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1314, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1315, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1316, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1317, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1318, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1319, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1320, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1321, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1322, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1323, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1324, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1325, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1326, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1327, N'København K')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1328, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1329, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1350, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1352, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1353, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1354, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1355, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1356, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1357, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1358, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1359, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1360, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1361, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1362, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1363, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1364, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1365, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1366, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1367, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1368, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1369, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1370, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1371, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1400, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1401, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1402, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1403, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1406, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1407, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1408, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1409, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1410, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1411, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1412, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1413, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1414, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1415, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1416, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1417, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1418, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1419, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1420, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1421, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1422, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1423, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1424, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1425, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1426, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1427, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1428, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1429, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1430, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1432, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1433, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1434, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1435, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1436, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1437, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1438, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1439, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1440, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1441, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1448, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1450, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1451, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1452, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1453, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1454, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1455, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1456, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1457, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1458, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1459, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1460, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1461, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1462, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1463, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1464, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1465, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1466, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1467, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1468, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1470, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1471, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1472, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1473, N'København K')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1500, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1501, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1502, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1503, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1504, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1505, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1506, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1507, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1508, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1509, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1510, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1512, N'Returpost')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1513, N'Flytninger og Nejtak')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1532, N'København V')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1533, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1550, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1551, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1552, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1553, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1554, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1555, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1556, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1557, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1558, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1559, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1560, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1561, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1562, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1563, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1564, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1567, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1568, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1569, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1570, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1571, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1572, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1573, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1574, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1575, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1576, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1577, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1592, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1599, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1600, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1601, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1602, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1603, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1604, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1605, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1606, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1607, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1608, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1609, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1610, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1611, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1612, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1613, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1614, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1615, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1616, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1617, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1618, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1619, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1620, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1621, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1622, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1623, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1624, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1630, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1631, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1632, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1633, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1634, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1635, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1650, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1651, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1652, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1653, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1654, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1655, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1656, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1657, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1658, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1659, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1660, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1661, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1662, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1663, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1664, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1665, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1666, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1667, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1668, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1669, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1670, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1671, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1672, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1673, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1674, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1675, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1676, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1677, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1699, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1700, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1701, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1702, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1703, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1704, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1705, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1706, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1707, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1708, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1709, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1710, N'København V')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1711, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1712, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1714, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1715, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1716, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1717, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1718, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1719, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1720, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1721, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1722, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1723, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1724, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1725, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1726, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1727, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1728, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1729, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1730, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1731, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1732, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1733, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1734, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1735, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1736, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1737, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1738, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1739, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1749, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1750, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1751, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1752, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1753, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1754, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1755, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1756, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1757, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1758, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1759, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1760, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1761, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1762, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1763, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1764, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1765, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1766, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1770, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1771, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1772, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1773, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1774, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1775, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1777, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1780, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1782, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1785, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1786, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1787, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1790, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1799, N'København V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1800, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1801, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1802, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1803, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1804, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1805, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1806, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1807, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1808, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1809, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1810, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1811, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1812, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1813, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1814, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1815, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1816, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1817, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1818, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1819, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1820, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1822, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1823, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1824, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1825, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1826, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1827, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1828, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1829, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1835, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1850, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1851, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1852, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1853, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1854, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1855, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1856, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1857, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1860, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1861, N'Frederiksberg C')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1862, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1863, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1864, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1865, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1866, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1867, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1868, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1870, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1871, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1872, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1873, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1874, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1875, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1876, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1877, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1878, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1879, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1900, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1901, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1902, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1903, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1904, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1905, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1906, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1908, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1909, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1910, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1911, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1912, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1913, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1914, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1915, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1916, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1917, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1920, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1921, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1922, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1923, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1924, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1925, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1926, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1927, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1928, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1931, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1950, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1951, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1952, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1953, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1954, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1955, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1956, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1957, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1958, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1959, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1960, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1961, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1962, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1963, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1964, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1965, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1966, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1967, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1970, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1971, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1972, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1973, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (1974, N'Frederiksberg C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2000, N'Frederiksberg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2100, N'København Ø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2150, N'Nordhavn')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2200, N'København ')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2300, N'København S')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2400, N'København NV')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2412, N'Grønland')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2450, N'København SV')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2500, N'Valby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2600, N'Glostrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2605, N'Brøndby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2610, N'Rødovre')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2620, N'Albertslund')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2625, N'Vallensbæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2630, N'Taastrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2635, N'Ishøj')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2640, N'Hedehusene')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2650, N'Hvidovre')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2660, N'Brøndby Strand')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2665, N'Vallensbæk Strand')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2670, N'Greve')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2680, N'Solrød Strand')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2690, N'Karlslunde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2700, N'Brønshøj')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2720, N'Vanløse')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2730, N'Herlev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2740, N'Skovlunde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2750, N'Ballerup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2760, N'Måløv')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2765, N'Smørum')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2770, N'Kastrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2791, N'Dragør')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2800, N'Kongens Lyngby')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2820, N'Gentofte')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2830, N'Virum')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2840, N'Holte')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2850, N'Nærum')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2860, N'Søborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2870, N'Dyssegård')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2880, N'Bagsværd')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2900, N'Hellerup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2920, N'Charlottenlund')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2930, N'Klampenborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2942, N'Skodsborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2950, N'Vedbæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2960, N'Rungsted Kyst')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2970, N'Hørsholm')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2980, N'Kokkedal')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (2990, N'Nivå')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3000, N'Helsingør')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3050, N'Humlebæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3060, N'Espergærde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3070, N'Snekkersten')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3080, N'Tikøb')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3100, N'Hornbæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3120, N'Dronningmølle')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3140, N'Ålsgårde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3150, N'Hellebæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3200, N'Helsinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3210, N'Vejby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3220, N'Tisvildeleje')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3230, N'Græsted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3250, N'Gilleleje')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3300, N'Frederiksværk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3310, N'Ølsted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3320, N'Skævinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3330, N'Gørløse')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3360, N'Liseleje')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3370, N'Melby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3390, N'Hundested')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3400, N'Hillerød')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3450, N'Allerød')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3460, N'Birkerød')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3480, N'Fredensborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3490, N'Kvistgård')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3500, N'Værløse')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3520, N'Farum')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3540, N'Lynge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3550, N'Slangerup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3600, N'Frederikssund')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3630, N'Jægerspris')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3650, N'Ølstykke')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3660, N'Stenløse')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3670, N'Veksø Sjælland')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3700, N'Rønne')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3720, N'Aakirkeby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3730, N'Nexø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3740, N'Svaneke')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3751, N'Østermarie')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3760, N'Gudhjem')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3770, N'Allinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3782, N'Klemensker')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (3790, N'Hasle')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4000, N'Roskilde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4030, N'Tune')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4040, N'Jyllinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4050, N'Skibby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4060, N'Kirke Såby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4070, N'Kirke Hyllinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4100, N'Ringsted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4129, N'Ringsted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4130, N'Viby Sjælland')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4140, N'Borup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4160, N'Herlufmagle')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4171, N'Glumsø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4173, N'Fjenneslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4174, N'Jystrup Midtsj')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4180, N'Sorø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4190, N'Munke Bjergby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4200, N'Slagelse')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4220, N'Korsør')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4230, N'Skælskør')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4241, N'Vemmelev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4242, N'Boeslunde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4243, N'Rude')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4244, N'Agersø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4245, N'Omø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4250, N'Fuglebjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4261, N'Dalmose')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4262, N'Sandved')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4270, N'Høng')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4281, N'Gørlev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4291, N'Ruds Vedby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4293, N'Dianalund')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4295, N'Stenlille')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4296, N'Nyrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4300, N'Holbæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4305, N'Orø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4320, N'Lejre')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4330, N'Hvalsø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4340, N'Tølløse')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4350, N'Ugerløse')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4360, N'Kirke Eskilstrup')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4370, N'Store Merløse')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4390, N'Vipperød')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4400, N'Kalundborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4420, N'Regstrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4440, N'Mørkøv')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4450, N'Jyderup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4460, N'Snertinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4470, N'Svebølle')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4480, N'Store Fuglede')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4490, N'Jerslev Sjælland')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4500, N'Nykøbing Sj')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4520, N'Svinninge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4532, N'Gislinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4534, N'Hørve')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4540, N'Fårevejle')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4550, N'Asnæs')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4560, N'Vig')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4571, N'Grevinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4572, N'Nørre Asmindrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4573, N'Højby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4581, N'Rørvig')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4583, N'Sjællands Odde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4591, N'Føllenslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4592, N'Sejerø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4593, N'Eskebjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4600, N'Køge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4621, N'Gadstrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4622, N'Havdrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4623, N'Lille Skensved')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4632, N'Bjæverskov')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4640, N'Faxe')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4652, N'Hårlev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4653, N'Karise')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4654, N'Faxe Ladeplads')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4660, N'Store Heddinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4671, N'Strøby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4672, N'Klippinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4673, N'Rødvig Stevns')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4681, N'Herfølge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4682, N'Tureby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4683, N'Rønnede')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4684, N'Holmegaard')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4690, N'Haslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4700, N'Næstved')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4720, N'Præstø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4733, N'Tappernøje')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4735, N'Mern')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4736, N'Karrebæksminde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4750, N'Lundby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4760, N'Vordingborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4771, N'Kalvehave')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4772, N'Langebæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4773, N'Stensved')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4780, N'Stege')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4791, N'Borre')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4792, N'Askeby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4793, N'Bogø By')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4800, N'Nykøbing F')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4840, N'Nørre Alslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4850, N'Stubbekøbing')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4862, N'Guldborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4863, N'Eskilstrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4871, N'Horbelev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4872, N'Idestrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4873, N'Væggerløse')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4874, N'Gedser')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4880, N'Nysted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4891, N'Toreby L')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4892, N'Kettinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4894, N'Øster Ulslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4895, N'Errindlev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4900, N'Nakskov')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4912, N'Harpelunde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4913, N'Horslunde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4920, N'Søllested')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4930, N'Maribo')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4941, N'Bandholm')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4942, N'Askø og Lilleø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4943, N'Torrig L')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4944, N'Fejø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4945, N'Femø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4951, N'Nørreballe')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4952, N'Stokkemarke')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4953, N'Vesterborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4960, N'Holeby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4970, N'Rødby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4983, N'Dannemare')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4990, N'Sakskøbing')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (4992, N'Midtsjælland USF P')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5000, N'Odense C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5029, N'Odense C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5100, N'Odense C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5200, N'Odense V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5210, N'Odense NV')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5220, N'Odense SØ')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5230, N'Odense M')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5240, N'Odense NØ')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5250, N'Odense SV')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5260, N'Odense S')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5270, N'Odense ')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5290, N'Marslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5300, N'Kerteminde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5320, N'Agedrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5330, N'Munkebo')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5350, N'Rynkeby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5370, N'Mesinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5380, N'Dalby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5390, N'Martofte')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5400, N'Bogense')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5450, N'Otterup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5462, N'Morud')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5463, N'Harndrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5464, N'Brenderup Fyn')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5466, N'Asperup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5471, N'Søndersø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5474, N'Veflinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5485, N'Skamby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5491, N'Blommenslyst')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5492, N'Vissenbjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5500, N'Middelfart')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5540, N'Ullerslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5550, N'Langeskov')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5560, N'Aarup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5580, N'Nørre Aaby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5591, N'Gelsted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5592, N'Ejby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5600, N'Faaborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5601, N'Lyø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5602, N'Avernakø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5603, N'Bjørnø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5610, N'Assens')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5620, N'Glamsbjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5631, N'Ebberup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5642, N'Millinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5672, N'Broby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5683, N'Haarby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5690, N'Tommerup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5700, N'Svendborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5750, N'Ringe')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5762, N'Vester Skerninge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5771, N'Stenstrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5772, N'Kværndrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5792, N'Årslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5800, N'Nyborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5853, N'Ørbæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5854, N'Gislev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5856, N'Ryslinge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5863, N'Ferritslev Fyn')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5871, N'Frørup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5874, N'Hesselager')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5881, N'Skårup Fyn')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5882, N'Vejstrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5883, N'Oure')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5884, N'Gudme')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5892, N'Gudbjerg Sydfyn')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5900, N'Rudkøbing')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5932, N'Humble')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5935, N'Bagenkop')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5943, N'Strynø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5953, N'Tranekær')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5960, N'Marstal')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5965, N'Birkholm')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5970, N'Ærøskøbing')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (5985, N'Søby Ærø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6000, N'Kolding')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6040, N'Egtved')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6051, N'Almind')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6052, N'Viuf')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6064, N'Jordrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6070, N'Christiansfeld')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6091, N'Bjert')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6092, N'Sønder Stenderup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6093, N'Sjølund')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6094, N'Hejls')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6100, N'Haderslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6200, N'Aabenraa')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6210, N'Barsø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6230, N'Rødekro')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6240, N'Løgumkloster')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6261, N'Bredebro')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6270, N'Tønder')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6280, N'Højer')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6300, N'Gråsten')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6310, N'Broager')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6320, N'Egernsund')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6330, N'Padborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6340, N'Kruså')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6360, N'Tinglev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6372, N'Bylderup-Bov')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6392, N'Bolderslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6400, N'Sønderborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6430, N'Nordborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6440, N'Augustenborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6470, N'Sydals')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6500, N'Vojens')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6510, N'Gram')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6520, N'Toftlund')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6534, N'Agerskov')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6535, N'Branderup J')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6541, N'Bevtoft')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6560, N'Sommersted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6580, N'Vamdrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6600, N'Vejen')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6621, N'Gesten')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6622, N'Bække')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6623, N'Vorbasse')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6630, N'Rødding')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6640, N'Lunderskov')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6650, N'Brørup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6660, N'Lintrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6670, N'Holsted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6682, N'Hovborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6683, N'Føvling')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6690, N'Gørding')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6700, N'Esbjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6701, N'Esbjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6705, N'Esbjerg Ø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6710, N'Esbjerg V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6715, N'Esbjerg ')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6720, N'Fanø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6731, N'Tjæreborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6740, N'Bramming')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6752, N'Glejbjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6753, N'Agerbæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6760, N'Ribe')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6771, N'Gredstedbro')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6780, N'Skærbæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6792, N'Rømø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6800, N'Varde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6818, N'Årre')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6823, N'Ansager')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6830, N'Nørre Nebel')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6840, N'Oksbøl')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6851, N'Janderup Vestj')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6852, N'Billum')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6853, N'Vejers Strand')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6854, N'Henne')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6855, N'Outrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6857, N'Blåvand')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6862, N'Tistrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6870, N'Ølgod')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6880, N'Tarm')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6893, N'Hemmet')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6900, N'Skjern')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6920, N'Videbæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6933, N'Kibæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6940, N'Lem St')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6950, N'Ringkøbing')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6960, N'Hvide Sande')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6971, N'Spjald')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6973, N'Ørnhøj')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6980, N'Tim')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (6990, N'Ulfborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7000, N'Fredericia')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7007, N'Fredericia')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7017, N'Taulov Pakkecenter')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7018, N'Pakker TLP')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7029, N'Fredericia')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7080, N'Børkop')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7100, N'Vejle')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7120, N'Vejle Øst')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7130, N'Juelsminde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7140, N'Stouby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7150, N'Barrit')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7160, N'Tørring')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7171, N'Uldum')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7173, N'Vonge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7182, N'Bredsten')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7183, N'Randbøl')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7184, N'Vandel')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7190, N'Billund')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7200, N'Grindsted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7250, N'Hejnsvig')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7260, N'Sønder Omme')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7270, N'Stakroge')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7280, N'Sønder Felding')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7300, N'Jelling')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7321, N'Gadbjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7323, N'Give')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7330, N'Brande')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7361, N'Ejstrupholm')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7362, N'Hampen')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7400, N'Herning')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7429, N'Herning')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7430, N'Ikast')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7441, N'Bording')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7442, N'Engesvang')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7451, N'Sunds')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7470, N'Karup J')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7480, N'Vildbjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7490, N'Aulum')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7500, N'Holstebro')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7540, N'Haderup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7550, N'Sørvad')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7560, N'Hjerm')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7570, N'Vemb')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7600, N'Struer')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7620, N'Lemvig')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7650, N'Bøvlingbjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7660, N'Bækmarksbro')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7673, N'Harboøre')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7680, N'Thyborøn')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7700, N'Thisted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7730, N'Hanstholm')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7741, N'Frøstrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7742, N'Vesløs')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7752, N'Snedsted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7755, N'Bedsted Thy')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7760, N'Hurup Thy')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7770, N'Vestervig')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7790, N'Thyholm')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7800, N'Skive')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7830, N'Vinderup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7840, N'Højslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7850, N'Stoholm Jyll')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7860, N'Spøttrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7870, N'Roslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7884, N'Fur')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7900, N'Nykøbing M')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7950, N'Erslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7960, N'Karby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7970, N'Redsted M')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7980, N'Vils')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7990, N'Øster Assels')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7992, N'Sydjylland/Fyn USF P')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7993, N'Sydjylland/Fyn USF B')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7996, N'Fakturaservice')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7997, N'Fakturascanning')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7998, N'Statsservice')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (7999, N'Kommunepost')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8000, N'Aarhus C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8100, N'Aarhus C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8200, N'Aarhus ')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8210, N'Aarhus V')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8220, N'Brabrand')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8229, N'Risskov Ø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8230, N'Åbyhøj')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8240, N'Risskov')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8245, N'Risskov Ø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8250, N'Egå')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8260, N'Viby J')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8270, N'Højbjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8300, N'Odder')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8305, N'Samsø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8310, N'Tranbjerg J')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8320, N'Mårslet')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8330, N'Beder')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8340, N'Malling')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8350, N'Hundslund')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8355, N'Solbjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8361, N'Hasselager')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8362, N'Hørning')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8370, N'Hadsten')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8380, N'Trige')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8381, N'Tilst')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8382, N'Hinnerup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8400, N'Ebeltoft')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8410, N'Rønde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8420, N'Knebel')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8444, N'Balle')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8450, N'Hammel')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8462, N'Harlev J')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8464, N'Galten')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8471, N'Sabro')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8472, N'Sporup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8500, N'Grenaa')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8520, N'Lystrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8530, N'Hjortshøj')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8541, N'Skødstrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8543, N'Hornslet')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8544, N'Mørke')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8550, N'Ryomgård')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8560, N'Kolind')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8570, N'Trustrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8581, N'Nimtofte')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8585, N'Glesborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8586, N'Ørum Djurs')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8592, N'Anholt')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8600, N'Silkeborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8620, N'Kjellerup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8632, N'Lemming')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8641, N'Sorring')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8643, N'Ans By')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8653, N'Them')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8654, N'Bryrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8660, N'Skanderborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8670, N'Låsby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8680, N'Ry')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8700, N'Horsens')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8721, N'Daugård')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8722, N'Hedensted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8723, N'Løsning')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8732, N'Hovedgård')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8740, N'Brædstrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8751, N'Gedved')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8752, N'Østbirk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8762, N'Flemming')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8763, N'Rask Mølle')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8765, N'Klovborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8766, N'Nørre Snede')
GO
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8781, N'Stenderup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8783, N'Hornsyld')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8789, N'Endelave')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8799, N'Tunø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8800, N'Viborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8830, N'Tjele')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8831, N'Løgstrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8832, N'Skals')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8840, N'Rødkærsbro')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8850, N'Bjerringbro')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8860, N'Ulstrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8870, N'Langå')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8881, N'Thorsø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8882, N'Fårvang')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8883, N'Gjern')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8900, N'Randers C')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8920, N'Randers NV')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8930, N'Randers NØ')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8940, N'Randers SV')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8950, N'Ørsted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8960, N'Randers SØ')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8961, N'Allingåbro')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8963, N'Auning')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8970, N'Havndal')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8981, N'Spentrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8983, N'Gjerlev J')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (8990, N'Fårup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9000, N'Aalborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9029, N'Aalborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9100, N'Aalborg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9200, N'Aalborg SV')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9210, N'Aalborg SØ')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9220, N'Aalborg Øst')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9230, N'Svenstrup J')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9240, N'Nibe')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9260, N'Gistrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9270, N'Klarup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9280, N'Storvorde')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9293, N'Kongerslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9300, N'Sæby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9310, N'Vodskov')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9320, N'Hjallerup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9330, N'Dronninglund')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9340, N'Asaa')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9352, N'Dybvad')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9362, N'Gandrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9370, N'Hals')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9380, N'Vestbjerg')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9381, N'Sulsted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9382, N'Tylstrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9400, N'Nørresundby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9430, N'Vadum')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9440, N'Aabybro')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9460, N'Brovst')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9480, N'Løkken')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9490, N'Pandrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9492, N'Blokhus')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9493, N'Saltum')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9500, N'Hobro')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9510, N'Arden')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9520, N'Skørping')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9530, N'Støvring')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9541, N'Suldrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9550, N'Mariager')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9560, N'Hadsund')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9574, N'Bælum')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9575, N'Terndrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9600, N'Aars')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9610, N'Nørager')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9620, N'Aalestrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9631, N'Gedsted')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9632, N'Møldrup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9640, N'Farsø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9670, N'Løgstør')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9681, N'Ranum')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9690, N'Fjerritslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9700, N'Brønderslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9740, N'Jerslev J')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9750, N'Østervrå')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9760, N'Vrå')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9800, N'Hjørring')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9830, N'Tårs')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9850, N'Hirtshals')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9870, N'Sindal')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9881, N'Bindslev')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9900, N'Frederikshavn')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9940, N'Læsø')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9970, N'Strandby')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9981, N'Jerup')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9982, N'Ålbæk')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9990, N'Skagen')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9992, N'Jylland USF P')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9993, N'Jylland USF B')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9996, N'Fakturaservice')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9997, N'Fakturascanning')
INSERT [dbo].[CityCode] ([postal], [city]) VALUES (9998, N'Borgerservice')
GO
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'1234@hotmail.com', 4100, N'22694455', N'Kvejen 21', N'mand')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'Camping@gmail.com', 4760, N'12222222', N'Kildemarksvej 16D', N'Benjamin Hoffmeyer')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'dennyemail@gmail.com', 4100, N'22334455', N'Kaspvejen 21', N'mand')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'Hamdennyeseje@gmail.com', 4600, N'69420969', N'nicevej 21', N'Gurli Gris')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'hjeK', 4450, N'546565', N'dscdc', N'FSDCF')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'jensesmail@gmail.com', 4600, N'22334455', N'dendervej 12', N'Kav')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'kasperjeppesen@hotmail.dk', 4600, N'22343021', N'sejvej 25', N'Kasper Legendensen')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'kavmail@gmail.com', 4600, N'22334455', N'dendervej 12', N'Kav')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'ny@email.dk', 4400, N'52525252', N'minvej 13', N'jens')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'randomemail@gmail.com', 4100, N'45972841', N'randomvej 12', N'Hans Larsen')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'SnitzelKlaus@gmail.com', 4700, N'12345678', N'Næstvedvej 30', N'Benjamin Hoffmeyer')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'test@test.test', 4450, N'8888888', N'sdfds', N'hrdfg')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'Testc@mping.dk', 4733, N'12345678', N'Tappernøje', N'Benjamin Hoffmeyer')
INSERT [dbo].[Customer] ([email], [postal], [phone], [address], [name]) VALUES (N'testingc@mping.dk', 4700, N'12345678', N'Næstvedvej 30', N'Test tester')
GO
SET IDENTITY_INSERT [dbo].[DebugTable] ON 

INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (1, N'EXECUTE dbo.CreateReservation Testc@mping.dk, 31, Stor campingplads, 2021-06-30, 2021-06-30, Adgang til badeland (børn).1,Adgang til badeland (voksen).1,Børn.1,Morgenkomplet(børn).1,Morgenkomplet(voksen).1,Sengelinned.2,Voksne.1')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (2, N'EXECUTE dbo.CreateReservation test@test.test, 10, Lille campingplads, 2021-06-25, 2021-06-28, Adgang til badeland (børn).2,Adgang til badeland (voksen).2,Børn.2,Morgenkomplet(børn).2,Morgenkomplet(voksen).2,Sengelinned.2,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (3, N'EXECUTE dbo.CreateReservation test@test.test, 10, Lille campingplads, 2021-06-25, 2021-06-28, Adgang til badeland (børn).2,Adgang til badeland (voksen).2,Børn.2,Morgenkomplet(børn).2,Morgenkomplet(voksen).2,Sengelinned.2,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (4, N'EXECUTE dbo.CreateReservation testingc@mping.dk, 13, Forår, 2021-04-01, 2021-06-30, ')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (5, N'EXECUTE dbo.CreateReservation test@test.test, 9, Lille campingplads, 2021-06-25, 2021-06-25, Adgang til badeland (børn).2,Adgang til badeland (voksen).2,Børn.2,Morgenkomplet(børn).2,Morgenkomplet(voksen).2,Sengelinned.2,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (6, N'EXECUTE dbo.CreateReservation SnitzelKlaus@gmail.com, 17, Teltplads, 2021-06-28, 2021-06-30, Adgang til badeland (børn).1,Adgang til badeland (voksen).1,Børn.1,Morgenkomplet(børn).1,Morgenkomplet(voksen).1,Sengelinned.2,Voksne.1')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (7, N'EXECUTE dbo.CreateReservation testingc@mping.dk, 6, Lille campingplads, 2021-07-05, 2021-07-07, Adgang til badeland (børn).2,Adgang til badeland (voksen).2,Børn.2,Morgenkomplet(børn).2,Morgenkomplet(voksen).2,Sengelinned.4,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (8, N'EXECUTE dbo.CreateReservation testingc@mping.dk, 73, Lille campingplads, 2021-06-24, 2021-06-25, Adgang til badeland (børn).2,Adgang til badeland (voksen).2,Børn.2,Morgenkomplet(børn).2,Morgenkomplet(voksen).2,Sengelinned.4,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (9, N'EXECUTE dbo.CreateReservation testingc@mping.dk, 31, Stor campingplads, 2021-06-25, 2021-06-29, Adgang til badeland (børn).4,Adgang til badeland (voksen).3,Børn.4,Morgenkomplet(børn).5,Morgenkomplet(voksen).6,Sengelinned.6,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (10, N'EXECUTE dbo.CreateReservation testingc@mping.dk, 71, Lille campingplads, 2021-06-24, 2021-06-25, Adgang til badeland (børn).2,Adgang til badeland (voksen).2,Børn.2,Morgenkomplet(børn).2,Morgenkomplet(voksen).2,Sengelinned.4,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (11, N'EXECUTE dbo.CreateReservation testingc@mping.dk, 72, Lille campingplads, 2021-06-24, 2021-06-25, Adgang til badeland (børn).2,Adgang til badeland (voksen).2,Børn.2,Morgenkomplet(børn).2,Morgenkomplet(voksen).2,Sengelinned.4,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (12, N'EXECUTE dbo.CreateReservation testingc@mping.dk, 12, Lille campingplads, 2021-06-26, 2021-06-30, Adgang til badeland (børn).3,Adgang til badeland (voksen).2,Børn.3,Morgenkomplet(børn).2,Morgenkomplet(voksen).1,Sengelinned.3,Voksne.1')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (13, N'EXECUTE dbo.CreateReservation testingc@mping.dk, 239, Lille campingplads, 2021-06-28, 2021-10-22, Adgang til badeland (børn).2,Adgang til badeland (voksen).2,Børn.2,Morgenkomplet(børn).2,Morgenkomplet(voksen).2,Sengelinned.4,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (14, N'EXECUTE dbo.CreateReservation SnitzelKlaus@gmail.com, H8, Standard hytte (4 pers.), 2021-06-25, 2040-08-31, Adgang til badeland (børn).42,Adgang til badeland (voksen).69,Børn.42,Morgenkomplet(børn).42,Morgenkomplet(voksen).69,Sengelinned.111,Slutrengøring.1,Voksne.69')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (15, N'EXECUTE dbo.CreateReservation SnitzelKlaus@gmail.com, H8, Standard hytte (4 pers.), 2021-06-25, 2040-08-31, Adgang til badeland (børn).42,Adgang til badeland (voksen).69,Børn.42,Morgenkomplet(børn).42,Morgenkomplet(voksen).69,Sengelinned.111,Slutrengøring.1,Voksne.69')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (16, N'EXECUTE dbo.CreateReservation SnitzelKlaus@gmail.com, H8, Standard hytte (4 pers.), 2021-06-25, 2040-08-31, Adgang til badeland (børn).4,Adgang til badeland (voksen).2,Børn.4,Morgenkomplet(børn).4,Morgenkomplet(voksen).2,Sengelinned.6,Slutrengøring.1,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (17, N'EXECUTE dbo.CreateReservation SnitzelKlaus@gmail.com, H8, Standard hytte (4 pers.), 2021-06-25, 2040-08-31, Adgang til badeland (børn).4,Adgang til badeland (voksen).2,Børn.4,Morgenkomplet(børn).4,Morgenkomplet(voksen).2,Sengelinned.6,Slutrengøring.1,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (18, N'EXECUTE dbo.CreateReservation SnitzelKlaus@gmail.com, 2, Lille campingplads, 2021-06-28, 2021-10-08, Adgang til badeland (børn).4,Adgang til badeland (voksen).4,Børn.4,Morgenkomplet(børn).4,Morgenkomplet(voksen).4,Sengelinned.8,Voksne.4')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (19, N'EXECUTE dbo.CreateReservation SnitzelKlaus@gmail.com, 3, Lille campingplads, 2021-06-30, 2021-07-10, Adgang til badeland (børn).3,Adgang til badeland (voksen).2,Børn.3,Morgenkomplet(børn).3,Morgenkomplet(voksen).2,Sengelinned.5,Voksne.2')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (20, N'EXECUTE dbo.CreateReservation SnitzelKlaus@gmail.com, 9, Lille campingplads, 2021-06-30, 2021-07-10, Voksne.1')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (21, N'EXECUTE dbo.CreateReservation kasperjeppesen@hotmail.dk, 18, Lille campingplads, 2021-06-27, 2021-07-01, Børn.7,Morgenkomplet(voksen).1,Voksne.1')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (22, N'EXECUTE dbo.CreateReservation kasperjeppesen@hotmail.dk, 20, Lille campingplads, 2021-06-26, 2021-07-03, 1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen.1')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (23, N'EXECUTE dbo.CreateReservation Hamdennyeseje@gmail.com, H11, Luksus hytte (4-6 pers), 2021-06-26, 2021-07-10, Sengelinned.4,Slutrengøring.1,Voksne.4')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (24, N'EXECUTE dbo.CreateReservation kasperjeppesen@hotmail.dk, 78, Teltplads, 2021-06-26, 2021-07-03, 1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen.1')
INSERT [dbo].[DebugTable] ([ID], [sql]) VALUES (25, N'EXECUTE dbo.CreateReservation kasperjeppesen@hotmail.dk, 108, Sommer, 2021-04-01, 2021-09-30, ')
SET IDENTITY_INSERT [dbo].[DebugTable] OFF
GO
SET IDENTITY_INSERT [dbo].[Reservation] ON 

INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (104829, N'kasperjeppesen@hotmail.dk', N'44', N'Stor campingplads', CAST(N'2021-06-11' AS Date), CAST(N'2021-06-18' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (104898, N'kasperjeppesen@hotmail.dk', N'H5', N'Standard hytte (4 pers.)', CAST(N'2021-02-06' AS Date), CAST(N'2021-02-16' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (105174, N'kasperjeppesen@hotmail.dk', N'H13', N'Luksus hytte (4-6 pers)', CAST(N'2021-07-06' AS Date), CAST(N'2021-07-16' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (107520, N'kasperjeppesen@hotmail.dk', N'10', N'Lille campingplads', CAST(N'2021-07-06' AS Date), CAST(N'2021-07-16' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (107727, N'kasperjeppesen@hotmail.dk', N'H14', N'Luksus hytte (4-6 pers)', CAST(N'2021-07-06' AS Date), CAST(N'2021-07-16' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (107865, N'dennyemail@gmail.com', N'100', N'Lille campingplads', CAST(N'2021-06-16' AS Date), CAST(N'2021-06-21' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (107934, N'dennyemail@gmail.com', N'101', N'Lille campingplads', CAST(N'2021-06-16' AS Date), CAST(N'2021-06-21' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (108003, N'dennyemail@gmail.com', N'102', N'Lille campingplads', CAST(N'2021-06-16' AS Date), CAST(N'2021-06-21' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (108141, N'kasperjeppesen@hotmail.dk', N'70', N'Lille campingplads', CAST(N'2021-06-14' AS Date), CAST(N'2021-06-16' AS Date), 1, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (108210, N'kasperjeppesen@hotmail.dk', N'72', N'Lille campingplads', CAST(N'2021-06-10' AS Date), CAST(N'2021-06-15' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (108279, N'1234@hotmail.com', N'104', N'Lille campingplads', CAST(N'2021-06-17' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (108348, N'1234@hotmail.com', N'105', N'Lille campingplads', CAST(N'2021-06-17' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (108624, N'kasperjeppesen@hotmail.dk', N'70', N'Lille campingplads', CAST(N'2021-06-15' AS Date), CAST(N'2021-06-18' AS Date), 1, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (108693, N'kasperjeppesen@hotmail.dk', N'72', N'Lille campingplads', CAST(N'2021-06-18' AS Date), CAST(N'2021-06-22' AS Date), 1, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (108762, N'test@test.test', N'128', N'Lille campingplads', CAST(N'2021-06-22' AS Date), CAST(N'2021-06-29' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (108900, N'test@test.test', N'70', N'Lille campingplads', CAST(N'2021-06-22' AS Date), CAST(N'2021-07-01' AS Date), 1, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (108969, N'kasperjeppesen@hotmail.dk', N'102', N'Lille campingplads', CAST(N'2021-06-23' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (109038, N'kasperjeppesen@hotmail.dk', N'101', N'Lille campingplads', CAST(N'2021-06-23' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (109245, N'ny@email.dk', N'153', N'Lille campingplads', CAST(N'2021-06-23' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (109314, N'ny@email.dk', N'60', N'Stor campingplads', CAST(N'2021-06-23' AS Date), CAST(N'2021-06-25' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (109797, N'ny@email.dk', N'152', N'Lille campingplads', CAST(N'2021-06-30' AS Date), CAST(N'2021-07-03' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (110073, N'test@test.test', N'156', N'Lille campingplads', CAST(N'2021-06-23' AS Date), CAST(N'2021-07-03' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (110211, N'test@test.test', N'155', N'Lille campingplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-07-02' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (110349, N'ny@email.dk', N'158', N'Lille campingplads', CAST(N'2021-06-24' AS Date), CAST(N'2021-07-01' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (110418, N'kasperjeppesen@hotmail.dk', N'H12', N'Luksus hytte (4-6 pers)', CAST(N'2021-06-24' AS Date), CAST(N'2021-07-01' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (110487, N'test@test.test', N'160', N'Lille campingplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (110556, N'ny@email.dk', N'201', N'Lille campingplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (110763, N'ny@email.dk', N'202', N'Lille campingplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (110832, N'test@test.test', N'151', N'Lille campingplads', CAST(N'2021-07-01' AS Date), CAST(N'2021-07-08' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (110901, N'ny@email.dk', N'149', N'Lille campingplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (111246, N'kasperjeppesen@hotmail.dk', N'4', N'Lille campingplads', CAST(N'2021-06-24' AS Date), CAST(N'2021-06-27' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (112350, N'kasperjeppesen@hotmail.dk', N'4', N'Efterår', CAST(N'2021-08-15' AS Date), CAST(N'2021-10-31' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (112695, N'test@test.test', N'12', N'Efterår', CAST(N'2021-08-15' AS Date), CAST(N'2021-10-31' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (112764, N'kasperjeppesen@hotmail.dk', N'3', N'Lille campingplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-06-27' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (112833, N'Testc@mping.dk', N'2', N'Lille campingplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-06-27' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (112902, N'Testc@mping.dk', N'3', N'Efterår', CAST(N'2021-08-15' AS Date), CAST(N'2021-10-31' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (112971, N'Testc@mping.dk', N'H15', N'Luksus hytte (4-6 pers)', CAST(N'2021-07-05' AS Date), CAST(N'2021-07-08' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113040, N'testingc@mping.dk', N'15', N'Teltplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113109, N'Testc@mping.dk', N'74', N'Teltplads', CAST(N'2021-06-28' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113178, N'testingc@mping.dk', N'H1', N'Standard hytte (4 pers.)', CAST(N'2021-06-30' AS Date), CAST(N'2021-07-08' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113247, N'testingc@mping.dk', N'4', N'Lille campingplads', CAST(N'2021-06-30' AS Date), CAST(N'2021-07-06' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113316, N'testingc@mping.dk', N'6', N'Lille campingplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-06-26' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113385, N'testingc@mping.dk', N'11', N'Sommer', CAST(N'2021-04-01' AS Date), CAST(N'2021-09-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113454, N'Testc@mping.dk', N'31', N'Stor campingplads', CAST(N'2021-06-30' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113523, N'test@test.test', N'10', N'Lille campingplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-06-28' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113592, N'testingc@mping.dk', N'13', N'Forår', CAST(N'2021-04-01' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113661, N'test@test.test', N'9', N'Lille campingplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-06-25' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113730, N'SnitzelKlaus@gmail.com', N'17', N'Teltplads', CAST(N'2021-06-28' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113799, N'testingc@mping.dk', N'6', N'Lille campingplads', CAST(N'2021-07-05' AS Date), CAST(N'2021-07-07' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113868, N'testingc@mping.dk', N'31', N'Stor campingplads', CAST(N'2021-06-25' AS Date), CAST(N'2021-06-29' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (113937, N'testingc@mping.dk', N'71', N'Lille campingplads', CAST(N'2021-06-24' AS Date), CAST(N'2021-06-25' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (114006, N'testingc@mping.dk', N'72', N'Lille campingplads', CAST(N'2021-06-24' AS Date), CAST(N'2021-06-25' AS Date), 1, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (114075, N'testingc@mping.dk', N'12', N'Lille campingplads', CAST(N'2021-06-26' AS Date), CAST(N'2021-06-30' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (114144, N'testingc@mping.dk', N'239', N'Lille campingplads', CAST(N'2021-06-28' AS Date), CAST(N'2021-10-22' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (114489, N'SnitzelKlaus@gmail.com', N'2', N'Lille campingplads', CAST(N'2021-06-28' AS Date), CAST(N'2021-10-08' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (114558, N'SnitzelKlaus@gmail.com', N'3', N'Lille campingplads', CAST(N'2021-06-30' AS Date), CAST(N'2021-07-10' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (114627, N'SnitzelKlaus@gmail.com', N'9', N'Lille campingplads', CAST(N'2021-06-30' AS Date), CAST(N'2021-07-10' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (114696, N'kasperjeppesen@hotmail.dk', N'18', N'Lille campingplads', CAST(N'2021-06-27' AS Date), CAST(N'2021-07-01' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (114765, N'kasperjeppesen@hotmail.dk', N'20', N'Lille campingplads', CAST(N'2021-06-26' AS Date), CAST(N'2021-07-03' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (114834, N'Hamdennyeseje@gmail.com', N'H11', N'Luksus hytte (4-6 pers)', CAST(N'2021-06-26' AS Date), CAST(N'2021-07-10' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (114903, N'kasperjeppesen@hotmail.dk', N'78', N'Teltplads', CAST(N'2021-06-26' AS Date), CAST(N'2021-07-03' AS Date), 0, 0)
INSERT [dbo].[Reservation] ([ordernumber], [email], [campingid], [typename], [startdate], [enddate], [checkin], [checkout]) VALUES (114972, N'kasperjeppesen@hotmail.dk', N'108', N'Sommer', CAST(N'2021-04-01' AS Date), CAST(N'2021-09-30' AS Date), 0, 0)
SET IDENTITY_INSERT [dbo].[Reservation] OFF
GO
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (104829, N'Voksne', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (104898, N'Børn', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (104898, N'Voksne', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (105174, N'Børn', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (105174, N'Voksne', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (107520, N'1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (107727, N'Børn', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (107727, N'Voksne', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (107865, N'Børn', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (107865, N'Voksne', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (107934, N'Børn', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (107934, N'Morgenkomplet(børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (107934, N'Voksne', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108003, N'Børn', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108003, N'Voksne', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108279, N'Børn', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108279, N'Voksne', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108348, N'Børn', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108348, N'Voksne', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108762, N'Børn', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108762, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108900, N'Børn', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108900, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108969, N'Børn', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (108969, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (109038, N'Børn', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (109038, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (109245, N'1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (109314, N'Børn', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (109314, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (109797, N'1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110073, N'Børn', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110073, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110211, N'1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110349, N'1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110418, N'Adgang til badeland (børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110418, N'Adgang til badeland (voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110418, N'Børn', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110418, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110487, N'Slutrengøring', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110556, N'Slutrengøring', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110763, N'Adgang til badeland (børn)', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110832, N'1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (110901, N'Voksne', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113661, N'Adgang til badeland (børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113661, N'Adgang til badeland (voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113661, N'Børn', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113661, N'Morgenkomplet(børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113661, N'Morgenkomplet(voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113661, N'Sengelinned', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113661, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113730, N'Adgang til badeland (børn)', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113730, N'Adgang til badeland (voksen)', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113730, N'Børn', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113730, N'Morgenkomplet(børn)', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113730, N'Morgenkomplet(voksen)', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113730, N'Sengelinned', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113730, N'Voksne', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113799, N'Adgang til badeland (børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113799, N'Adgang til badeland (voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113799, N'Børn', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113799, N'Morgenkomplet(børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113799, N'Morgenkomplet(voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113799, N'Sengelinned', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113799, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113868, N'Adgang til badeland (børn)', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113868, N'Adgang til badeland (voksen)', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113868, N'Børn', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113868, N'Morgenkomplet(børn)', 5)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113868, N'Morgenkomplet(voksen)', 6)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113868, N'Sengelinned', 6)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113868, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113937, N'Adgang til badeland (børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113937, N'Adgang til badeland (voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113937, N'Børn', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113937, N'Morgenkomplet(børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113937, N'Morgenkomplet(voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113937, N'Sengelinned', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (113937, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114006, N'Adgang til badeland (børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114006, N'Adgang til badeland (voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114006, N'Børn', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114006, N'Morgenkomplet(børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114006, N'Morgenkomplet(voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114006, N'Sengelinned', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114006, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114075, N'Adgang til badeland (børn)', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114075, N'Adgang til badeland (voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114075, N'Børn', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114075, N'Morgenkomplet(børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114075, N'Morgenkomplet(voksen)', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114075, N'Sengelinned', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114075, N'Voksne', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114144, N'Adgang til badeland (børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114144, N'Adgang til badeland (voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114144, N'Børn', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114144, N'Morgenkomplet(børn)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114144, N'Morgenkomplet(voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114144, N'Sengelinned', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114144, N'Voksne', 2)
GO
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114489, N'Adgang til badeland (børn)', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114489, N'Adgang til badeland (voksen)', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114489, N'Børn', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114489, N'Morgenkomplet(børn)', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114489, N'Morgenkomplet(voksen)', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114489, N'Sengelinned', 8)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114489, N'Voksne', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114558, N'Adgang til badeland (børn)', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114558, N'Adgang til badeland (voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114558, N'Børn', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114558, N'Morgenkomplet(børn)', 3)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114558, N'Morgenkomplet(voksen)', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114558, N'Sengelinned', 5)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114558, N'Voksne', 2)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114627, N'Voksne', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114696, N'Børn', 7)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114696, N'Morgenkomplet(voksen)', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114696, N'Voksne', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114765, N'1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114834, N'Sengelinned', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114834, N'Slutrengøring', 1)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114834, N'Voksne', 4)
INSERT [dbo].[ReservationAddition] ([ordernumber], [additionname], [amount]) VALUES (114903, N'1 uges plads inkl 4 personer 6 x morgenmad og billetter til badeland hele ugen', 1)
GO
INSERT [dbo].[SeasonPeriods] ([from], [to], [SeasonName]) VALUES (CAST(N'1900-01-01' AS Date), CAST(N'9999-12-31' AS Date), N'Special')
INSERT [dbo].[SeasonPeriods] ([from], [to], [SeasonName]) VALUES (CAST(N'2020-10-01' AS Date), CAST(N'2021-03-31' AS Date), N'Vinter')
INSERT [dbo].[SeasonPeriods] ([from], [to], [SeasonName]) VALUES (CAST(N'2021-01-01' AS Date), CAST(N'2021-06-14' AS Date), N'Lavsæson')
INSERT [dbo].[SeasonPeriods] ([from], [to], [SeasonName]) VALUES (CAST(N'2021-04-01' AS Date), CAST(N'2021-06-30' AS Date), N'Forår')
INSERT [dbo].[SeasonPeriods] ([from], [to], [SeasonName]) VALUES (CAST(N'2021-04-01' AS Date), CAST(N'2021-09-30' AS Date), N'Sommer')
INSERT [dbo].[SeasonPeriods] ([from], [to], [SeasonName]) VALUES (CAST(N'2021-06-14' AS Date), CAST(N'2021-08-15' AS Date), N'Højsæson')
INSERT [dbo].[SeasonPeriods] ([from], [to], [SeasonName]) VALUES (CAST(N'2021-08-15' AS Date), CAST(N'2021-10-31' AS Date), N'Efterår')
INSERT [dbo].[SeasonPeriods] ([from], [to], [SeasonName]) VALUES (CAST(N'2021-08-15' AS Date), CAST(N'2021-12-31' AS Date), N'Lavsæson')
INSERT [dbo].[SeasonPeriods] ([from], [to], [SeasonName]) VALUES (CAST(N'2021-10-01' AS Date), CAST(N'2022-03-31' AS Date), N'Vinter')
GO
INSERT [dbo].[Seasons] ([name]) VALUES (N'Efterår')
INSERT [dbo].[Seasons] ([name]) VALUES (N'Forår')
INSERT [dbo].[Seasons] ([name]) VALUES (N'Højsæson')
INSERT [dbo].[Seasons] ([name]) VALUES (N'Lavsæson')
INSERT [dbo].[Seasons] ([name]) VALUES (N'Sommer')
INSERT [dbo].[Seasons] ([name]) VALUES (N'Special')
INSERT [dbo].[Seasons] ([name]) VALUES (N'Vinter')
GO
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Efterår', N'Efterår', CAST(2900.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Forår', N'Forår', CAST(4100.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Lille campingplads', N'Højsæson', CAST(50.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Lille campingplads', N'Lavsæson', CAST(60.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Luksus hytte (4-6 pers)', N'Højsæson', CAST(850.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Luksus hytte (4-6 pers)', N'Lavsæson', CAST(600.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Sommer', N'Sommer', CAST(9300.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Standard hytte (4 pers.)', N'Højsæson', CAST(500.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Standard hytte (4 pers.)', N'Lavsæson', CAST(350.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Stor campingplads', N'Højsæson', CAST(80.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Stor campingplads', N'Lavsæson', CAST(65.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Teltplads', N'Højsæson', CAST(35.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Teltplads', N'Lavsæson', CAST(45.00 AS Numeric(8, 2)))
INSERT [dbo].[TypeSeason] ([typename], [seasonname], [price]) VALUES (N'Vinter', N'Vinter', CAST(3500.00 AS Numeric(8, 2)))
GO
ALTER TABLE [dbo].[AuditTable] ADD  DEFAULT (getdate()) FOR [Time]
GO
ALTER TABLE [dbo].[CampingSite] ADD  DEFAULT ((0)) FOR [clean]
GO
ALTER TABLE [dbo].[Reservation] ADD  DEFAULT ((0)) FOR [checkin]
GO
ALTER TABLE [dbo].[Reservation] ADD  DEFAULT ((0)) FOR [checkout]
GO
ALTER TABLE [dbo].[AdditionsSeason]  WITH CHECK ADD FOREIGN KEY([additionname])
REFERENCES [dbo].[Additions] ([name])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[AdditionsSeason]  WITH CHECK ADD FOREIGN KEY([seasonname])
REFERENCES [dbo].[Seasons] ([name])
GO
ALTER TABLE [dbo].[CampingSiteAdditions]  WITH CHECK ADD FOREIGN KEY([additionname])
REFERENCES [dbo].[CampingAddition] ([name])
GO
ALTER TABLE [dbo].[CampingSiteAdditions]  WITH CHECK ADD FOREIGN KEY([campingid])
REFERENCES [dbo].[CampingSite] ([id])
GO
ALTER TABLE [dbo].[CampingSiteTypes]  WITH CHECK ADD FOREIGN KEY([campingid])
REFERENCES [dbo].[CampingSite] ([id])
GO
ALTER TABLE [dbo].[CampingSiteTypes]  WITH CHECK ADD FOREIGN KEY([typename])
REFERENCES [dbo].[Campingtype] ([name])
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD FOREIGN KEY([postal])
REFERENCES [dbo].[CityCode] ([postal])
GO
ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD FOREIGN KEY([campingid])
REFERENCES [dbo].[CampingSite] ([id])
GO
ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD FOREIGN KEY([email])
REFERENCES [dbo].[Customer] ([email])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD FOREIGN KEY([typename])
REFERENCES [dbo].[Campingtype] ([name])
GO
ALTER TABLE [dbo].[ReservationAddition]  WITH CHECK ADD FOREIGN KEY([additionname])
REFERENCES [dbo].[Additions] ([name])
ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[ReservationAddition]  WITH CHECK ADD FOREIGN KEY([ordernumber])
REFERENCES [dbo].[Reservation] ([ordernumber])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[SeasonPeriods]  WITH CHECK ADD FOREIGN KEY([SeasonName])
REFERENCES [dbo].[Seasons] ([name])
GO
ALTER TABLE [dbo].[TypeSeason]  WITH CHECK ADD FOREIGN KEY([seasonname])
REFERENCES [dbo].[Seasons] ([name])
GO
ALTER TABLE [dbo].[TypeSeason]  WITH CHECK ADD FOREIGN KEY([typename])
REFERENCES [dbo].[Campingtype] ([name])
GO
ALTER TABLE [dbo].[AuditTable]  WITH CHECK ADD CHECK  (([Type]='Insert' OR [Type]='Update'))
GO
ALTER TABLE [dbo].[Reservation]  WITH CHECK ADD  CONSTRAINT [CK__Reservation__6E01572D] CHECK  (([dbo].[IsTypenameValid]([typename],[campingid])=(1)))
GO
ALTER TABLE [dbo].[Reservation] CHECK CONSTRAINT [CK__Reservation__6E01572D]
GO
ALTER TABLE [dbo].[ReservationAddition]  WITH CHECK ADD  CONSTRAINT [CHK_IsValid] CHECK  (([dbo].[IsReservationAdditionValid]([ordernumber],[additionname])=(1)))
GO
ALTER TABLE [dbo].[ReservationAddition] CHECK CONSTRAINT [CHK_IsValid]
GO
/****** Object:  StoredProcedure [dbo].[CreateCustomer]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CreateCustomer] 
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
/****** Object:  StoredProcedure [dbo].[CreateReservation]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- This is how to use it DECLARE @ID INT;
-- EXECUTE dbo.CreateReservation 'kasperjeppesen@hotmail.dk', 'H13', 'Luksus hytte (4-6 pers)', '2021-07-06', '2021-07-16', 'Voksne.3,Børn.3', @ReservationID = @ID OUTPUT;
-- SELECT @ID
-- =============================================
CREATE   PROCEDURE [dbo].[CreateReservation]
	-- Add the parameters for the stored procedure here
	@email VARCHAR(30),
	@campingid VARCHAR(3),
	@typename VARCHAR(30),
	@startdate DATE,
	@enddate DATE,
	@additionsandamount VARCHAR(MAX),
	@ReservationID INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ordernumber INT

	DECLARE @script VARCHAR(MAX)
	SET @script = 'EXECUTE dbo.CreateReservation ' + @email +', ' +@campingid+', ' +@typename+', ' +CAST(@startdate AS VARCHAR)+', ' +CAST(@enddate AS VARCHAR)+', ' +@additionsandamount

	INSERT INTO DebugTable SELECT @script



	--Check if startdate is in further
	IF(@startdate < FORMAT(GETDATE(), 'yyyy-MM-dd') AND @typename NOT IN ('Forår', 'Efterår', 'Vinter', 'Sommer'))
		BEGIN
			RAISERROR('Startdate is in the past',16,1)
			RETURN NULL
		END

	--Check if there are any rows in avaliablesites 
	IF NOT EXISTS (SELECT * FROM dbo.GetAvaliableSites(@startdate, @enddate, @typename) WHERE id = @campingid)
		BEGIN
			RAISERROR('There is no avaliable sites at the period Or the type does not match',16,1)
			RETURN NULL
		END
	
	BEGIN TRANSACTION
	BEGIN TRY
		--insert reservation and return ordernumber
		INSERT INTO Reservation(email,campingid,typename,startdate,enddate)
		VALUES(@email, @campingid, @typename, @startdate, @enddate)
		SET @ordernumber  = SCOPE_IDENTITY()
		--Insert additions to table 
		IF(@typename NOT IN ('Forår', 'Efterår', 'Vinter', 'Sommer') AND (@additionsandamount IS NOT NULL OR @additionsandamount <> '')) --Skip this if it a seasontype and the addition is empty
			BEGIN
				INSERT INTO ReservationAddition(ordernumber,additionname,amount)
				SELECT @ordernumber
					, PARSENAME(a.value, 2) AS additionname
					, PARSENAME(a.value, 1) AS amount
				FROM STRING_SPLIT(@additionsandamount, ',') a
			END
				SET @ReservationID = @ordernumber
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	
		DECLARE @errmsg VARCHAR(MAX) 
		SELECT @errmsg = ERROR_MESSAGE()

		RAISERROR(@errmsg,16,1)

	ROLLBACK TRANSACTION 
	END CATCH
	RETURN @ReservationID
END
GO
/****** Object:  StoredProcedure [dbo].[DeleteReservation]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[DeleteReservation] @ordernumber INT
AS
DELETE FROM Reservation WHERE ordernumber = @ordernumber
;
GO
/****** Object:  StoredProcedure [dbo].[IsCustomerCreated]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Philip
-- Create date: <Create Date,,>
-- Description:	Return true if there is a customer with the specified email
-- DECLARE @result BIT
-- EXECUTE @result = dbo.IsCustomerCreated 'test'
-- SELECT @result
-- In C# the result should be a bool
-- =============================================
CREATE   PROCEDURE [dbo].[IsCustomerCreated]
	-- Add the parameters for the stored procedure here
	@email VARCHAR(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF EXISTS (SELECT * FROM Customer WHERE email = @email)
		RETURN 1
	ELSE 
		RETURN 0
END
GO
/****** Object:  StoredProcedure [dbo].[UpdateCustomer]    Script Date: 24/06/2021 15.08.37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UpdateCustomer] @oldemail VARCHAR(255), @email VARCHAR(255), @postal INT, @phone VARCHAR(20), @name VARCHAR(100), @address VARCHAR(255)
AS
--If customer change email it will automaticly change it in reservation table - ON UPDATE CASCADE
UPDATE Customer
SET email = @email
	, postal = @postal
	, phone = @phone
	, [name] = @name
	, [address] = @address
WHERE email = @oldemail;
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CampingSite"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 126
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CampingSiteTypes"
            Begin Extent = 
               Top = 7
               Left = 290
               Bottom = 126
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2544
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BungalowsToClean'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BungalowsToClean'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Customer"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Reservation"
            Begin Extent = 
               Top = 7
               Left = 290
               Bottom = 170
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3828
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CurrentReservationCustomers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CurrentReservationCustomers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1[50] 4[25] 3) )"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Customer"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Reservation"
            Begin Extent = 
               Top = 7
               Left = 290
               Bottom = 170
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2544
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'NextWeekReservationCustomers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'NextWeekReservationCustomers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Reservation"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Customer"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 338
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ReservationOverview'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ReservationOverview'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Customer"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 242
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Reservation"
            Begin Extent = 
               Top = 7
               Left = 290
               Bottom = 170
               Right = 484
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2352
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TodaysCustomers'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TodaysCustomers'
GO
USE [master]
GO
ALTER DATABASE [ZAP_Base] SET  READ_WRITE 
GO
