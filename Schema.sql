Anirudh Subramanyam, Joseph Chou, Muatasim Qazi, Andreas Hindman
Schema


CREATE DATABASE WASTE_MANAGEMENT


USE WASTE_MANAGEMENT


CREATE TABLE tblCollection (
        CollectionID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        CollectionWeight int NOT NULL,
        CollectionDate date NOT NULL
);


CREATE TABLE tblCollection_Item (
        Collection_ItemID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        Quantity int NOT NULL
);


CREATE TABLE tblItem (
        ItemID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        ItemName varchar(50) NOT NULL,
        ItemDesc varchar(500) NULL
);


CREATE TABLE tblCategory (
        CategoryID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        CategoryName varchar(50) NOT NULL,
        CategoryDesc varchar(500) NULL
);


CREATE TABLE tblProcedure (
        ProcedureID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        ProcedureName varchar(50) NOT NULL,
        ProcedureDesc varchar(500) NULL
);


CREATE TABLE tblLocation (
        LocationID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        LocationName varchar(50) NOT NULL,
        LocationDesc varchar(500) NULL
);


CREATE TABLE tblLocation_Type (
        Location_TypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        Location_TypeName varchar(50) NOT NULL,
        Location_TypeDesc varchar(500) NULL
);


CREATE TABLE tblSchedule (
        ScheduleID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        ScheduleName varchar(50) NOT NULL,
        ScheduleDesc varchar(500) NULL
);


CREATE TABLE tblCollector (
        CollectorID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        CollectorName varchar(50) NOT NULL,
        CollectorDesc varchar(500) NULL
);


CREATE TABLE tblSchedule_Day (
        Schedule_DayID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
);


CREATE TABLE tblDay (
        DayID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        DayName varchar(50) NOT NULL,
        DayDesc varchar(500) NULL
);


CREATE TABLE tblIncident (
        IncidentID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        IncidentName varchar(50) NOT NULL,
        IncidentDate DATE NOT NULL,
        IncidentDesc varchar(500) NULL
);


CREATE TABLE tblIncident_Type (
        Incident_TypeID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
        Incident_TypeName varchar(50) NOT NULL,
        Incident_TypeDesc varchar(500) NULL
);


ALTER TABLE tblCollection
ADD LocationID INT FOREIGN KEY REFERENCES tblLocation(LocationID) NOT NULL,
CollectorID INT FOREIGN KEY REFERENCES tblCollector(CollectorID) NOT NULL


ALTER TABLE tblIncident
ADD CollectionID INT FOREIGN KEY REFERENCES tblCollection(CollectionID)


ALTER TABLE tblCollection_Item
ADD CollectionID INT FOREIGN KEY REFERENCES tblCollection(CollectionID) NOT NULL,
ItemID INT FOREIGN KEY REFERENCES tblItem(ItemID) NOT NULL


ALTER TABLE tblItem
ADD CategoryID INT FOREIGN KEY REFERENCES tblCategory(CategoryID) NOT NULL


ALTER TABLE tblCategory
ADD ProcedureID INT FOREIGN KEY REFERENCES tblProcedure(ProcedureID) NOT NULL


ALTER TABLE tblLocation
ADD Location_TypeID INT FOREIGN KEY REFERENCES tblLocation_Type(Location_TypeID) NOT NULL


ALTER TABLE tblCollector
ADD ScheduleID INT FOREIGN KEY REFERENCES tblSchedule(ScheduleID) NOT NULL


ALTER TABLE tblSchedule_Day
ADD ScheduleID INT FOREIGN KEY REFERENCES tblSchedule(ScheduleID) NOT NULL,
DayID INT FOREIGN KEY REFERENCES tblDay(DayID) NOT NULL


ALTER TABLE tblIncident
ADD Incident_TypeID INT FOREIGN KEY REFERENCES tblIncident_Type(Incident_TypeID)
