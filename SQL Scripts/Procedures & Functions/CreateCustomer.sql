
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