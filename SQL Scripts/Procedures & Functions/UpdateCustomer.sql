CREATE OR ALTER PROCEDURE UpdateCustomer @oldemail VARCHAR(255), @email VARCHAR(255), @postal INT, @phone VARCHAR(20), @name VARCHAR(100), @address VARCHAR(255)
AS
--If customer change email it will automaticly change it in reservation table - ON UPDATE CASCADE
UPDATE Customer
SET email = @email
	, postal = @postal
	, phone = @phone
	, [name] = @name
	, [address] = @address
WHERE email = @oldemail;