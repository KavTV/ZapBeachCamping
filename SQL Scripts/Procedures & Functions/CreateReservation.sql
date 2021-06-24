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
-- Author:		Philip
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- This is how to use it DECLARE @ID INT;
-- EXECUTE dbo.CreateReservation 'kasperjeppesen@hotmail.dk', 'H13', 'Luksus hytte (4-6 pers)', '2021-07-06', '2021-07-16', 'Voksne.3,Børn.3', @ReservationID = @ID OUTPUT;
-- SELECT @ID
-- =============================================
CREATE OR ALTER PROCEDURE CreateReservation
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
