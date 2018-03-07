Anirudh Subramanyam, Joseph Chou, Muatasim Qazi, Andreas Hindman
Final Database Code


USE WASTE_MANAGEMENT


/* Execute schema/create tables, see other file for updated schema */


/* STORED PROCEDURES */
/* Populates the Collection table */
CREATE PROCEDURE uspPopulateCollection
@CollectionWeight decimal(7, 3),
@CollectionDate Date,
@LocationName varchar(100),
@CollectorName varchar(100)


AS


BEGIN
DECLARE
@LocationID INT,
@CollectorID INT


SET @LocationID = (SELECT LocationID FROM tblLocation
                                WHERE LocationName = @LocationName)


SET @CollectorID = (SELECT CollectorID FROM tblCollector
                                WHERE CollectorName = @CollectorName)

BEGIN TRAN T1
INSERT INTO tblCollection(CollectionWeight, CollectionDate, LocationID, CollectorID)
VALUES (@CollectionWeight, @CollectionDate, @LocationID, @CollectorID)
COMMIT TRAN T1


END
GO


/*Populates the inciden table */
CREATE PROCEDURE uspPopulateIncident
@IncidentName varchar(100),
@IncidentDate DATE,
@IncidentDesc varchar(500) = NULL,
@TypeName varchar(100),
@CollectionWeight decimal(7, 3),
@CollectionDate Date
@Location varchar(100)


AS


BEGIN
DECLARE
@IncidentTypeID INT,
@CollectionID INT


SET @IncidentTypeID = (SELECT IncidentTypeID
FROM tblIncident_Type
                                WHERE Incident_TypeName = @TypeName)


SET @CollectionID = (SELECT CollectionID FROM tblCollection C
                                JOIN tblLocation L ON L.LocationID = C.LocationID
                                WHERE CollectionWeight = @CollectionWeight AND
                                CollectionDate = @CollectionDate AND
L.LocationName = @Location)

BEGIN TRAN T2
INSERT INTO tblIncident(IncidentName, IncidentDesc, IncidentDate, Incident_TypeID, CollectionID)
VALUES (@IncidentName, @IncidentDesc, @IncidentDate, @IncidentTypeID, @CollectionID)
COMMIT TRAN T2


END
GO


/*Populates the Collection_Item table */
CREATE PROCEDURE uspPopulateCollectionItem
@Item varchar(100),
@Weight numeric(7, 3),
@Date date,
@Location varchar(100)
@Qty int,
AS
BEGIN
DECLARE @ItemID INT
DECLARE @CollectionID INT


SET @ItemID = (SELECT ItemID FROM tblItem
                                WHERE ItemName = @Item)


SET @CollectionID = (SELECT CollectionID
                                                FROM tblCollection C
                                                JOIN tblLocation L ON L.LocationID = C.LocationID
                                                WHERE C.CollectionWeight = @Weight
                                                        AND C.CollectionDate = @Date
                                                        AND L.LocationName = @Location)


BEGIN TRAN T3
INSERT INTO tblCollection_Item (ItemID, CollectionID, Quantity)
VALUES (@ItemID, @CollectionID, @Qty)
COMMIT TRAN T3
END


GO


/*Populates the Item table */
CREATE PROCEDURE uspPopulateItem
@Name varchar(100),
@Desc varchar(500) = NULL,
@Category varchar(100)
AS
BEGIN
DECLARE @CatID INT
SET @CatID = (SELECT CategoryID FROM tblCategory
                                WHERE CategoryName = @Category)


BEGIN TRAN T4
INSERT INTO tblItem (ItemName, ItemDesc, CategoryID)
VALUES (@Name, @Desc, @CatID)
COMMIT TRAN T4
END


GO


/*Populates the Category table */
CREATE PROCEDURE uspPopulateCategory
@CategoryName VARCHAR(50),
@CategoryDesc VARCHAR(500) = NULL,
@ProcedureName VARCHAR(50)


AS
DECLARE @ProcedureID INT
SET @ProcedureID = (SELECT ProcedureID FROM tblProcedure
                             WHERE ProcedureName = @ProcedureName)
