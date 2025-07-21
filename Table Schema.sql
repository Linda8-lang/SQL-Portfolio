USE Aluso -----Specifies the database to use
----First dimensional table
CREATE TABLE DimCustomer(
CustomerKey INT PRIMARY KEY NOT NULL,
CustomerID VARCHAR(24) NOT NULL,
CustomerName VARCHAR(24),
Email VARCHAR(24),
DateOfBirth VARCHAR(24),
MembershipStatus VARCHAR(24))
----Second dimensional table
CREATE TABLE DimTime(
TimeKey INT PRIMARY KEY NOT NULL,
TimeValue TIMESTAMP,
TimeOfDayCategory VARCHAR(24))
-----Third dimensional table
CREATE TABLE DimDate(
DateKey INT PRIMARY KEY NOT NULL,
ViewingDate DATE,
DayName VARCHAR(24))
---- Fourth dimensional table
CREATE TABLE DimRating(
RatingKey INT PRIMARY KEY NOT NULL,
RatingID VARCHAR(24) NOT NULL,
RatingValue int,
RatingDescription VARCHAR(64))
--DROP TABLE DimRating
------Fifth dimensional tab.le
CREATE TABLE DimVideo(
VideoKey INT PRIMARY KEY NOT NULL,
VideoID VARCHAR(24) NOT NULL,
VideoName VARCHAR(64),
RunTimeMinutes INT,
Genre VARCHAR(24),
ReleaseYear DATE NOT NULL,
Director VARCHAR(24),
Producer VARCHAR(24))
----Sixth dimensional table
CREATE TABLE DimCast(
CastKey INT PRIMARY KEY NOT NULL,
CastID VARCHAR(24) NOT NULL,
CastName VARCHAR(64),
Role VARCHAR(24))
----Bridge to break many to many relationship
CREATE TABLE BridgevideoCast(
CastKey INT,
VideoKey INT,
FOREIGN KEY (CastKey) REFERENCES DimCast(CastKey),
FOREIGN KEY (VideoKey) REFERENCES DimVideo(VideoKey))
----Fact Table
CREATE TABLE FactVideoViewing(
ViewingKey INT PRIMARY KEY IDENTITY(1,1),
VideoKey INT,
CustomerKey INT,
RatingKey INT,
DateKey INT,
TimeKey INT,
ViewingStartTime DATETIME,
ViewingEndTime DATETIME,
VideoWatched INT,
TrailerWatched INT,
VideoDownloaded INT,
PercentageWatched INT,
FOREIGN KEY (VideoKey) REFERENCES DimVideo(VideoKey),
FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
FOREIGN KEY (RatingKey) REFERENCES DimRating(RatingKey),
FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
FOREIGN KEY (TimeKey) REFERENCES DimTime(TimeKey)
)
--DROP TABLE FactVideoViewing
SELECT * FROM FactVideoViewing
