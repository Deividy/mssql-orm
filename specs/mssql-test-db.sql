CREATE TABLE dbo.Customers (
	Id int NOT NULL IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY CLUSTERED,
	FirstName varchar(100) NOT NULL,
	LastName varchar(100) NOT NULL
)

CREATE TABLE dbo.Products (
	Id int NOT NULL IDENTITY(1,1) CONSTRAINT PK_Products PRIMARY KEY CLUSTERED,
	ProductName varchar(200) NOT NULL,
	
	CONSTRAINT UQ_Products_ProductName UNIQUE NONCLUSTERED (ProductName)
)

CREATE TABLE dbo.Orders (
	Id int NOT NULL IDENTITY(1,1) CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED,
	CustomerId int NOT NULL,
	CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId) REFERENCES Customers,
	OrderDate datetime NOT NULL
)

CREATE TABLE dbo.OrderLines (
	Id int NOT NULL IDENTITY(1,1) CONSTRAINT PK_OrderLines PRIMARY KEY CLUSTERED,
	
	OrderId int NOT NULL,
	CONSTRAINT FK_OrdersLines_Orders FOREIGN KEY (OrderId) REFERENCES Orders,
	LineNumber int NOT NULL,
	CONSTRAINT UQ_OderId_LineId UNIQUE NONCLUSTERED (OrderId, LineNumber),
	
	ProductId int NOT NULL,
	CONSTRAINT FK_OrderLines_Products FOREIGN KEY (ProductId) REFERENCES Products
)




CREATE TABLE dbo.IdMap (
	Id int NOT NULL IDENTITY(1,1) CONSTRAINT PK_IdMap PRIMARY KEY CLUSTERED,
	Data varchar(50) NOT NULL,

	
)

CREATE TABLE dbo.FractionsGalore (
	Id int NOT NULL CONSTRAINT PK_FractionsGalore PRIMARY KEY CLUSTERED,
	Decimal284 decimal(28,4),
	Decimal304 decimal(30,4)
)

CREATE TABLE dbo.TypesGalore (
	Integer int NOT NULL, 
	RowVersionColumn rowversion, 
	VarCharMax varchar(max), 
	Decimal182 decimal(18,2) NOT NULL, 
	Bin100 binary(100),
	BinMax100 varbinary(max),
	Money money,
	Bit bit
)

CREATE TABLE A (
	Id int NOT NULL IDENTITY(1,1) CONSTRAINT PK_A PRIMARY KEY CLUSTERED,
	ParentId int 
)

CREATE TABLE B (
	Id int NOT NULL IDENTITY(1,1) CONSTRAINT PK_B PRIMARY KEY CLUSTERED,
	ParentId int
)

ALTER TABLE TypesGalore ADD CONSTRAINT PK_Foo PRIMARY KEY (Integer, Decimal182)



ALTER TABLE A ADD CONSTRAINT AToB FOREIGN KEY (ParentId) REFERENCES B (Id) 