BEGIN TRAN T5
    INSERT INTO tblCategory(CategoryName, CategoryDesc, ProcedureID) VALUES(@CategoryName, @CategoryDesc, @ProcedureID)
COMMIT TRAN T5


GO


/*Populates the Schedule_Day table */
CREATE PROCEDURE uspPopulateScheduleDay
@ScheduleName VARCHAR(50),
@DayName VARCHAR(50)
AS
DECLARE @ScheduleID INT
DECLARE @DayID INT
SET @ScheduleID = (SELECT ScheduleID FROM tblSchedule
   WHERE ScheduleName = @ScheduleName)
SET @DayID = (SELECT DayID FROM tblDay WHERE DayName = @DayName)


BEGIN TRAN T6
INSERT INTO tblSchedule_Day(ScheduleID, DayID)
VALUES(@ScheduleID, @DayID)
COMMIT TRAN T6


GO


/*Populates the Location table */
CREATE PROCEDURE uspPopulateLocation
@Name varchar(100),
@Desc varchar(500) = NULL,
@LocTypeName varchar(100)
AS
BEGIN
DECLARE @LocTypeID INT
SET @LocTypeID = (SELECT Location_TypeID FROM tblLocation_Type
                                    WHERE Location_TypeName = @LocTypeName)
BEGIN TRAN T7
INSERT INTO tblLocation(LocationName, LocationDesc, Location_TypeID)
VALUES(@Name, @Desc, @LocTypeID)
COMMIT TRAN T7
END


GO


/*Populates the Collector table */
CREATE PROCEDURE uspPopulateCollector
@Name varchar(100),
@Desc varchar(500) = NULL,
@SchName varchar(100)
AS
BEGIN
DECLARE @SchID INT
SET @SchID = (SELECT ScheduleID FROM tblSchedule
                            WHERE ScheduleName = @SchName)
BEGIN TRAN T8
INSERT INTO tblCollector(CollectorName, CollectorDesc, ScheduleID)
VALUES(@Name, @Desc, @SchID)
COMMIT TRAN T8
END


/* BUSINESS RULES */
/* Collection weights should be under 2000 lbs and over 10 lbs */
CREATE FUNCTION fn_CheckWeight()
RETURNS INT
AS
BEGIN
        DECLARE @Ret INT = 0
        IF EXISTS (
                SELECT * FROM tblCollection C
                WHERE C.CollectionWeight < 10.000
OR C.CollectionWeight > 2000.000
        )
        SET @Ret = 1
RETURN @Ret
END
GO


ALTER TABLE tblCollection
ADD CONSTRAINT CK_CheckWeight
CHECK (dbo.fn_CheckWeight() = 0)


/* Collectors should not be scheduled to pick up on weekends */
CREATE FUNCTION fn_NoWeekendSchedule()
RETURNS INT
AS
BEGIN
        DECLARE @Ret INT = 0
        IF EXISTS (
                SELECT *
                FROM tblCOLLECTOR C
                JOIN tblSCHEDULE S ON C.ScheduleID = S.ScheduleID
                JOIN tblSCHEDULE_DAY SD ON SD.ScheduleID = S.ScheduleID
                JOIN tblDAY D ON D.DayID = SD.DayID
                WHERE [DayName] = 'Saturday'
                        OR [DayName] = 'Sunday'
        )
        SET @Ret = 1


RETURN @Ret
END


GO


ALTER TABLE tblCOLLECTOR
ADD CONSTRAINT CK_NoWeekendSchedule
CHECK (dbo.fn_NoWeekendSchedule() = 0)


/* A collection should not contain more than 10 different categories of items */
CREATE FUNCTION fn_CheckItemCat()
RETURNS INT
AS
BEGIN
DECLARE @Ret INT = 0
IF EXISTS(
SELECT C.CategoryName, COUNT(C.CategoryName)
FROM tblCategory C
JOIN tblItem I ON C.CategoryID = I.CategoryID
JOIN tblCollection_Item CI ON I.ItemID = CI.ItemID
JOIN tblCollection CO ON CI.CollectionID = CO.CollectionID
GROUP BY C.CategoryName
HAVING COUNT(C.CategoryName) > 10
)
SET @Ret = 1
RETURN @Ret
END


GO
ALTER TABLE tblCOLLECTION
ADD CONSTRAINT CK_CheckItemCat
CHECK (dbo.fn_CheckItemCat() = 0)




/* Hazardous materials should not be allowed to be collected in residence halls or dining halls */
CREATE FUNCTION fn_NoHazardInResidential()
RETURNS INT
AS
BEGIN
DECLARE @Ret INT = 0
IF EXISTS(
        SELECT *
        FROM tblCategory Cat
        JOIN tblItem I ON Cat.CategoryID = I.CategoryID
        JOIN tblCollection_Item CI ON I.ItemID = CI.ItemID
        JOIN tblCollection Col ON CI.CollectionID = Col.CollectionID
        JOIN tblLocation L ON Col.LocationID = L.LocationID
JOIN tblLocation_Type LT ON L.Location_TypeID =
LT.Location_TypeID
        WHERE (LT.Location_TypeName = 'Residence Hall'
        OR LT.Location_TypeName = 'Restaurant')
        AND Cat.CategoryName = 'Hazardous'
)
SET @Ret = 1
RETURN @Ret
END
ALTER TABLE tblCOLLECTION
ADD CONSTRAINT CK_NoHazardsCollectedFromResident
CHECK (dbo.fn_NoHazardInResidential() = 0)


/* EXAMPLES FOR POPULATING EACH TABLE IN THE DATABASE */
/* One example row is inserted into each table. */


/* Populate tblDay */
INSERT INTO tblDay([DayName], DayDesc)
VALUES ('Monday', 'Garfield you lazy cat')


/* Populate tblProcedure */
INSERT INTO tblProcedure(ProcedureName, ProcedureDesc)
VALUES ('Burn', 'Eviscerate the waste with fire')


/* Populate tblSchedule */
INSERT INTO tblSchedule(ScheduleName)
VALUES ('Angel''s Junk Removal Schedule')


/* Populate tblLocation_Type */
INSERT INTO tblLocation_Type(Location_TypeName, Location_TypeDesc)
VALUES ('Residence Hall', 'People live here.')


/* Populate tblIncident_Type */
INSERT INTO tblIncident_Type(Incident_TypeName, Incident_TypeDesc)
VALUES ('Late', 'Pickup not on schedule')


/* Populate tblLocation */
EXEC uspPopulateLocation
@Name = 'Mary Gates Hall',
@Desc = 'ischool is my school',
@LocTypeName = 'Academic'


/* Populate tblCategory */
EXECUTE uspPopulateCategory
@CategoryName = 'Food Waste',
@CategoryDesc = 'Edible trash',
@ProcedureName = 'Compost'


/* Populate tblCollector */
EXECUTE uspPopulateCollector
@Name = 'Angel''s Junk Removal',
@Desc = 'They remove junk spiritually',
@SchName = 'Angel''s Junk Removal Schedule'


/* Populate tblCollection */
EXEC uspPopulateCollection
@CollectionWeight = '59.494',
@CollectionDate = 'December 1, 2017',
@LocationName = 'Mary Gates Hall',
@CollectorName = 'Jimmy John''s'


/* Populate tblItem */
EXEC uspPopulateItem
@Name = 'Apple',
@Desc = 'Steve Jobs''s favorite fruit',
@Category = 'Food Waste'


/* Populate tblCollection_Item */
EXEC uspPopulateCollectionItem
@Item = 'Dead Crow',
@Weight = '59.000',
@Date = '2017-12-01',
@Location = 'Mary Gates Hall',
@Qty = '500'


/* Populate tblIncident */
EXEC uspPopulateIncident
@IncidentName = 'Collector staff back injury',
@IncidentDate = '2017-12-04',
@TypeName = 'Injuries',
@CollectionWeight = '32.000',
@CollectionDate = '2017-12-04',
@Location = 'Mary Gates Hall'


/*Populate tblSchedule_Day */
EXEC uspPopulateScheduleDay
@ScheduleName = 'Angel Junk's Schedule',
@DayName = 'Wednesday'
