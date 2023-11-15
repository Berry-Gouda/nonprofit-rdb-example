USE [master]
GO
/****** Object:  Database [Champlain_Chartiy_LLC]    Script Date: 2/23/2023 9:13:35 PM ******/
CREATE DATABASE [Champlain_Chartiy_LLC]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Champlain_Chartiy_LLC', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Champlain_Chartiy_LLC.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Champlain_Chartiy_LLC_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Champlain_Chartiy_LLC_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Champlain_Chartiy_LLC].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET ARITHABORT OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET RECOVERY FULL 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET  MULTI_USER 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'Champlain_Chartiy_LLC', N'ON'
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET QUERY_STORE = OFF
GO
USE [Champlain_Chartiy_LLC]
GO
/****** Object:  Schema [Foodshelf]    Script Date: 2/23/2023 9:13:35 PM ******/
CREATE SCHEMA [Foodshelf]
GO
/****** Object:  Schema [Person]    Script Date: 2/23/2023 9:13:35 PM ******/
CREATE SCHEMA [Person]
GO
/****** Object:  Schema [Signature]    Script Date: 2/23/2023 9:13:35 PM ******/
CREATE SCHEMA [Signature]
GO
/****** Object:  Schema [SSN]    Script Date: 2/23/2023 9:13:35 PM ******/
CREATE SCHEMA [SSN]
GO
/****** Object:  Schema [Volunteer]    Script Date: 2/23/2023 9:13:35 PM ******/
CREATE SCHEMA [Volunteer]
GO
/****** Object:  UserDefinedDataType [dbo].[Name]    Script Date: 2/23/2023 9:13:35 PM ******/
CREATE TYPE [dbo].[Name] FROM [nvarchar](50) NULL
GO
/****** Object:  UserDefinedFunction [dbo].[CheckAddressValid]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[CheckAddressValid]   (@AddressLine1 VARCHAR(60), @AddressLine2 VARCHAR(60) = NULL, @City VARCHAR(30),
										@County VARCHAR(30), @State VARCHAR(2), @PostalCode VARCHAR(10), @Type INT)
RETURNS BIT
AS
BEGIN
	
	DECLARE @Rtn_Val BIT
	IF @AddressLine1 IS NULL OR @City IS NULL OR @County IS NULL OR @State IS NULL OR 
		NOT EXISTS(SELECT AddressTypeID FROM Person.LUAddressType WHERE @Type = AddressTypeID)
		SET @Rtn_Val = 0
	ELSE 
		SET @Rtn_Val = 1

	RETURN @Rtn_Val
END

GO
/****** Object:  UserDefinedFunction [Person].[FindCheckRelation]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Person].[FindCheckRelation] (@PersonID INT, @RelationID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Rtn_Val INT,
			@FamilyLastName VARCHAR(50)

	IF @RelationID = 1 AND @PersonID NOT IN(SELECT PersonID FROM Person.Household)
	BEGIN
		SELECT @FamilyLastName = LastName FROM Person.Person WHERE PersonID = @PersonID

		SELECT @Rtn_Val = H.HouseHoldID FROM Person.Household AS H
			INNER JOIN Person.Person AS P ON P.PersonID = H.PersonID WHERE @FamilyLastName = P.LastName AND H.HouseHoldRelationID = 1

		IF @Rtn_Val IS NULL
			SET @Rtn_Val = 0 --Sets the Rtn_Val to indicate that it should be a new Household
		ELSE
			SET @Rtn_Val = -3 --Sets to -3 indicating that There is already a head of household for that lastname.
	END

	--If the person is a parent, child, or sibling and does not exist in Household Table Gather the lastname to find the Household ID 
	ELSE IF @RelationID BETWEEN 2 AND 4 AND @PersonID NOT IN(SELECT PersonID FROM Person.Household)
	BEGIN
		SELECT @FamilyLastName = LastName FROM Person.Person WHERE PersonID = @PersonID
		SELECT @Rtn_Val = H.HouseHoldID FROM Person.Household AS H
			INNER JOIN Person.Person AS P ON P.PersonID = H.PersonID WHERE @FamilyLastName = P.LastName AND H.HouseHoldRelationID = 1
		
		--IF NULL No head of household exists, set to @Rtn_Val to -1 Indicating that more info is needed to determin HouseholdID
		IF @Rtn_Val IS NULL
		BEGIN
			SET @Rtn_Val = -1
		END
	END

	--if no @HouseholdID is provided set to -1 indicating more info needed.
	ELSE IF @RelationID = 5
	BEGIN
		SET @Rtn_Val = -1
	END

	--Else the @Relation ID does not exist and set @rtn_val to -2 to indicate this.
	ELSE
		SET @Rtn_Val = -2

	RETURN @Rtn_Val
END

GO
/****** Object:  UserDefinedFunction [Volunteer].[CheckIfWorking]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [Volunteer].[CheckIfWorking](@Shift VARCHAR(15), @Name VARCHAR(100), @StartDate DATE)
RETURNS BIT
AS
BEGIN
	
	DECLARE @rtnVal BIT
	SET @rtnVal = 1

	IF @Shift = 'SundayAM'
		IF EXISTS(SELECT SundayAM FROM Volunteer.Schedule WHERE @Name = SundayAM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'SundayPM'
		IF EXISTS(SELECT SundayPM FROM Volunteer.Schedule WHERE @Name = SundayPM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'MondayAM'
		IF EXISTS(SELECT MondayAM FROM Volunteer.Schedule WHERE @Name = MondayAM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'MondayPM'
		IF EXISTS(SELECT MondayPM FROM Volunteer.Schedule WHERE @Name = MondayPM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'TuesdayAM'
		IF EXISTS(SELECT TuesdayAM FROM Volunteer.Schedule WHERE @Name = TuesdayAM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'TuesdayPM'
		IF EXISTS(SELECT TuesdayPM FROM Volunteer.Schedule WHERE @Name = TuesdayPM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'WednesdayAM'
		IF EXISTS(SELECT WednesdayAM FROM Volunteer.Schedule WHERE @Name = WednesdayAM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'WednesdayPM'
		IF EXISTS(SELECT WednesdayPM FROM Volunteer.Schedule WHERE @Name = WednesdayPM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'ThursdayAM'
		IF EXISTS(SELECT ThursdayAM FROM Volunteer.Schedule WHERE @Name = ThursdayAM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'ThursdayPM'
		IF EXISTS(SELECT ThursdayPM FROM Volunteer.Schedule WHERE @Name = ThursdayPM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'FridayAM'
		IF EXISTS(SELECT FridayAM FROM Volunteer.Schedule WHERE @Name = FridayAM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'FridayPM'
		IF EXISTS(SELECT FridayPM FROM Volunteer.Schedule WHERE @Name = FridayPM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'SaturdayAM'
		IF EXISTS(SELECT SaturdayAM FROM Volunteer.Schedule WHERE @Name = SaturdayAM AND @StartDate = WeekStarting)
			SET @rtnVal = 0
	IF @Shift = 'SaturdayPM'
		IF EXISTS(SELECT SaturdayPM FROM Volunteer.Schedule WHERE @Name = SaturdayPM AND @StartDate = WeekStarting)
			SET @rtnVal = 0

	RETURN @rtnVal
END


GO
/****** Object:  UserDefinedFunction [Volunteer].[CountAvailability]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [Volunteer].[CountAvailability](@VolID INT)
RETURNS INT
AS
BEGIN
	DECLARE @rtnVal INT
	SET @rtnVal = 0

	IF 1 = (SELECT SundayAM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1
	IF 1 = (SELECT o.SundayPM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1

	IF 1 = (SELECT o.MondayAM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1
	IF 1 = (SELECT o.MondayPM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1

	IF 1 = (SELECT o.TuesdayAM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1
	IF 1 = (SELECT o.TuesdayPM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1
			
	IF 1 = (SELECT o.WednesdayAM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1
	IF 1 = (SELECT o.WednesdayPM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1

	IF 1 = (SELECT o.ThursdayAM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1
	IF 1 = (SELECT o.ThursdayPM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1

	IF 1 = (SELECT o.FridayAM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1
	IF 1 = (SELECT o.FridayPM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1

	IF 1 = (SELECT o.SaturdayAM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1
	IF 1 = (SELECT o.SaturdayPM FROM Volunteer.VolunteerAvailability as o WHERE @VolID = VolunteerID)
		SET @rtnVal = @rtnVal + 1


	RETURN @rtnVal
END

GO
/****** Object:  UserDefinedFunction [Volunteer].[GetFullName]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [Volunteer].[GetFullName](@VolID INT)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @FullName VARCHAR(100);

	WITH FullNames
	AS(
		SELECT V.VolunteerID, CONCAT(P.FirstName, ' ', P.LastName) AS FullName FROM Person.Person AS P
			INNER JOIN Volunteer.Volunteer AS V ON V.PersonID = P.PersonID WHERE @VolID = V.VolunteerID)
	
	SELECT @FullName = FullName FROM FullNames
	
	RETURN @FullName
END

GO
/****** Object:  UserDefinedFunction [Volunteer].[GetVolunteerIDFromRow]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [Volunteer].[GetVolunteerIDFromRow](@OrgID INT, @RowCount INT)
RETURNS INT
AS
BEGIN
	
	DECLARE @rtnVal INT;
	
	--Creates a table with the names of the people that work in that Job.
	WITH FullNamesWithShiftCount
	AS(
		SELECT V.VolunteerID, CONCAT(P.FirstName, ' ', P.LastName) AS FullName, Volunteer.CountAvailability(V.VolunteerID) AS ShiftsAvailable FROM Person.Person AS P
			INNER JOIN Volunteer.Volunteer AS V ON V.PersonID = P.PersonID
				INNER JOIN Volunteer.VolunteerJob AS VJ ON VJ.VolunteerID = V.VolunteerID WHERE VJ.JobDescriptionID = @OrgID),

	FullNamesRowCount
		AS(SELECT VolunteerID, FullName, ShiftsAvailable, ROW_NUMBER() OVER(ORDER BY ShiftsAvailable) AS RowNum FROM FullNamesWithShiftCount)


	SELECT @rtnVal = VolunteerID FROM FullNamesRowCount WHERE RowNum = @RowCount

	RETURN @rtnVal
	

END

GO
/****** Object:  Table [Person].[PersonType]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[PersonType](
	[PersonTypeID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[PersonType] [int] NOT NULL,
	[ModifiedDate] [date] NULL,
	[ModifiedBy] [varchar](3) NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Volunteer].[Volunteer]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Volunteer].[Volunteer](
	[VolunteerID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_VolunteerID] PRIMARY KEY CLUSTERED 
(
	[VolunteerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[Person]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[Person](
	[PersonID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [dbo].[Name] NOT NULL,
	[MiddleName] [dbo].[Name] NULL,
	[LastName] [dbo].[Name] NOT NULL,
	[Suffix] [nvarchar](10) NULL,
	[DateOfBirth] [date] NOT NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[EmailContactPreference] [bit] NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](3) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Person_PersonID] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [Person].[FindVolunteerTypeNotVolunteer]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--This function returns a table with the personid and the email address of people who are marked as a volunteer
-- but have not been added to the volunteer section.

CREATE FUNCTION [Person].[FindVolunteerTypeNotVolunteer]
()
RETURNS TABLE
AS
RETURN
	SELECT P.PersonID, EmailAddress FROM Person.Person AS P
		Join Person.PersonType AS PT ON P.PersonID = PT.PersonID
				WHERE PersonType = 2 AND P.PersonID NOT IN(Select PersonID FROM Volunteer.Volunteer)

GO
/****** Object:  Table [dbo].[Organization]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Organization](
	[OrganizationID] [int] IDENTITY(1,1) NOT NULL,
	[OrganizationName] [nvarchar](50) NOT NULL,
	[Phone] [nchar](10) NULL,
	[Address] [nvarchar](50) NULL,
	[Note] [nvarchar](max) NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED 
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrganizationHours]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrganizationHours](
	[OrganizationID] [int] NOT NULL,
	[SundayAM] [bit] NOT NULL,
	[SundayPM] [bit] NOT NULL,
	[MondayAM] [bit] NOT NULL,
	[MondayPM] [bit] NOT NULL,
	[TuesdayAM] [bit] NOT NULL,
	[TuesdayPM] [bit] NOT NULL,
	[WednesdayAM] [bit] NOT NULL,
	[WednesdayPM] [bit] NOT NULL,
	[ThursdayAM] [bit] NOT NULL,
	[ThursdayPM] [bit] NOT NULL,
	[FridayAM] [bit] NOT NULL,
	[FridayPM] [bit] NOT NULL,
	[SaturdayAM] [bit] NOT NULL,
	[SaturdayPM] [bit] NOT NULL,
	[ModifiedDate] [date] NOT NULL,
	[ModifiedBy] [varchar](3) NOT NULL,
 CONSTRAINT [PK_OrgID] PRIMARY KEY CLUSTERED 
(
	[OrganizationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Foodshelf].[FoodDisbursements]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Foodshelf].[FoodDisbursements](
	[PersonID] [int] NOT NULL,
	[FoodshelfClientID] [int] NOT NULL,
	[FoodDisbursementID] [int] IDENTITY(1,1) NOT NULL,
	[FoodTypeID] [int] NOT NULL,
	[ReceivedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](3) NOT NULL,
 CONSTRAINT [PK_FoodTypeGiven] PRIMARY KEY CLUSTERED 
(
	[FoodDisbursementID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Foodshelf].[FoodshelfCertification]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Foodshelf].[FoodshelfCertification](
	[PersonID] [int] NOT NULL,
	[FoodshelfClientID] [int] NOT NULL,
	[FoodshelfCertificationID] [int] IDENTITY(1,1) NOT NULL,
	[CertificationTextID] [int] NOT NULL,
	[LastCertificationDate] [datetime] NOT NULL,
	[IsPaperCertification] [bit] NULL,
	[PaperCertificationDate] [datetime] NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_FoodShelfCertification_1] PRIMARY KEY CLUSTERED 
(
	[FoodshelfCertificationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Foodshelf].[FoodshelfClient]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Foodshelf].[FoodshelfClient](
	[PersonID] [int] NOT NULL,
	[FoodshelfClientID] [int] IDENTITY(1,1) NOT NULL,
	[HomeBoundDelivery] [bit] NOT NULL,
	[ModifiedDate] [date] NOT NULL,
	[ModifiedBy] [varchar](3) NOT NULL,
 CONSTRAINT [PK_FoodshelfPersonID] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[FoodshelfClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Foodshelf].[HouseholdNotes]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Foodshelf].[HouseholdNotes](
	[HouseholdNotesID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[FoodshelfClientID] [int] NOT NULL,
	[HouseHoldID] [int] NOT NULL,
	[Notes] [nvarchar](max) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_FoodShelfHouseNotes] PRIMARY KEY CLUSTERED 
(
	[HouseholdNotesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Foodshelf].[LUCertificationText]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Foodshelf].[LUCertificationText](
	[CertificationTextID] [int] IDENTITY(1,1) NOT NULL,
	[CertificationText] [nvarchar](max) NOT NULL,
	[GuidelinesText] [nvarchar](max) NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_CertificationTextID] PRIMARY KEY CLUSTERED 
(
	[CertificationTextID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Foodshelf].[LUFoodType]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Foodshelf].[LUFoodType](
	[FoodTypeID] [int] IDENTITY(1,1) NOT NULL,
	[FoodTypeDescription] [varchar](50) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](3) NOT NULL,
 CONSTRAINT [PK_FoodTypeID] PRIMARY KEY CLUSTERED 
(
	[FoodTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[Address]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[Address](
	[AddressID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[AddressLine1] [nvarchar](60) NOT NULL,
	[AddressLine2] [nvarchar](60) NULL,
	[City] [nvarchar](30) NOT NULL,
	[County] [nvarchar](30) NULL,
	[State] [nvarchar](2) NOT NULL,
	[PostalCode] [nvarchar](10) NULL,
	[AddressTypeID] [int] NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_AddressID] PRIMARY KEY CLUSTERED 
(
	[AddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[Demographics]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[Demographics](
	[DemographicsID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[EducationCategoryID] [int] NOT NULL,
	[HousingStatusID] [int] NOT NULL,
	[IncomeSourceID] [int] NOT NULL,
	[GenderID] [int] NOT NULL,
	[RaceID] [int] NOT NULL,
	[CountryOfOriginID] [int] NOT NULL,
	[EthnicityID] [int] NOT NULL,
	[Disability] [bit] NOT NULL,
	[CSFP] [bit] NOT NULL,
	[Veteran] [bit] NOT NULL,
	[InsuranceTypeID] [int] NULL,
	[FoodStamps] [bit] NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK__Deomographics] PRIMARY KEY CLUSTERED 
(
	[DemographicsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[Household]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[Household](
	[PersonID] [int] NOT NULL,
	[HouseHoldID] [int] NOT NULL,
	[HouseHoldRelationID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_PersonHouseHoldID] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[HouseHoldID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LanguagesSpoken]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LanguagesSpoken](
	[LanguagesSpokenID] [int] IDENTITY(1,1) NOT NULL,
	[LanguageID] [int] NOT NULL,
	[PersonID] [int] NOT NULL,
	[IsPrimaryLanguage] [bit] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_LanguagesSpokenID] PRIMARY KEY CLUSTERED 
(
	[LanguagesSpokenID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUAddressType]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUAddressType](
	[AddressTypeID] [int] IDENTITY(1,1) NOT NULL,
	[AddressType] [nvarchar](10) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_AddressType_AddressTypeID] PRIMARY KEY CLUSTERED 
(
	[AddressTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUCountryOfOrigin]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUCountryOfOrigin](
	[CountryID] [int] IDENTITY(1,1) NOT NULL,
	[CountryAbbreviation] [nvarchar](50) NULL,
	[CountryName] [nvarchar](70) NOT NULL,
	[FIPSCode] [nvarchar](2) NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_LUCountryOfOrigin] PRIMARY KEY CLUSTERED 
(
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUEducationCategory]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUEducationCategory](
	[EducationCategoryID] [int] IDENTITY(1,1) NOT NULL,
	[EducationLevel] [nvarchar](50) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_LUEducationCategory] PRIMARY KEY CLUSTERED 
(
	[EducationCategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUEthnicity]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUEthnicity](
	[EthnicityID] [int] IDENTITY(1,1) NOT NULL,
	[EthnicityDescription] [nvarchar](50) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_LUEthnicity] PRIMARY KEY CLUSTERED 
(
	[EthnicityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUGender]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUGender](
	[GenderID] [int] IDENTITY(1,1) NOT NULL,
	[GenderDescription] [varchar](85) NOT NULL,
	[DateModified] [date] NOT NULL,
	[ModifiedBy] [varchar](3) NULL,
PRIMARY KEY CLUSTERED 
(
	[GenderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUHouseHoldRelation]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUHouseHoldRelation](
	[HouseholdRelationID] [int] IDENTITY(1,1) NOT NULL,
	[RelationshipDescription] [nvarchar](50) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_HouseholdRelationID] PRIMARY KEY CLUSTERED 
(
	[HouseholdRelationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUHousingStatus]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUHousingStatus](
	[HousingStatusID] [int] IDENTITY(1,1) NOT NULL,
	[HousingStatus] [nvarchar](50) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_LUHousingStatus] PRIMARY KEY CLUSTERED 
(
	[HousingStatusID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUIncomeSource]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUIncomeSource](
	[IncomeSourceID] [int] IDENTITY(1,1) NOT NULL,
	[IncomeSourceDescription] [nvarchar](50) NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_LUIncomeSource] PRIMARY KEY CLUSTERED 
(
	[IncomeSourceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUInsuranceType]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUInsuranceType](
	[InsuranceTypeID] [int] IDENTITY(1,1) NOT NULL,
	[InsuranceType] [nvarchar](50) NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LUInsuranceType] PRIMARY KEY CLUSTERED 
(
	[InsuranceTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LULanguage]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LULanguage](
	[LanguageID] [int] IDENTITY(1,1) NOT NULL,
	[LanguageName] [nvarchar](50) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[LanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUPersonType]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUPersonType](
	[PersonTypeID] [int] IDENTITY(1,1) NOT NULL,
	[PersonType] [nvarchar](20) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_LUPersonType] PRIMARY KEY CLUSTERED 
(
	[PersonTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUPhoneType]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUPhoneType](
	[PhoneTypeID] [int] IDENTITY(1,1) NOT NULL,
	[PhoneType] [nvarchar](50) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_PhoneTypeID] PRIMARY KEY CLUSTERED 
(
	[PhoneTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LUProgramType]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LUProgramType](
	[ProgramTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ProgramName] [nvarchar](20) NOT NULL,
	[ProgramDescription] [nvarchar](50) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_ProgramTypeID] PRIMARY KEY CLUSTERED 
(
	[ProgramTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[LURace]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[LURace](
	[RaceID] [int] IDENTITY(1,1) NOT NULL,
	[RaceDescription] [nvarchar](50) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_LURace] PRIMARY KEY CLUSTERED 
(
	[RaceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[Phone]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[Phone](
	[PhoneID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[PhoneNumber] [varchar](10) NOT NULL,
	[PhoneExtension] [nvarchar](8) NULL,
	[PhoneType] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_Phone] PRIMARY KEY CLUSTERED 
(
	[PhoneID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Person].[ProgramServicesUsed]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Person].[ProgramServicesUsed](
	[ServiceID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[ProgramServiceID] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_ProgramServicesUsed] PRIMARY KEY CLUSTERED 
(
	[ServiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Signature].[Signature]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Signature].[Signature](
	[SignatureID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[Signature] [varchar](max) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_Signature] PRIMARY KEY CLUSTERED 
(
	[SignatureID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Volunteer].[Address]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Volunteer].[Address](
	[AddressID] [int] IDENTITY(1,1) NOT NULL,
	[VolunteerID] [int] NOT NULL,
	[AddressLine1] [nvarchar](60) NOT NULL,
	[AddressLine2] [nvarchar](60) NULL,
	[City] [nvarchar](30) NOT NULL,
	[County] [nvarchar](30) NULL,
	[State] [nvarchar](2) NOT NULL,
	[PostalCode] [nvarchar](10) NULL,
	[AddressTypeID] [int] NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_AddressID] PRIMARY KEY CLUSTERED 
(
	[AddressID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Volunteer].[CountTable]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Volunteer].[CountTable](
	[VolunteerID] [int] NULL,
	[ShiftCount] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Volunteer].[DateRequest]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Volunteer].[DateRequest](
	[RequestID] [int] IDENTITY(1,1) NOT NULL,
	[VolunteerID] [int] NOT NULL,
	[RequestedDate] [date] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Volunteer].[LUVolunteerJobDescription]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Volunteer].[LUVolunteerJobDescription](
	[VolunteerJobsID] [int] IDENTITY(1,1) NOT NULL,
	[OrganizationID] [int] NOT NULL,
	[JobDescription] [nvarchar](50) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_JobID] PRIMARY KEY CLUSTERED 
(
	[VolunteerJobsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Volunteer].[Phone]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Volunteer].[Phone](
	[PhoneID] [int] IDENTITY(1,1) NOT NULL,
	[VolunteerID] [int] NOT NULL,
	[PhoneNumber] [nvarchar](11) NOT NULL,
	[PhoneTypeID] [int] NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_VOL_PhoneID] PRIMARY KEY CLUSTERED 
(
	[PhoneID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Volunteer].[Schedule]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Volunteer].[Schedule](
	[ScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[OrganizationID] [int] NOT NULL,
	[WeekStarting] [date] NOT NULL,
	[WeekEnding] [date] NOT NULL,
	[SundayAM] [varchar](100) NULL,
	[SundayPM] [varchar](100) NULL,
	[MondayAM] [varchar](100) NULL,
	[MondayPM] [varchar](100) NULL,
	[TuesdayAM] [varchar](100) NULL,
	[TuesdayPM] [varchar](100) NULL,
	[WednesdayAM] [varchar](100) NULL,
	[WednesdayPM] [varchar](100) NULL,
	[ThursdayAM] [varchar](100) NULL,
	[ThursdayPM] [varchar](100) NULL,
	[FridayAM] [varchar](100) NULL,
	[FridayPM] [varchar](100) NULL,
	[SaturdayAM] [varchar](100) NULL,
	[SaturdayPM] [varchar](100) NULL,
	[ModifiedDate] [date] NOT NULL,
	[ModifiedBy] [varchar](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Volunteer].[VolunteerAvailability]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Volunteer].[VolunteerAvailability](
	[VolunteerID] [int] NOT NULL,
	[SundayAM] [bit] NOT NULL,
	[SundayPM] [bit] NOT NULL,
	[MondayAM] [bit] NOT NULL,
	[MondayPM] [bit] NOT NULL,
	[TuesdayAM] [bit] NOT NULL,
	[TuesdayPM] [bit] NOT NULL,
	[WednesdayAM] [bit] NOT NULL,
	[WednesdayPM] [bit] NOT NULL,
	[ThursdayAM] [bit] NOT NULL,
	[ThursdayPM] [bit] NOT NULL,
	[FridayAM] [bit] NOT NULL,
	[FridayPM] [bit] NOT NULL,
	[SaturdayAM] [bit] NOT NULL,
	[SaturdayPM] [bit] NOT NULL,
	[ModifiedDate] [date] NOT NULL,
	[ModifiedBy] [varchar](3) NOT NULL,
 CONSTRAINT [PK_VolID] PRIMARY KEY CLUSTERED 
(
	[VolunteerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Volunteer].[VolunteerEmergencyContact]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Volunteer].[VolunteerEmergencyContact](
	[VolunteerEmergencyContactID] [int] IDENTITY(1,1) NOT NULL,
	[VolunteerID] [int] NOT NULL,
	[ContactFirstName] [varchar](40) NOT NULL,
	[ContactLastName] [varchar](50) NOT NULL,
	[ContactRelationID] [int] NOT NULL,
	[ContactPhoneNumber] [nvarchar](max) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_EmergencyContactID] PRIMARY KEY CLUSTERED 
(
	[VolunteerEmergencyContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Volunteer].[VolunteerJob]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Volunteer].[VolunteerJob](
	[JobID] [int] IDENTITY(1,1) NOT NULL,
	[VolunteerID] [int] NOT NULL,
	[JobDescriptionID] [int] NOT NULL,
	[ModifiedDate] [date] NOT NULL,
	[ModifiedBy] [varchar](3) NOT NULL,
 CONSTRAINT [PK_Vol_JobID] PRIMARY KEY CLUSTERED 
(
	[JobID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Volunteer].[VolunteerNotes]    Script Date: 2/23/2023 9:13:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Volunteer].[VolunteerNotes](
	[VolunteerNotesID] [int] IDENTITY(1,1) NOT NULL,
	[VolunteerID] [int] NOT NULL,
	[Note] [varchar](max) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[ModifiedBy] [dbo].[Name] NOT NULL,
 CONSTRAINT [PK_Vol_NotesID] PRIMARY KEY CLUSTERED 
(
	[VolunteerNotesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Organization] ON 

INSERT [dbo].[Organization] ([OrganizationID], [OrganizationName], [Phone], [Address], [Note], [ModifiedDate], [ModifiedBy]) VALUES (1, N'Food Shelf', N'5555551234', N'123 Hungry Ln, Burlington VT, 01010', N'This is where you can get some tasty food.', CAST(N'2023-02-03T14:13:13.330' AS DateTime), N'RMS')
INSERT [dbo].[Organization] ([OrganizationID], [OrganizationName], [Phone], [Address], [Note], [ModifiedDate], [ModifiedBy]) VALUES (2, N'Administration', N'1234567890', N'Bangladash', N'We got outsourced because of poor fund raising', CAST(N'2023-02-03T14:13:13.333' AS DateTime), N'RMS')
INSERT [dbo].[Organization] ([OrganizationID], [OrganizationName], [Phone], [Address], [Note], [ModifiedDate], [ModifiedBy]) VALUES (3, N'Housing', N'0987654321', N'321 Pine St, Burlingtion VT, 01010', N'Jim is amazing he can find anyone a roof to put over head', CAST(N'2023-02-03T14:13:13.333' AS DateTime), N'RMS')
INSERT [dbo].[Organization] ([OrganizationID], [OrganizationName], [Phone], [Address], [Note], [ModifiedDate], [ModifiedBy]) VALUES (4, N'Outreach', N'4567891230', N'123 Hungry Ln Suit#145, 01010', N'', CAST(N'2023-02-03T14:13:13.333' AS DateTime), N'RMS')
INSERT [dbo].[Organization] ([OrganizationID], [OrganizationName], [Phone], [Address], [Note], [ModifiedDate], [ModifiedBy]) VALUES (5, N'Fund Raising', N'9999999999', N'$$$ Money Blvd, Boston MA 02472', N'We have fat stacks', CAST(N'2023-02-03T14:13:13.333' AS DateTime), N'RMS')
SET IDENTITY_INSERT [dbo].[Organization] OFF
GO
INSERT [dbo].[OrganizationHours] ([OrganizationID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, CAST(N'2023-02-10' AS Date), N'RMS')
INSERT [dbo].[OrganizationHours] ([OrganizationID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, CAST(N'2023-02-10' AS Date), N'RMS')
INSERT [dbo].[OrganizationHours] ([OrganizationID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (3, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, CAST(N'2023-02-10' AS Date), N'RMS')
INSERT [dbo].[OrganizationHours] ([OrganizationID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (4, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, CAST(N'2023-02-10' AS Date), N'RMS')
INSERT [dbo].[OrganizationHours] ([OrganizationID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (5, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, CAST(N'2023-02-10' AS Date), N'RMS')
GO
SET IDENTITY_INSERT [Foodshelf].[LUFoodType] ON 

INSERT [Foodshelf].[LUFoodType] ([FoodTypeID], [FoodTypeDescription], [ModifiedDate], [ModifiedBy]) VALUES (1, N'Frozen Meat', CAST(N'2023-02-03T14:14:38.167' AS DateTime), N'RMS')
INSERT [Foodshelf].[LUFoodType] ([FoodTypeID], [FoodTypeDescription], [ModifiedDate], [ModifiedBy]) VALUES (2, N'Fresh Meat', CAST(N'2023-02-03T14:14:38.167' AS DateTime), N'RMS')
INSERT [Foodshelf].[LUFoodType] ([FoodTypeID], [FoodTypeDescription], [ModifiedDate], [ModifiedBy]) VALUES (3, N'Frozen Vegetables', CAST(N'2023-02-03T14:14:38.167' AS DateTime), N'RMS')
INSERT [Foodshelf].[LUFoodType] ([FoodTypeID], [FoodTypeDescription], [ModifiedDate], [ModifiedBy]) VALUES (4, N'Fresh Vegetables', CAST(N'2023-02-03T14:14:38.167' AS DateTime), N'RMS')
INSERT [Foodshelf].[LUFoodType] ([FoodTypeID], [FoodTypeDescription], [ModifiedDate], [ModifiedBy]) VALUES (5, N'Dry Goods', CAST(N'2023-02-03T14:14:38.167' AS DateTime), N'RMS')
INSERT [Foodshelf].[LUFoodType] ([FoodTypeID], [FoodTypeDescription], [ModifiedDate], [ModifiedBy]) VALUES (6, N'Staples', CAST(N'2023-02-03T14:14:38.167' AS DateTime), N'RMS')
INSERT [Foodshelf].[LUFoodType] ([FoodTypeID], [FoodTypeDescription], [ModifiedDate], [ModifiedBy]) VALUES (7, N'Special Occasion Treat', CAST(N'2023-02-03T14:14:38.167' AS DateTime), N'RMS')
INSERT [Foodshelf].[LUFoodType] ([FoodTypeID], [FoodTypeDescription], [ModifiedDate], [ModifiedBy]) VALUES (8, N'Holiday Meal', CAST(N'2023-02-03T14:14:38.167' AS DateTime), N'RMS')
SET IDENTITY_INSERT [Foodshelf].[LUFoodType] OFF
GO
INSERT [Person].[Household] ([PersonID], [HouseHoldID], [HouseHoldRelationID], [ModifiedDate], [ModifiedBy]) VALUES (372, 472, 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
GO
SET IDENTITY_INSERT [Person].[LUAddressType] ON 

INSERT [Person].[LUAddressType] ([AddressTypeID], [AddressType], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (1, N'Home', CAST(N'2023-02-03T14:14:33.633' AS DateTime), N'RMS', 0)
INSERT [Person].[LUAddressType] ([AddressTypeID], [AddressType], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (2, N'Mailing', CAST(N'2023-02-03T14:14:33.633' AS DateTime), N'RMS', 0)
INSERT [Person].[LUAddressType] ([AddressTypeID], [AddressType], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (3, N'Work', CAST(N'2023-02-03T14:14:33.633' AS DateTime), N'RMS', 0)
INSERT [Person].[LUAddressType] ([AddressTypeID], [AddressType], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (4, N'Secondary', CAST(N'2023-02-03T14:14:33.633' AS DateTime), N'RMS', 0)
INSERT [Person].[LUAddressType] ([AddressTypeID], [AddressType], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (5, N'Temporary', CAST(N'2023-02-03T14:14:33.633' AS DateTime), N'RMS', 0)
SET IDENTITY_INSERT [Person].[LUAddressType] OFF
GO
SET IDENTITY_INSERT [Person].[LUCountryOfOrigin] ON 

INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (1, N'Afghanistan', N'Islamic Republic of Afghanistan', N'AF', CAST(N'2010-10-04T21:42:34.143' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (2, N'Albania', N'Republic of Albania', N'AL', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (3, N'Algeria', N'Peoples Democratic Republic of Algeria', N'AG', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (4, N'Andorra', N'Principality of Andorra', N'AN', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (5, N'Angola ', N'Republic of Angola', N'AO', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (6, N'Antigua and Barbuda', N'Antigua and Barbuda', N'AC', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (7, N'Argentina ', N'Argentine Republic', N'AR', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (8, N'Armenia', N'Republic of Armenia', N'AM', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (9, N'Australia', N'Commonwealth of Australia', N'AS', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (10, N'Austria', N'Republic of Austria', N'AU', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (11, N'Azerbaijan', N'Republic of Azerbaijan', N'AJ', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (12, N'Bahamas', N'Commonwealth of the Bahamas', N'BF', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (13, N'Bahrain', N'Kingdom of Bahrain', N'BA', CAST(N'2010-10-04T21:42:34.147' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (14, N'Bangladesh', N'Peoples Republic of Bangladesh', N'BG', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (15, N'Barbados', N'Barbados', N'BB', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (16, N'Belarus', N'Republic of Belarus', N'BO', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (17, N'Belgium', N'Kingdom of Belgium', N'BE', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (18, N'Belize', N'Belize', N'BH', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (19, N'Benin', N'Republic of Benin', N'BN', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (20, N'Bhutan', N'Kingdom of Bhutan', N'BT', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (21, N'Bolivia', N'Plurinational State of Bolivia', N'BL', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (22, N'Bosnia and Herzegovina', N'Bosnia and Herzegovina', N'BK', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (23, N'Botswana', N'Republic of Botswana', N'BC', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (24, N'Brazil', N'Federative Republic of Brazil', N'BR', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (25, N'Brunei', N'Brunei Darussalam', N'BX', CAST(N'2010-10-04T21:42:34.150' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (26, N'Bulgaria', N'Republic of Bulgaria', N'BU', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (27, N'Burkina Faso', N'Burkina Faso', N'UV', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (28, N'Burma', N'Union of Burma', N'BM', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (29, N'Burundi', N'Republic of Burundi', N'BY', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (30, N'Cambodia', N'Kingdom of Cambodia', N'CB', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (31, N'Cameroon', N'Republic of Cameroon', N'CM', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (32, N'Canada', N'Canada', N'CA', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (33, N'Cape Verde', N'Republic of Cape Verde', N'CV', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (34, N'Central African Republic', N'Central African Republic', N'CT', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (35, N'Chad', N'Republic of Chad', N'CD', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (36, N'Chile', N'Republic of Chile', N'CI', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (37, N'China', N'Peoples Republic of China', N'CH', CAST(N'2010-10-04T21:42:34.153' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (38, N'Colombia', N'Republic of Colombia', N'CO', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (39, N'Comoros', N'Union of the Comoros', N'CN', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (40, N'Congo (Brazzaville)', N'Republic of the Congo', N'CF', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (41, N'Congo (Kinshasa)', N'Democratic Republic of the Congo', N'CF', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (42, N'Costa Rica', N'Republic of Costa Rica', N'CS', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (43, N'Cote dIvoire', N'Republic of Cote dIvoire', N'IV', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (44, N'Croatia', N'Republic of Croatia', N'HR', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (45, N'Cuba', N'Republic of Cuba', N'CU', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (46, N'Cyprus', N'Republic of Cyprus', N'CY', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (47, N'Czech Republic', N'Czech Republic', N'EZ', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (48, N'Denmark', N'Kingdom of Denmark', N'DA', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (49, N'Djibouti', N'Republic of Djibouti', N'DJ', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (50, N'Dominica', N'Commonwealth of Dominica', N'DO', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (51, N'Dominican Republic', N'Dominican Republic', N'DR', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (52, N'Ecuador', N'Republic of Ecuador', N'EC', CAST(N'2010-10-04T21:42:34.157' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (53, N'Egypt', N'Arab Republic of Egypt', N'EG', CAST(N'2010-10-04T21:42:34.160' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (54, N'El Salvador', N'Republic of El Salvador', N'ES', CAST(N'2010-10-04T21:42:34.160' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (55, N'Equatorial Guinea', N'Republic of Equatorial Guinea', N'EK', CAST(N'2010-10-04T21:42:34.160' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (56, N'Eritrea', N'State of Eritrea', N'ER', CAST(N'2010-10-04T21:42:34.160' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (57, N'Estonia', N'Republic of Estonia', N'EN', CAST(N'2010-10-04T21:42:34.160' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (58, N'Ethiopia', N'Federal Democratic Republic of Ethiopia', N'ET', CAST(N'2010-10-04T21:42:34.160' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (59, N'Fiji', N'Republic of the Fiji Islands', N'FJ', CAST(N'2010-10-04T21:42:34.160' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (60, N'Finland', N'Republic of Finland', N'FI', CAST(N'2010-10-04T21:42:34.160' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (61, N'France', N'French Republic', N'FR', CAST(N'2010-10-04T21:42:34.160' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (62, N'Gabon', N'Gabonese Republic', N'GB', CAST(N'2010-10-04T21:42:34.160' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (63, N'Gambia', N'Republic of The Gambia', N'GA', CAST(N'2010-10-04T21:42:34.160' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (64, N'Georgia', N'Georgia', N'GG', CAST(N'2010-10-04T21:42:34.163' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (65, N'Germany', N'Federal Republic of Germany', N'GM', CAST(N'2010-10-04T21:42:34.163' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (66, N'Ghana', N'Republic of Ghana', N'GH', CAST(N'2010-10-04T21:42:34.163' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (67, N'Greece', N'Hellenic Republic', N'GR', CAST(N'2010-10-04T21:42:34.163' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (68, N'Grenada', N'Grenada', N'GJ', CAST(N'2010-10-04T21:42:34.163' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (69, N'Guatemala', N'Republic of Guatemala', N'GT', CAST(N'2010-10-04T21:42:34.163' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (70, N'Guinea', N'Republic of Guinea', N'GV', CAST(N'2010-10-04T21:42:34.163' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (71, N'Guinea-Bissau ', N'Republic of Guinea-Bissau', N'PU', CAST(N'2010-10-04T21:42:34.163' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (72, N'Guyana', N'Co-operative Republic of Guyana', N'GY', CAST(N'2010-10-04T21:42:34.163' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (73, N'Haiti', N'Republic of Haiti', N'HA', CAST(N'2010-10-04T21:42:34.163' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (74, N'Holy See', N'Holy See', N'VT', CAST(N'2010-10-04T21:42:34.163' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (75, N'Honduras', N'Republic of Honduras', N'HO', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (76, N'Hungary', N'Republic of Hungary', N'HU', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (77, N'Iceland', N'Republic of Iceland', N'IC', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (78, N'India', N'Republic of India', N'IN', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (79, N'Indonesia', N'Republic of Indonesia', N'ID', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (80, N'Iran', N'Islamic Republic of Iran', N'IR', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (81, N'Iraq', N'Republic of Iraq', N'IZ', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (82, N'Ireland', N'Ireland', N'EI', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (83, N'Israel', N'State of Israel', N'IS', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (84, N'Italy', N'Italian Republic', N'IT', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (85, N'Jamaica', N'Jamaica', N'JM', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (86, N'Japan', N'Japan', N'JA', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (87, N'Jordan', N'Hashemite Kingdom of Jordan', N'JO', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (88, N'Kazakhstan', N'Republic of Kazakhstan', N'KZ', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (89, N'Kenya', N'Republic of Kenya', N'KE', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (90, N'Kiribati', N'Republic of Kiribati', N'KR', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (91, N'North Korea', N'Democratic Peoples Republic of Korea', N'KN', CAST(N'2010-10-04T21:42:34.167' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (92, N'South Korea', N'Republic of Korea', N'KS', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (93, N'Kosovo', N'Republic of Kosovo', N'KV', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (94, N'Kuwait', N'State of Kuwait', N'KU', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (95, N'Kyrgyzstan', N'Kyrgyz Republic', N'KG', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (96, N'Laos', N'Lao Peoples Democratic Republic', N'LA', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (97, N'Latvia', N'Republic of Latvia', N'LG', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (98, N'Lebanon', N'Lebanese Republic', N'LE', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (99, N'Lesotho', N'Kingdom of Lesotho', N'LT', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
GO
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (100, N'Liberia', N'Republic of Liberia', N'LI', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (101, N'Libya', N'Great Socialist Peoples', N'', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (102, N'Libyan Arab Jamahiriya', N'LY', N'', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (103, N'Liechtenstein', N'Principality of Liechtenstein', N'LS', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (104, N'Lithuania', N'Republic of Lithuania', N'LH', CAST(N'2010-10-04T21:42:34.170' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (105, N'Luxembourg', N'Grand Duchy of Luxembourg', N'LU', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (106, N'Macedonia', N'Republic of Macedonia', N'MK', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (107, N'Madagascar', N'Republic of Madagascar', N'MA', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (108, N'Malawi', N'Republic of Malawi', N'MI', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (109, N'Malaysia', N'Malaysia', N'MY', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (110, N'Maldives', N'Republic of Maldives', N'MV', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (111, N'Mali', N'Republic of Mali', N'ML', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (112, N'Malta', N'Republic of Malta', N'MT', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (113, N'Marshall Islands', N'Republic of the Marshall Islands', N'RM', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (114, N'Mauritania ', N'Islamic Republic of Mauritania', N'MR', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (115, N'Mauritius ', N'Republic of Mauritius', N'MP', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (116, N'Mexico ', N'United Mexican States', N'MX', CAST(N'2010-10-04T21:42:34.173' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (117, N'"Micronesia', N'Federated States of Micronesia', N'FM', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (118, N'Moldova', N'Republic of Moldova', N'MD', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (119, N'Monaco', N'Principality of Monaco', N'MN', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (120, N'Mongolia', N'Mongolia', N'MG', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (121, N'Montenegro', N'Montenegro', N'MJ', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (122, N'Morocco', N'Kingdom of Morocco', N'MO', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (123, N'Mozambique', N'Republic of Mozambique', N'MZ', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (124, N'Namibia', N'Republic of Namibia', N'WA', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (125, N'Nauru', N'Republic of Nauru', N'NR', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (126, N'Nepal', N'Federal Democratic Republic of Nepal', N'NP', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (127, N'Netherlands', N'Kingdom of the Netherlands', N'NL', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (128, N'New Zealand', N'New Zealand', N'NZ', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (129, N'Nicaragua', N'Republic of Nicaragua', N'NU', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (130, N'Niger', N'Republic of Niger', N'NG', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (131, N'Nigeria', N'Federal Republic of Nigeria', N'NI', CAST(N'2010-10-04T21:42:34.177' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (132, N'Norway', N'Kingdom of Norway', N'NO', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (133, N'Oman', N'Sultanate of Oman', N'MU', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (134, N'Pakistan', N'Islamic Republic of Pakistan', N'PK', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (135, N'Palau', N'Republic of Palau', N'PS', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (136, N'Panama', N'Republic of Panama', N'PM', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (137, N'Papua New Guinea', N'Independent State of Papua New Guinea', N'PP', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (138, N'Paraguay', N'Republic of Paraguay', N'PA', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (139, N'Peru', N'Republic of Peru', N'PE', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (140, N'Philippines', N'Republic of the Philippines', N'RP', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (141, N'Poland', N'Republic of Poland', N'PL', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (142, N'Portugal', N'Portuguese Republic', N'PO', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (143, N'Qatar', N'State of Qatar', N'QA', CAST(N'2010-10-04T21:42:34.180' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (144, N'Romania', N'Romania', N'RO', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (145, N'Russia', N'Russian Federation', N'RS', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (146, N'Rwanda', N'Republic of Rwanda', N'RW', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (147, N'Saint Kitts and Nevis ', N'Federation of Saint Kitts and Nevis', N'SC', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (148, N'Saint Lucia ', N'Saint Lucia ', N'ST', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (149, N'Saint Vincent and the Grenadines', N'Saint Vincent and the Grenadines', N'VC', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (150, N'Samoa', N'Independent State of Samoa', N'WS', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (151, N'San Marino', N'Republic of San Marino', N'SM', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (152, N'Sao Tome and Principe', N'Democratic Republic of Sao Tome and Principe', N'TP', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (153, N'Saudi Arabia', N'Kingdom of Saudi Arabia', N'SA', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (154, N'Senegal', N'Republic of Senegal', N'SG', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (155, N'Serbia', N'Republic of Serbia', N'RI', CAST(N'2010-10-04T21:42:34.183' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (156, N'Seychelles', N'Republic of Seychelles', N'SE', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (157, N'Sierra Leone', N'Republic of Sierra Leone', N'SL', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (158, N'Singapore', N'Republic of Singapore', N'SN', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (159, N'Slovakia', N'Slovak Republic', N'LO', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (160, N'Slovenia', N'Republic of Slovenia', N'SI', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (161, N'Solomon Islands', N'Solomon Islands', N'BP', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (162, N'Somalia', N'Somalia', N'SO', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (163, N'South Africa', N'Republic of South Africa', N'SF', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (164, N'Spain', N'Kingdom of Spain', N'SP', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (165, N'Sri Lanka', N'Democratic Socialist Republic of Sri Lanka', N'CE', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (166, N'Sudan', N'Republic of the Sudan', N'SU', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (167, N'Suriname', N'Republic of Suriname', N'NS', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (168, N'Swaziland', N'Kingdom of Swaziland', N'WZ', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (169, N'Sweden', N'Kingdom of Sweden', N'SW', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (170, N'Switzerland', N'Swiss Confederation', N'SZ', CAST(N'2010-10-04T21:42:34.187' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (171, N'Syria', N'Syrian Arab Republic', N'SY', CAST(N'2010-10-04T21:42:34.190' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (172, N'Tajikistan', N'Republic of Tajikistan', N'TI', CAST(N'2010-10-04T21:42:34.190' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (173, N'Tanzania', N'United Republic of Tanzania', N'TZ', CAST(N'2010-10-04T21:42:34.190' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (174, N'Thailand', N'Kingdom of Thailand', N'TH', CAST(N'2010-10-04T21:42:34.190' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (175, N'Timor-Leste', N'Democratic Republic of Timor-Leste', N'TT', CAST(N'2010-10-04T21:42:34.190' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (176, N'Togo', N'Togolese Republic', N'TO', CAST(N'2010-10-04T21:42:34.190' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (177, N'Tonga', N'Kingdom of Tonga', N'TN', CAST(N'2010-10-04T21:42:34.190' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (178, N'Trinidad and Tobago', N'Republic of Trinidad and Tobago', N'TD', CAST(N'2010-10-04T21:42:34.190' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (180, N'Tunisia', N'Tunisian Republic', N'TS', CAST(N'2010-10-04T21:42:34.190' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (181, N'Turkey', N'Republic of Turkey', N'TU', CAST(N'2010-10-04T21:42:34.190' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (182, N'Turkmenistan', N'Turkmenistan', N'TX', CAST(N'2010-10-04T21:42:34.190' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (183, N'Tuvalu', N'Tuvalu', N'TV', CAST(N'2010-10-04T21:42:34.193' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (184, N'Uganda', N'Republic of Uganda', N'UG', CAST(N'2010-10-04T21:42:34.193' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (185, N'Ukraine', N'Ukraine', N'UP', CAST(N'2010-10-04T21:42:34.193' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (186, N'United Arab Emirates', N'United Arab Emirates', N'AE', CAST(N'2010-10-04T21:42:34.193' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (187, N'United Kingdom', N'United Kingdom of Great Britain and Northern Ireland', N'UK', CAST(N'2010-10-04T21:42:34.193' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (188, N'United States', N'United States of America', N'US', CAST(N'2010-10-04T21:42:34.193' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (189, N'Uruguay', N'Oriental Republic of Uruguay', N'UY', CAST(N'2010-10-04T21:42:34.193' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (190, N'Uzbekistan', N'Republic of Uzbekistan', N'UZ', CAST(N'2010-10-04T21:42:34.193' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (191, N'Vanuatu', N'Republic of Vanuatu', N'NH', CAST(N'2010-10-04T21:42:34.193' AS DateTime), N'SSE', NULL)
INSERT [Person].[LUCountryOfOrigin] ([CountryID], [CountryAbbreviation], [CountryName], [FIPSCode], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (192, N'Venezuela', N'Bolivarian Republic of Venezuela', N'VE', CAST(N'2010-10-04T21:42:34.193' AS DateTime), N'SSE', NULL)
SET IDENTITY_INSERT [Person].[LUCountryOfOrigin] OFF
GO
SET IDENTITY_INSERT [Person].[LUEducationCategory] ON 

INSERT [Person].[LUEducationCategory] ([EducationCategoryID], [EducationLevel], [ModifiedDate], [ModifiedBy]) VALUES (1, N'Grade School', CAST(N'2023-02-03T14:16:37.690' AS DateTime), N'RMS')
INSERT [Person].[LUEducationCategory] ([EducationCategoryID], [EducationLevel], [ModifiedDate], [ModifiedBy]) VALUES (2, N'Some High School', CAST(N'2023-02-03T14:16:37.693' AS DateTime), N'RMS')
INSERT [Person].[LUEducationCategory] ([EducationCategoryID], [EducationLevel], [ModifiedDate], [ModifiedBy]) VALUES (3, N'High School Graduate or GED', CAST(N'2023-02-03T14:16:37.693' AS DateTime), N'RMS')
INSERT [Person].[LUEducationCategory] ([EducationCategoryID], [EducationLevel], [ModifiedDate], [ModifiedBy]) VALUES (4, N'Some College', CAST(N'2023-02-03T14:16:37.693' AS DateTime), N'RMS')
INSERT [Person].[LUEducationCategory] ([EducationCategoryID], [EducationLevel], [ModifiedDate], [ModifiedBy]) VALUES (5, N'Associates Degree', CAST(N'2023-02-03T14:16:37.693' AS DateTime), N'RMS')
INSERT [Person].[LUEducationCategory] ([EducationCategoryID], [EducationLevel], [ModifiedDate], [ModifiedBy]) VALUES (6, N'College Degree', CAST(N'2023-02-03T14:16:37.693' AS DateTime), N'RMS')
INSERT [Person].[LUEducationCategory] ([EducationCategoryID], [EducationLevel], [ModifiedDate], [ModifiedBy]) VALUES (7, N'Technical School', CAST(N'2023-02-03T14:16:37.693' AS DateTime), N'RMS')
INSERT [Person].[LUEducationCategory] ([EducationCategoryID], [EducationLevel], [ModifiedDate], [ModifiedBy]) VALUES (8, N'Training Certificate', CAST(N'2023-02-03T14:16:37.693' AS DateTime), N'RMS')
SET IDENTITY_INSERT [Person].[LUEducationCategory] OFF
GO
SET IDENTITY_INSERT [Person].[LUEthnicity] ON 

INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (1, N'African American', CAST(N'2023-02-03T14:14:34.650' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (2, N'American', CAST(N'2023-02-03T14:14:34.653' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (3, N'Hispanic/Latino', CAST(N'2023-02-03T14:14:34.653' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (4, N'Black', CAST(N'2023-02-03T14:14:34.653' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (5, N'Asian', CAST(N'2023-02-03T14:14:34.653' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (6, N'Native American', CAST(N'2023-02-03T14:14:34.653' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (7, N'Native Alaskan', CAST(N'2023-02-03T14:14:34.653' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (8, N'Pacific Islander', CAST(N'2023-02-03T14:14:34.653' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (9, N'Uyghurs', CAST(N'2023-02-03T14:14:34.653' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (10, N'Arab', CAST(N'2023-02-03T14:14:34.653' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (11, N'White', CAST(N'2023-02-03T14:14:34.653' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUEthnicity] ([EthnicityID], [EthnicityDescription], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (12, N'Ashkenazi', CAST(N'2023-02-03T14:14:34.653' AS DateTime), N'RMS', NULL)
SET IDENTITY_INSERT [Person].[LUEthnicity] OFF
GO
SET IDENTITY_INSERT [Person].[LUGender] ON 

INSERT [Person].[LUGender] ([GenderID], [GenderDescription], [DateModified], [ModifiedBy]) VALUES (1, N'Male', CAST(N'2023-02-03' AS Date), N'RMS')
INSERT [Person].[LUGender] ([GenderID], [GenderDescription], [DateModified], [ModifiedBy]) VALUES (2, N'Female', CAST(N'2023-02-03' AS Date), N'RMS')
INSERT [Person].[LUGender] ([GenderID], [GenderDescription], [DateModified], [ModifiedBy]) VALUES (3, N'Non Binary', CAST(N'2023-02-03' AS Date), N'RMS')
INSERT [Person].[LUGender] ([GenderID], [GenderDescription], [DateModified], [ModifiedBy]) VALUES (4, N'No Respons', CAST(N'2023-02-03' AS Date), N'RMS')
SET IDENTITY_INSERT [Person].[LUGender] OFF
GO
SET IDENTITY_INSERT [Person].[LUHouseHoldRelation] ON 

INSERT [Person].[LUHouseHoldRelation] ([HouseholdRelationID], [RelationshipDescription], [ModifiedDate], [ModifiedBy]) VALUES (1, N'Head of Household', CAST(N'2023-02-03T14:14:31.160' AS DateTime), N'RMS')
INSERT [Person].[LUHouseHoldRelation] ([HouseholdRelationID], [RelationshipDescription], [ModifiedDate], [ModifiedBy]) VALUES (2, N'Parent', CAST(N'2023-02-03T14:14:31.160' AS DateTime), N'RMS')
INSERT [Person].[LUHouseHoldRelation] ([HouseholdRelationID], [RelationshipDescription], [ModifiedDate], [ModifiedBy]) VALUES (3, N'Child', CAST(N'2023-02-03T14:14:31.160' AS DateTime), N'RMS')
INSERT [Person].[LUHouseHoldRelation] ([HouseholdRelationID], [RelationshipDescription], [ModifiedDate], [ModifiedBy]) VALUES (4, N'Sibling', CAST(N'2023-02-03T14:14:31.160' AS DateTime), N'RMS')
INSERT [Person].[LUHouseHoldRelation] ([HouseholdRelationID], [RelationshipDescription], [ModifiedDate], [ModifiedBy]) VALUES (5, N'Roommate', CAST(N'2023-02-03T14:14:31.160' AS DateTime), N'RMS')
SET IDENTITY_INSERT [Person].[LUHouseHoldRelation] OFF
GO
SET IDENTITY_INSERT [Person].[LUHousingStatus] ON 

INSERT [Person].[LUHousingStatus] ([HousingStatusID], [HousingStatus], [ModifiedDate], [ModifiedBy]) VALUES (1, N'Rent', CAST(N'2023-02-03T14:16:51.093' AS DateTime), N'RMS')
INSERT [Person].[LUHousingStatus] ([HousingStatusID], [HousingStatus], [ModifiedDate], [ModifiedBy]) VALUES (2, N'Own', CAST(N'2023-02-03T14:16:51.093' AS DateTime), N'RMS')
INSERT [Person].[LUHousingStatus] ([HousingStatusID], [HousingStatus], [ModifiedDate], [ModifiedBy]) VALUES (3, N'Homeless', CAST(N'2023-02-03T14:16:51.093' AS DateTime), N'RMS')
INSERT [Person].[LUHousingStatus] ([HousingStatusID], [HousingStatus], [ModifiedDate], [ModifiedBy]) VALUES (4, N'Homeless with Roof', CAST(N'2023-02-03T14:16:51.093' AS DateTime), N'RMS')
INSERT [Person].[LUHousingStatus] ([HousingStatusID], [HousingStatus], [ModifiedDate], [ModifiedBy]) VALUES (5, N'Boarder', CAST(N'2023-02-03T14:16:51.093' AS DateTime), N'RMS')
INSERT [Person].[LUHousingStatus] ([HousingStatusID], [HousingStatus], [ModifiedDate], [ModifiedBy]) VALUES (6, N'Other', CAST(N'2023-02-03T14:16:51.097' AS DateTime), N'RMS')
SET IDENTITY_INSERT [Person].[LUHousingStatus] OFF
GO
SET IDENTITY_INSERT [Person].[LUIncomeSource] ON 

INSERT [Person].[LUIncomeSource] ([IncomeSourceID], [IncomeSourceDescription], [ModifiedDate], [ModifiedBy]) VALUES (1, N'Unemployed', CAST(N'2023-02-03T14:14:29.800' AS DateTime), N'RMS')
INSERT [Person].[LUIncomeSource] ([IncomeSourceID], [IncomeSourceDescription], [ModifiedDate], [ModifiedBy]) VALUES (2, N'Part-Time', CAST(N'2023-02-03T14:14:29.800' AS DateTime), N'RMS')
INSERT [Person].[LUIncomeSource] ([IncomeSourceID], [IncomeSourceDescription], [ModifiedDate], [ModifiedBy]) VALUES (3, N'Full-Time', CAST(N'2023-02-03T14:14:29.800' AS DateTime), N'RMS')
INSERT [Person].[LUIncomeSource] ([IncomeSourceID], [IncomeSourceDescription], [ModifiedDate], [ModifiedBy]) VALUES (4, N'Self-Employed', CAST(N'2023-02-03T14:14:29.800' AS DateTime), N'RMS')
INSERT [Person].[LUIncomeSource] ([IncomeSourceID], [IncomeSourceDescription], [ModifiedDate], [ModifiedBy]) VALUES (5, N'SSI/Disability', CAST(N'2023-02-03T14:14:29.800' AS DateTime), N'RMS')
INSERT [Person].[LUIncomeSource] ([IncomeSourceID], [IncomeSourceDescription], [ModifiedDate], [ModifiedBy]) VALUES (6, N'Social Security', CAST(N'2023-02-03T14:14:29.803' AS DateTime), N'RMS')
INSERT [Person].[LUIncomeSource] ([IncomeSourceID], [IncomeSourceDescription], [ModifiedDate], [ModifiedBy]) VALUES (7, N'General Assistance', CAST(N'2023-02-03T14:14:29.803' AS DateTime), N'RMS')
INSERT [Person].[LUIncomeSource] ([IncomeSourceID], [IncomeSourceDescription], [ModifiedDate], [ModifiedBy]) VALUES (8, N'Temporary Assistance for ', CAST(N'2023-02-03T14:14:29.803' AS DateTime), N'RMS')
SET IDENTITY_INSERT [Person].[LUIncomeSource] OFF
GO
SET IDENTITY_INSERT [Person].[LUInsuranceType] ON 

INSERT [Person].[LUInsuranceType] ([InsuranceTypeID], [InsuranceType], [ModifiedBy], [ModifiedDate]) VALUES (1, N'State/Federal', N'RMS', CAST(N'2023-02-03T14:13:23.483' AS DateTime))
INSERT [Person].[LUInsuranceType] ([InsuranceTypeID], [InsuranceType], [ModifiedBy], [ModifiedDate]) VALUES (2, N'Employer', N'RMS', CAST(N'2023-02-03T14:13:23.483' AS DateTime))
INSERT [Person].[LUInsuranceType] ([InsuranceTypeID], [InsuranceType], [ModifiedBy], [ModifiedDate]) VALUES (3, N'Self Insured', N'RMS', CAST(N'2023-02-03T14:13:23.483' AS DateTime))
INSERT [Person].[LUInsuranceType] ([InsuranceTypeID], [InsuranceType], [ModifiedBy], [ModifiedDate]) VALUES (4, N'Veteran', N'RMS', CAST(N'2023-02-03T14:13:23.483' AS DateTime))
INSERT [Person].[LUInsuranceType] ([InsuranceTypeID], [InsuranceType], [ModifiedBy], [ModifiedDate]) VALUES (5, N'Did Not Specify', N'RMS', CAST(N'2023-02-03T14:13:23.483' AS DateTime))
INSERT [Person].[LUInsuranceType] ([InsuranceTypeID], [InsuranceType], [ModifiedBy], [ModifiedDate]) VALUES (6, N'None', N'RMS', CAST(N'2023-02-03T14:13:23.483' AS DateTime))
SET IDENTITY_INSERT [Person].[LUInsuranceType] OFF
GO
SET IDENTITY_INSERT [Person].[LULanguage] ON 

INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (1, N'Brazilian Portuguese', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (2, N'English', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (3, N'French Creole', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (4, N'Dutch', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (5, N'Catalan', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (6, N'Belarusian', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (7, N'Kirundi', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (8, N'German', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (9, N'Greek', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (10, N'Icelandic', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (11, N'Italian', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (12, N'Norwegian', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (13, N'Portuguese', CAST(N'2023-02-03T14:13:18.943' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (14, N'Spanish', CAST(N'2023-02-03T14:13:18.947' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (15, N'Mongolian', CAST(N'2023-02-03T14:13:18.947' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (16, N'Chinese', CAST(N'2023-02-03T14:13:18.947' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (17, N'Japanese', CAST(N'2023-02-03T14:13:18.947' AS DateTime), N'RMS', 0)
INSERT [Person].[LULanguage] ([LanguageID], [LanguageName], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (18, N'Taiwanese', CAST(N'2023-02-03T14:13:18.947' AS DateTime), N'RMS', 0)
SET IDENTITY_INSERT [Person].[LULanguage] OFF
GO
SET IDENTITY_INSERT [Person].[LUPersonType] ON 

INSERT [Person].[LUPersonType] ([PersonTypeID], [PersonType], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (1, N'Employee', CAST(N'2023-02-03T14:13:16.453' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUPersonType] ([PersonTypeID], [PersonType], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (2, N'Volunteer', CAST(N'2023-02-03T14:13:16.453' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUPersonType] ([PersonTypeID], [PersonType], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (3, N'Client', CAST(N'2023-02-03T14:13:16.453' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUPersonType] ([PersonTypeID], [PersonType], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (4, N'Donor', CAST(N'2023-02-03T14:13:16.453' AS DateTime), N'RMS', NULL)
INSERT [Person].[LUPersonType] ([PersonTypeID], [PersonType], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (5, N'Other', CAST(N'2023-02-03T14:13:16.453' AS DateTime), N'RMS', NULL)
SET IDENTITY_INSERT [Person].[LUPersonType] OFF
GO
SET IDENTITY_INSERT [Person].[LUPhoneType] ON 

INSERT [Person].[LUPhoneType] ([PhoneTypeID], [PhoneType], [ModifiedDate], [ModifiedBy]) VALUES (1, N'Home', CAST(N'2023-02-03T14:13:22.077' AS DateTime), N'RMS')
INSERT [Person].[LUPhoneType] ([PhoneTypeID], [PhoneType], [ModifiedDate], [ModifiedBy]) VALUES (2, N'Cell', CAST(N'2023-02-03T14:13:22.077' AS DateTime), N'RMS')
INSERT [Person].[LUPhoneType] ([PhoneTypeID], [PhoneType], [ModifiedDate], [ModifiedBy]) VALUES (3, N'Work', CAST(N'2023-02-03T14:13:22.077' AS DateTime), N'RMS')
SET IDENTITY_INSERT [Person].[LUPhoneType] OFF
GO
SET IDENTITY_INSERT [Person].[LUProgramType] ON 

INSERT [Person].[LUProgramType] ([ProgramTypeID], [ProgramName], [ProgramDescription], [ModifiedDate], [ModifiedBy]) VALUES (1, N'FoodShelf', N'Provides Food for the needy.', CAST(N'2023-02-03T14:13:20.400' AS DateTime), N'RMS')
INSERT [Person].[LUProgramType] ([ProgramTypeID], [ProgramName], [ProgramDescription], [ModifiedDate], [ModifiedBy]) VALUES (2, N'Houseing', N'Helps find Homes for rent, and also helps with dow', CAST(N'2023-02-03T14:13:20.400' AS DateTime), N'RMS')
INSERT [Person].[LUProgramType] ([ProgramTypeID], [ProgramName], [ProgramDescription], [ModifiedDate], [ModifiedBy]) VALUES (3, N'HeatingAssitance', N'Helps pay for electric and gas bills in winter.', CAST(N'2023-02-03T14:13:20.403' AS DateTime), N'RMS')
SET IDENTITY_INSERT [Person].[LUProgramType] OFF
GO
SET IDENTITY_INSERT [Person].[LURace] ON 

INSERT [Person].[LURace] ([RaceID], [RaceDescription], [ModifiedDate], [ModifiedBy]) VALUES (1, N'White', CAST(N'2023-02-03T14:17:18.373' AS DateTime), N'RMS')
INSERT [Person].[LURace] ([RaceID], [RaceDescription], [ModifiedDate], [ModifiedBy]) VALUES (2, N'Black', CAST(N'2023-02-03T14:17:18.373' AS DateTime), N'RMS')
INSERT [Person].[LURace] ([RaceID], [RaceDescription], [ModifiedDate], [ModifiedBy]) VALUES (3, N'Native American', CAST(N'2023-02-03T14:17:18.373' AS DateTime), N'RMS')
INSERT [Person].[LURace] ([RaceID], [RaceDescription], [ModifiedDate], [ModifiedBy]) VALUES (4, N'Hispanic', CAST(N'2023-02-03T14:17:18.373' AS DateTime), N'RMS')
INSERT [Person].[LURace] ([RaceID], [RaceDescription], [ModifiedDate], [ModifiedBy]) VALUES (5, N'Asian or Pacific Islander', CAST(N'2023-02-03T14:17:18.373' AS DateTime), N'RMS')
INSERT [Person].[LURace] ([RaceID], [RaceDescription], [ModifiedDate], [ModifiedBy]) VALUES (6, N'Middle Eastern', CAST(N'2023-02-03T14:17:18.373' AS DateTime), N'RMS')
INSERT [Person].[LURace] ([RaceID], [RaceDescription], [ModifiedDate], [ModifiedBy]) VALUES (7, N'Chinese', CAST(N'2023-02-03T14:17:18.373' AS DateTime), N'RMS')
INSERT [Person].[LURace] ([RaceID], [RaceDescription], [ModifiedDate], [ModifiedBy]) VALUES (8, N'Indian', CAST(N'2023-02-03T14:17:18.373' AS DateTime), N'RMS')
INSERT [Person].[LURace] ([RaceID], [RaceDescription], [ModifiedDate], [ModifiedBy]) VALUES (9, N'European', CAST(N'2023-02-03T14:17:18.377' AS DateTime), N'RMS')
INSERT [Person].[LURace] ([RaceID], [RaceDescription], [ModifiedDate], [ModifiedBy]) VALUES (10, N'Other', CAST(N'2023-02-03T14:17:18.377' AS DateTime), N'RMS')
SET IDENTITY_INSERT [Person].[LURace] OFF
GO
SET IDENTITY_INSERT [Person].[Person] ON 

INSERT [Person].[Person] ([PersonID], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [DateOfBirth], [EmailAddress], [EmailContactPreference], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (372, NULL, N'Donna', NULL, N'Ainsworth', NULL, CAST(N'1974-09-24' AS Date), N'D_Ainsworth@Babson.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS', 0)
INSERT [Person].[Person] ([PersonID], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [DateOfBirth], [EmailAddress], [EmailContactPreference], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (373, NULL, N'Roger', NULL, N'Silvestri', NULL, CAST(N'1987-08-04' AS Date), N'rogersilvestri@gmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS', 0)
INSERT [Person].[Person] ([PersonID], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [DateOfBirth], [EmailAddress], [EmailContactPreference], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (374, NULL, N'Susan', NULL, N'Salgan', NULL, CAST(N'1989-04-07' AS Date), N'suzy@hotmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS', 0)
INSERT [Person].[Person] ([PersonID], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [DateOfBirth], [EmailAddress], [EmailContactPreference], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (375, NULL, N'Eli', NULL, N'Silvestri', NULL, CAST(N'2022-09-06' AS Date), N'EGS@Gmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS', 0)
INSERT [Person].[Person] ([PersonID], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [DateOfBirth], [EmailAddress], [EmailContactPreference], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (376, NULL, N'Albert', NULL, N'Salgan', NULL, CAST(N'1974-10-24' AS Date), N'asalgan@gmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS', 0)
INSERT [Person].[Person] ([PersonID], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [DateOfBirth], [EmailAddress], [EmailContactPreference], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (377, NULL, N'Issac', NULL, N'Salgan', NULL, CAST(N'1952-10-24' AS Date), N'Issack@gmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS', 0)
INSERT [Person].[Person] ([PersonID], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [DateOfBirth], [EmailAddress], [EmailContactPreference], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (378, NULL, N'Anna', NULL, N'Salgan', NULL, CAST(N'1974-11-24' AS Date), N'annasalgan@gmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS', 0)
INSERT [Person].[Person] ([PersonID], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [DateOfBirth], [EmailAddress], [EmailContactPreference], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (379, NULL, N'Jonny', NULL, N'Depp', NULL, CAST(N'1877-01-01' AS Date), N'heresjonny@ymail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS', 0)
INSERT [Person].[Person] ([PersonID], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [DateOfBirth], [EmailAddress], [EmailContactPreference], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (380, NULL, N'Florance', NULL, N'The Machine', NULL, CAST(N'1999-01-01' AS Date), N'Whoknows@outlook.com', 1, CAST(N'2023-02-20T11:59:55.643' AS DateTime), N'RMS', 0)
INSERT [Person].[Person] ([PersonID], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [DateOfBirth], [EmailAddress], [EmailContactPreference], [ModifiedDate], [ModifiedBy], [IsDeleted]) VALUES (381, NULL, N'Stevie', NULL, N'Nicks', NULL, CAST(N'1974-11-24' AS Date), N'myonetruelove@myheart.com', 1, CAST(N'2023-02-20T11:59:55.643' AS DateTime), N'RMS', 0)
SET IDENTITY_INSERT [Person].[Person] OFF
GO
SET IDENTITY_INSERT [Person].[PersonType] ON 

INSERT [Person].[PersonType] ([PersonTypeID], [PersonID], [PersonType], [ModifiedDate], [ModifiedBy]) VALUES (85, 372, 2, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Person].[PersonType] ([PersonTypeID], [PersonID], [PersonType], [ModifiedDate], [ModifiedBy]) VALUES (86, 373, 2, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Person].[PersonType] ([PersonTypeID], [PersonID], [PersonType], [ModifiedDate], [ModifiedBy]) VALUES (87, 374, 2, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Person].[PersonType] ([PersonTypeID], [PersonID], [PersonType], [ModifiedDate], [ModifiedBy]) VALUES (88, 375, 2, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Person].[PersonType] ([PersonTypeID], [PersonID], [PersonType], [ModifiedDate], [ModifiedBy]) VALUES (89, 376, 2, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Person].[PersonType] ([PersonTypeID], [PersonID], [PersonType], [ModifiedDate], [ModifiedBy]) VALUES (90, 377, 2, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Person].[PersonType] ([PersonTypeID], [PersonID], [PersonType], [ModifiedDate], [ModifiedBy]) VALUES (91, 378, 2, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Person].[PersonType] ([PersonTypeID], [PersonID], [PersonType], [ModifiedDate], [ModifiedBy]) VALUES (92, 379, 2, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Person].[PersonType] ([PersonTypeID], [PersonID], [PersonType], [ModifiedDate], [ModifiedBy]) VALUES (93, 380, 2, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Person].[PersonType] ([PersonTypeID], [PersonID], [PersonType], [ModifiedDate], [ModifiedBy]) VALUES (94, 381, 2, CAST(N'2023-02-20' AS Date), N'RMS')
SET IDENTITY_INSERT [Person].[PersonType] OFF
GO
SET IDENTITY_INSERT [Volunteer].[Address] ON 

INSERT [Volunteer].[Address] ([AddressID], [VolunteerID], [AddressLine1], [AddressLine2], [City], [County], [State], [PostalCode], [AddressTypeID], [ModifiedDate], [ModifiedBy]) VALUES (38, 165, N'12 River Way', NULL, N'Harwich', N'Barnstible', N'MA', N'02111', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Address] ([AddressID], [VolunteerID], [AddressLine1], [AddressLine2], [City], [County], [State], [PostalCode], [AddressTypeID], [ModifiedDate], [ModifiedBy]) VALUES (39, 166, N'91 Spring St', N'#12', N'Watertown', N'Middlesex', N'MA', N'02111', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Address] ([AddressID], [VolunteerID], [AddressLine1], [AddressLine2], [City], [County], [State], [PostalCode], [AddressTypeID], [ModifiedDate], [ModifiedBy]) VALUES (40, 167, N'91 Spring St', N'#12', N'Watertown', N'Middlesex', N'MA', N'02111', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Address] ([AddressID], [VolunteerID], [AddressLine1], [AddressLine2], [City], [County], [State], [PostalCode], [AddressTypeID], [ModifiedDate], [ModifiedBy]) VALUES (41, 168, N'91 Spring St', N'#12', N'Watertown', N'Middlesex', N'MA', N'02111', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Address] ([AddressID], [VolunteerID], [AddressLine1], [AddressLine2], [City], [County], [State], [PostalCode], [AddressTypeID], [ModifiedDate], [ModifiedBy]) VALUES (42, 169, N'121 Jackson Rd', NULL, N'Newton', N'Middlesex', N'MA', N'02311', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Address] ([AddressID], [VolunteerID], [AddressLine1], [AddressLine2], [City], [County], [State], [PostalCode], [AddressTypeID], [ModifiedDate], [ModifiedBy]) VALUES (43, 170, N'121 Jackson Rd', NULL, N'Newton', N'Middlesex', N'MA', N'02311', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Address] ([AddressID], [VolunteerID], [AddressLine1], [AddressLine2], [City], [County], [State], [PostalCode], [AddressTypeID], [ModifiedDate], [ModifiedBy]) VALUES (44, 171, N'121 Jackson Rd', NULL, N'Newton', N'Middlesex', N'MA', N'02311', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Address] ([AddressID], [VolunteerID], [AddressLine1], [AddressLine2], [City], [County], [State], [PostalCode], [AddressTypeID], [ModifiedDate], [ModifiedBy]) VALUES (45, 172, N'Somewhere Road', NULL, N'Hollywood', N'LA County', N'CA', N'00000', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Address] ([AddressID], [VolunteerID], [AddressLine1], [AddressLine2], [City], [County], [State], [PostalCode], [AddressTypeID], [ModifiedDate], [ModifiedBy]) VALUES (46, 173, N'my mind', NULL, N'songs', N'get stuck in', N'ME', N'99999', 1, CAST(N'2023-02-20T11:59:55.643' AS DateTime), N'RMS')
INSERT [Volunteer].[Address] ([AddressID], [VolunteerID], [AddressLine1], [AddressLine2], [City], [County], [State], [PostalCode], [AddressTypeID], [ModifiedDate], [ModifiedBy]) VALUES (47, 174, N'No matter how old', NULL, N'She will always', N'be', N'my', N'pass', 1, CAST(N'2023-02-20T11:59:55.643' AS DateTime), N'RMS')
SET IDENTITY_INSERT [Volunteer].[Address] OFF
GO
SET IDENTITY_INSERT [Volunteer].[LUVolunteerJobDescription] ON 

INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (1, 1, N'Intake Worker', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (2, 1, N'WareHouse Worker', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (3, 1, N'Inventory', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (4, 1, N'Vendor Management', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (5, 2, N'Administration Assistant', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (6, 2, N'Finacial Assistant', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (7, 3, N'Coordinator', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (8, 3, N'Client Outreach', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (9, 4, N'Media Relations', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (10, 4, N'Marketing Assistant', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (11, 5, N'Charity Outreach', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (12, 5, N'Fundraiser', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (13, 5, N'Event Coordinator', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
INSERT [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID], [OrganizationID], [JobDescription], [ModifiedDate], [ModifiedBy]) VALUES (14, 5, N'Event Volunteer', CAST(N'2023-02-03T14:13:24.923' AS DateTime), N'RMS')
SET IDENTITY_INSERT [Volunteer].[LUVolunteerJobDescription] OFF
GO
SET IDENTITY_INSERT [Volunteer].[Volunteer] ON 

INSERT [Volunteer].[Volunteer] ([VolunteerID], [PersonID], [Email], [IsActive], [ModifiedDate], [ModifiedBy]) VALUES (165, 372, N'D_Ainsworth@Babson.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Volunteer] ([VolunteerID], [PersonID], [Email], [IsActive], [ModifiedDate], [ModifiedBy]) VALUES (166, 373, N'rogersilvestri@gmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Volunteer] ([VolunteerID], [PersonID], [Email], [IsActive], [ModifiedDate], [ModifiedBy]) VALUES (167, 374, N'suzy@hotmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Volunteer] ([VolunteerID], [PersonID], [Email], [IsActive], [ModifiedDate], [ModifiedBy]) VALUES (168, 375, N'EGS@Gmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Volunteer] ([VolunteerID], [PersonID], [Email], [IsActive], [ModifiedDate], [ModifiedBy]) VALUES (169, 376, N'asalgan@gmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Volunteer] ([VolunteerID], [PersonID], [Email], [IsActive], [ModifiedDate], [ModifiedBy]) VALUES (170, 377, N'Issack@gmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Volunteer] ([VolunteerID], [PersonID], [Email], [IsActive], [ModifiedDate], [ModifiedBy]) VALUES (171, 378, N'annasalgan@gmail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Volunteer] ([VolunteerID], [PersonID], [Email], [IsActive], [ModifiedDate], [ModifiedBy]) VALUES (172, 379, N'heresjonny@ymail.com', 1, CAST(N'2023-02-20T11:59:55.640' AS DateTime), N'RMS')
INSERT [Volunteer].[Volunteer] ([VolunteerID], [PersonID], [Email], [IsActive], [ModifiedDate], [ModifiedBy]) VALUES (173, 380, N'Whoknows@outlook.com', 1, CAST(N'2023-02-20T11:59:55.643' AS DateTime), N'RMS')
INSERT [Volunteer].[Volunteer] ([VolunteerID], [PersonID], [Email], [IsActive], [ModifiedDate], [ModifiedBy]) VALUES (174, 381, N'myonetruelove@myheart.com', 1, CAST(N'2023-02-20T11:59:55.643' AS DateTime), N'RMS')
SET IDENTITY_INSERT [Volunteer].[Volunteer] OFF
GO
INSERT [Volunteer].[VolunteerAvailability] ([VolunteerID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (165, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerAvailability] ([VolunteerID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (166, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerAvailability] ([VolunteerID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (167, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerAvailability] ([VolunteerID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (168, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerAvailability] ([VolunteerID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (169, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerAvailability] ([VolunteerID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (170, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerAvailability] ([VolunteerID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (171, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerAvailability] ([VolunteerID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (172, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerAvailability] ([VolunteerID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (173, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerAvailability] ([VolunteerID], [SundayAM], [SundayPM], [MondayAM], [MondayPM], [TuesdayAM], [TuesdayPM], [WednesdayAM], [WednesdayPM], [ThursdayAM], [ThursdayPM], [FridayAM], [FridayPM], [SaturdayAM], [SaturdayPM], [ModifiedDate], [ModifiedBy]) VALUES (174, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, CAST(N'2023-02-20' AS Date), N'RMS')
GO
SET IDENTITY_INSERT [Volunteer].[VolunteerJob] ON 

INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (25, 165, 2, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (26, 166, 1, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (27, 167, 1, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (28, 168, 3, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (29, 169, 5, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (30, 170, 4, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (31, 171, 4, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (32, 172, 1, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (33, 173, 1, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (34, 174, 2, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (36, 165, 3, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (37, 165, 1, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (38, 165, 4, CAST(N'2023-02-20' AS Date), N'RMS')
INSERT [Volunteer].[VolunteerJob] ([JobID], [VolunteerID], [JobDescriptionID], [ModifiedDate], [ModifiedBy]) VALUES (39, 165, 5, CAST(N'2023-02-20' AS Date), N'RMS')
SET IDENTITY_INSERT [Volunteer].[VolunteerJob] OFF
GO
ALTER TABLE [dbo].[OrganizationHours]  WITH CHECK ADD  CONSTRAINT [FK_OrgID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organization] ([OrganizationID])
GO
ALTER TABLE [dbo].[OrganizationHours] CHECK CONSTRAINT [FK_OrgID]
GO
ALTER TABLE [Foodshelf].[FoodDisbursements]  WITH CHECK ADD  CONSTRAINT [FK_FoodshelfClientID] FOREIGN KEY([PersonID], [FoodshelfClientID])
REFERENCES [Foodshelf].[FoodshelfClient] ([PersonID], [FoodshelfClientID])
GO
ALTER TABLE [Foodshelf].[FoodDisbursements] CHECK CONSTRAINT [FK_FoodshelfClientID]
GO
ALTER TABLE [Foodshelf].[FoodDisbursements]  WITH CHECK ADD  CONSTRAINT [FK_FoodTypeID] FOREIGN KEY([FoodTypeID])
REFERENCES [Foodshelf].[LUFoodType] ([FoodTypeID])
GO
ALTER TABLE [Foodshelf].[FoodDisbursements] CHECK CONSTRAINT [FK_FoodTypeID]
GO
ALTER TABLE [Foodshelf].[FoodshelfCertification]  WITH CHECK ADD  CONSTRAINT [FK_FoodshelfCertificationClientID] FOREIGN KEY([PersonID], [FoodshelfClientID])
REFERENCES [Foodshelf].[FoodshelfClient] ([PersonID], [FoodshelfClientID])
GO
ALTER TABLE [Foodshelf].[FoodshelfCertification] CHECK CONSTRAINT [FK_FoodshelfCertificationClientID]
GO
ALTER TABLE [Foodshelf].[FoodshelfCertification]  WITH CHECK ADD  CONSTRAINT [FK_FoodshelfCertificationTextID] FOREIGN KEY([CertificationTextID])
REFERENCES [Foodshelf].[LUCertificationText] ([CertificationTextID])
GO
ALTER TABLE [Foodshelf].[FoodshelfCertification] CHECK CONSTRAINT [FK_FoodshelfCertificationTextID]
GO
ALTER TABLE [Foodshelf].[FoodshelfClient]  WITH CHECK ADD  CONSTRAINT [FK_FoodshelfPersonID] FOREIGN KEY([PersonID])
REFERENCES [Person].[Person] ([PersonID])
GO
ALTER TABLE [Foodshelf].[FoodshelfClient] CHECK CONSTRAINT [FK_FoodshelfPersonID]
GO
ALTER TABLE [Foodshelf].[HouseholdNotes]  WITH CHECK ADD  CONSTRAINT [FK_FS_ClientID] FOREIGN KEY([PersonID], [FoodshelfClientID])
REFERENCES [Foodshelf].[FoodshelfClient] ([PersonID], [FoodshelfClientID])
GO
ALTER TABLE [Foodshelf].[HouseholdNotes] CHECK CONSTRAINT [FK_FS_ClientID]
GO
ALTER TABLE [Foodshelf].[HouseholdNotes]  WITH CHECK ADD  CONSTRAINT [FK_FS_HouseholdID] FOREIGN KEY([PersonID], [HouseHoldID])
REFERENCES [Person].[Household] ([PersonID], [HouseHoldID])
GO
ALTER TABLE [Foodshelf].[HouseholdNotes] CHECK CONSTRAINT [FK_FS_HouseholdID]
GO
ALTER TABLE [Person].[Address]  WITH CHECK ADD  CONSTRAINT [FK_AddressPersonID] FOREIGN KEY([PersonID])
REFERENCES [Person].[Person] ([PersonID])
GO
ALTER TABLE [Person].[Address] CHECK CONSTRAINT [FK_AddressPersonID]
GO
ALTER TABLE [Person].[Address]  WITH CHECK ADD  CONSTRAINT [FK_LUAddressType] FOREIGN KEY([AddressTypeID])
REFERENCES [Person].[LUAddressType] ([AddressTypeID])
GO
ALTER TABLE [Person].[Address] CHECK CONSTRAINT [FK_LUAddressType]
GO
ALTER TABLE [Person].[Demographics]  WITH CHECK ADD  CONSTRAINT [FK_Demo_COOID] FOREIGN KEY([CountryOfOriginID])
REFERENCES [Person].[LUCountryOfOrigin] ([CountryID])
GO
ALTER TABLE [Person].[Demographics] CHECK CONSTRAINT [FK_Demo_COOID]
GO
ALTER TABLE [Person].[Demographics]  WITH CHECK ADD  CONSTRAINT [FK_Demo_EdCatID] FOREIGN KEY([EducationCategoryID])
REFERENCES [Person].[LUEducationCategory] ([EducationCategoryID])
GO
ALTER TABLE [Person].[Demographics] CHECK CONSTRAINT [FK_Demo_EdCatID]
GO
ALTER TABLE [Person].[Demographics]  WITH CHECK ADD  CONSTRAINT [FK_Demo_EthnicID] FOREIGN KEY([EthnicityID])
REFERENCES [Person].[LUEthnicity] ([EthnicityID])
GO
ALTER TABLE [Person].[Demographics] CHECK CONSTRAINT [FK_Demo_EthnicID]
GO
ALTER TABLE [Person].[Demographics]  WITH CHECK ADD  CONSTRAINT [FK_Demo_GenderID] FOREIGN KEY([GenderID])
REFERENCES [Person].[LUGender] ([GenderID])
GO
ALTER TABLE [Person].[Demographics] CHECK CONSTRAINT [FK_Demo_GenderID]
GO
ALTER TABLE [Person].[Demographics]  WITH CHECK ADD  CONSTRAINT [FK_Demo_HousingStatus] FOREIGN KEY([HousingStatusID])
REFERENCES [Person].[LUHousingStatus] ([HousingStatusID])
GO
ALTER TABLE [Person].[Demographics] CHECK CONSTRAINT [FK_Demo_HousingStatus]
GO
ALTER TABLE [Person].[Demographics]  WITH CHECK ADD  CONSTRAINT [FK_Demo_IncomeID] FOREIGN KEY([IncomeSourceID])
REFERENCES [Person].[LUIncomeSource] ([IncomeSourceID])
GO
ALTER TABLE [Person].[Demographics] CHECK CONSTRAINT [FK_Demo_IncomeID]
GO
ALTER TABLE [Person].[Demographics]  WITH CHECK ADD  CONSTRAINT [FK_Demo_InsurID] FOREIGN KEY([InsuranceTypeID])
REFERENCES [Person].[LUInsuranceType] ([InsuranceTypeID])
GO
ALTER TABLE [Person].[Demographics] CHECK CONSTRAINT [FK_Demo_InsurID]
GO
ALTER TABLE [Person].[Demographics]  WITH CHECK ADD  CONSTRAINT [FK_Demo_RaceID] FOREIGN KEY([RaceID])
REFERENCES [Person].[LURace] ([RaceID])
GO
ALTER TABLE [Person].[Demographics] CHECK CONSTRAINT [FK_Demo_RaceID]
GO
ALTER TABLE [Person].[Demographics]  WITH CHECK ADD  CONSTRAINT [FK_Deomographics_Person] FOREIGN KEY([PersonID])
REFERENCES [Person].[Person] ([PersonID])
GO
ALTER TABLE [Person].[Demographics] CHECK CONSTRAINT [FK_Deomographics_Person]
GO
ALTER TABLE [Person].[Household]  WITH CHECK ADD  CONSTRAINT [FK_FoodshelfPersonID] FOREIGN KEY([PersonID])
REFERENCES [Person].[Person] ([PersonID])
GO
ALTER TABLE [Person].[Household] CHECK CONSTRAINT [FK_FoodshelfPersonID]
GO
ALTER TABLE [Person].[Household]  WITH CHECK ADD  CONSTRAINT [FK_HouseHoldRelationID] FOREIGN KEY([HouseHoldRelationID])
REFERENCES [Person].[LUHouseHoldRelation] ([HouseholdRelationID])
GO
ALTER TABLE [Person].[Household] CHECK CONSTRAINT [FK_HouseHoldRelationID]
GO
ALTER TABLE [Person].[LanguagesSpoken]  WITH CHECK ADD  CONSTRAINT [FK_LanguageID] FOREIGN KEY([LanguageID])
REFERENCES [Person].[LULanguage] ([LanguageID])
GO
ALTER TABLE [Person].[LanguagesSpoken] CHECK CONSTRAINT [FK_LanguageID]
GO
ALTER TABLE [Person].[LanguagesSpoken]  WITH CHECK ADD  CONSTRAINT [FK_LanguagesSpoken_Person] FOREIGN KEY([PersonID])
REFERENCES [Person].[Person] ([PersonID])
GO
ALTER TABLE [Person].[LanguagesSpoken] CHECK CONSTRAINT [FK_LanguagesSpoken_Person]
GO
ALTER TABLE [Person].[PersonType]  WITH CHECK ADD  CONSTRAINT [FK_PERSONTYPE_PersonID] FOREIGN KEY([PersonID])
REFERENCES [Person].[Person] ([PersonID])
GO
ALTER TABLE [Person].[PersonType] CHECK CONSTRAINT [FK_PERSONTYPE_PersonID]
GO
ALTER TABLE [Person].[PersonType]  WITH CHECK ADD  CONSTRAINT [FK_PersonTypeID] FOREIGN KEY([PersonType])
REFERENCES [Person].[LUPersonType] ([PersonTypeID])
GO
ALTER TABLE [Person].[PersonType] CHECK CONSTRAINT [FK_PersonTypeID]
GO
ALTER TABLE [Person].[Phone]  WITH CHECK ADD  CONSTRAINT [FK_Phone_Person] FOREIGN KEY([PersonID])
REFERENCES [Person].[Person] ([PersonID])
GO
ALTER TABLE [Person].[Phone] CHECK CONSTRAINT [FK_Phone_Person]
GO
ALTER TABLE [Person].[Phone]  WITH CHECK ADD  CONSTRAINT [FK_PhoneTypeID] FOREIGN KEY([PhoneType])
REFERENCES [Person].[LUPhoneType] ([PhoneTypeID])
GO
ALTER TABLE [Person].[Phone] CHECK CONSTRAINT [FK_PhoneTypeID]
GO
ALTER TABLE [Person].[ProgramServicesUsed]  WITH CHECK ADD  CONSTRAINT [FK_ProgramServicesUsedPersonID] FOREIGN KEY([PersonID])
REFERENCES [Person].[Person] ([PersonID])
GO
ALTER TABLE [Person].[ProgramServicesUsed] CHECK CONSTRAINT [FK_ProgramServicesUsedPersonID]
GO
ALTER TABLE [Person].[ProgramServicesUsed]  WITH CHECK ADD  CONSTRAINT [FK_ProgramServicesUsedProgramID] FOREIGN KEY([ProgramServiceID])
REFERENCES [Person].[LUProgramType] ([ProgramTypeID])
GO
ALTER TABLE [Person].[ProgramServicesUsed] CHECK CONSTRAINT [FK_ProgramServicesUsedProgramID]
GO
ALTER TABLE [Signature].[Signature]  WITH CHECK ADD  CONSTRAINT [FK_SignaturePersonID] FOREIGN KEY([PersonID])
REFERENCES [Person].[Person] ([PersonID])
GO
ALTER TABLE [Signature].[Signature] CHECK CONSTRAINT [FK_SignaturePersonID]
GO
ALTER TABLE [Volunteer].[Address]  WITH CHECK ADD  CONSTRAINT [FK_AddressType] FOREIGN KEY([AddressTypeID])
REFERENCES [Person].[LUAddressType] ([AddressTypeID])
GO
ALTER TABLE [Volunteer].[Address] CHECK CONSTRAINT [FK_AddressType]
GO
ALTER TABLE [Volunteer].[Address]  WITH CHECK ADD  CONSTRAINT [FK_VolunteerID] FOREIGN KEY([VolunteerID])
REFERENCES [Volunteer].[Volunteer] ([VolunteerID])
GO
ALTER TABLE [Volunteer].[Address] CHECK CONSTRAINT [FK_VolunteerID]
GO
ALTER TABLE [Volunteer].[DateRequest]  WITH CHECK ADD FOREIGN KEY([VolunteerID])
REFERENCES [Volunteer].[Volunteer] ([VolunteerID])
GO
ALTER TABLE [Volunteer].[LUVolunteerJobDescription]  WITH CHECK ADD  CONSTRAINT [FK_OrgID] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organization] ([OrganizationID])
GO
ALTER TABLE [Volunteer].[LUVolunteerJobDescription] CHECK CONSTRAINT [FK_OrgID]
GO
ALTER TABLE [Volunteer].[Phone]  WITH CHECK ADD  CONSTRAINT [FK_VOL_PhoneType] FOREIGN KEY([PhoneTypeID])
REFERENCES [Person].[LUPhoneType] ([PhoneTypeID])
GO
ALTER TABLE [Volunteer].[Phone] CHECK CONSTRAINT [FK_VOL_PhoneType]
GO
ALTER TABLE [Volunteer].[Phone]  WITH CHECK ADD  CONSTRAINT [FK_VolunteerPhoneID] FOREIGN KEY([VolunteerID])
REFERENCES [Volunteer].[Volunteer] ([VolunteerID])
GO
ALTER TABLE [Volunteer].[Phone] CHECK CONSTRAINT [FK_VolunteerPhoneID]
GO
ALTER TABLE [Volunteer].[Schedule]  WITH CHECK ADD FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organization] ([OrganizationID])
GO
ALTER TABLE [Volunteer].[Volunteer]  WITH CHECK ADD  CONSTRAINT [FK_Vol_PersonID] FOREIGN KEY([PersonID])
REFERENCES [Person].[Person] ([PersonID])
GO
ALTER TABLE [Volunteer].[Volunteer] CHECK CONSTRAINT [FK_Vol_PersonID]
GO
ALTER TABLE [Volunteer].[VolunteerAvailability]  WITH CHECK ADD  CONSTRAINT [FK_Vol_Avail_ID] FOREIGN KEY([VolunteerID])
REFERENCES [Volunteer].[Volunteer] ([VolunteerID])
GO
ALTER TABLE [Volunteer].[VolunteerAvailability] CHECK CONSTRAINT [FK_Vol_Avail_ID]
GO
ALTER TABLE [Volunteer].[VolunteerEmergencyContact]  WITH CHECK ADD  CONSTRAINT [FK_RelationID] FOREIGN KEY([ContactRelationID])
REFERENCES [Person].[LUHouseHoldRelation] ([HouseholdRelationID])
GO
ALTER TABLE [Volunteer].[VolunteerEmergencyContact] CHECK CONSTRAINT [FK_RelationID]
GO
ALTER TABLE [Volunteer].[VolunteerEmergencyContact]  WITH CHECK ADD  CONSTRAINT [FKVolID] FOREIGN KEY([VolunteerID])
REFERENCES [Volunteer].[Volunteer] ([VolunteerID])
GO
ALTER TABLE [Volunteer].[VolunteerEmergencyContact] CHECK CONSTRAINT [FKVolID]
GO
ALTER TABLE [Volunteer].[VolunteerJob]  WITH CHECK ADD  CONSTRAINT [FK_DescID] FOREIGN KEY([JobDescriptionID])
REFERENCES [Volunteer].[LUVolunteerJobDescription] ([VolunteerJobsID])
GO
ALTER TABLE [Volunteer].[VolunteerJob] CHECK CONSTRAINT [FK_DescID]
GO
ALTER TABLE [Volunteer].[VolunteerJob]  WITH CHECK ADD  CONSTRAINT [FK_JOB_VolID] FOREIGN KEY([VolunteerID])
REFERENCES [Volunteer].[Volunteer] ([VolunteerID])
GO
ALTER TABLE [Volunteer].[VolunteerJob] CHECK CONSTRAINT [FK_JOB_VolID]
GO
ALTER TABLE [Volunteer].[VolunteerNotes]  WITH CHECK ADD  CONSTRAINT [FK_VolID] FOREIGN KEY([VolunteerID])
REFERENCES [Volunteer].[Volunteer] ([VolunteerID])
GO
ALTER TABLE [Volunteer].[VolunteerNotes] CHECK CONSTRAINT [FK_VolID]
GO
/****** Object:  StoredProcedure [dbo].[DeleteOrganizationHours]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DeleteOrganizationHours] @OrgID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM dbo.OrganizationHours WHERE @OrgID = OrganizationID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH

GO
/****** Object:  StoredProcedure [dbo].[InsertOrganization]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[InsertOrganization] @Name VARCHAR(50), @Phone VARCHAR(10), @Address VARCHAR(50), @Note VARCHAR(MAX), @UserEdit VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
	
		IF EXISTS(SELECT OrganizationID FROM Organization WHERE @Name = OrganizationName)
		BEGIN
			SELECT @ErrorMessage = 'Housing Status Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [dbo].[Organization]
			([OrganizationName],
			[Phone]
			,[Address]
			,[Note]
			,[ModifiedDate]
			,[ModifiedBy])
		VALUES
			(@Name, @Phone, @Address, @Note, GETDATE(), @UserEdit)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH
GO
/****** Object:  StoredProcedure [dbo].[InsertOrganizationHours]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InsertOrganizationHours] @OrgID INT,
	@SundayAM BIT = 0, @SundayPM BIT = 0,
	@MondayAM BIT = 0, @MondayPM BIT = 0,
	@TuesdayAM BIT = 0, @TuesdayPM BIT = 0,
	@WednesdayAM BIT = 0, @WednesdayPM BIT = 0,
	@ThursdayAM BIT = 0, @ThursdayPM BIT = 0,
	@FridayAM BIT = 0, @FridayPM BIT = 0,
	@SaturdayAM BIT = 0, @SaturdayPM BIT = 0,
	@ModifiedBy VARCHAR(3), @ErrorMessage VARCHAR(50) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
		
		IF EXISTS(SELECT OrganizationID FROM dbo.OrganizationHours WHERE @OrgID = OrganizationID)
		BEGIN
			SELECT @ErrorMessage = 'Organization already has opperating hours.';
			THROW 500000, @ErrorMessage, 1;
		END

		INSERT INTO dbo.OrganizationHours(
			OrganizationID,
			SundayAM, SundayPM,
			MondayAM, MondayPM,
			TuesdayAM, TuesdayPM,
			WednesdayAM, WednesdayPM,
			ThursdayAM, ThursdayPM,
			FridayAM, FridayPM,
			SaturdayAM, SaturdayPM,
			ModifiedDate, ModifiedBy)
		VALUES 	(@OrgID,
			@SundayAM, @SundayPM,
			@MondayAM, @MondayPM,
			@TuesdayAM, @TuesdayPM,
			@WednesdayAM, @WednesdayPM,
			@ThursdayAM, @ThursdayPM,
			@FridayAM, @FridayPM,
			@SaturdayAM, @SaturdayPM,
			GETDATE(), @ModifiedBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	THROW 500001, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [dbo].[TotalInsert]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[TotalInsert] @TI_PersonType INT, @TI_Title VARCHAR(8) = NULL, @TI_FirstName dbo.Name, @TI_MiddleName dbo.Name = NULL, @TI_LastName dbo.Name, @TI_Suffix VARCHAR(10) = NULL,
								 @TI_DateOfBirth DATE, @TI_EmailAddress VARCHAR(50), @TI_EmailPref bit = 1, @TI_AddressLine1 VARCHAR(60) = NULL, @TI_AddressLine2 VARCHAR(60) = NULL, 
								 @TI_City VARCHAR(30) = NULL, @TI_County VARCHAR(30) = NULL, @TI_State VARCHAR(2) = NULL, @TI_PostalCode VARCHAR(5) = NULL, @TI_AddressType INT = NULL, @TI_EditBy VARCHAR(3),
								 @TI_HouseHoldID INT = NULL, @TI_RelationID INT = NULL,
								 @TI_SundayAM BIT = 0, @TI_SundayPM BIT = 0,@TI_MondayAM BIT = 0, @TI_MondayPM BIT = 0,@TI_TuesdayAM BIT = 0, @TI_TuesdayPM BIT = 0,@TI_WednesdayAM BIT = 0, @TI_WednesdayPM BIT = 0,
								 @TI_ThursdayAM BIT = 0, @TI_ThursdayPM BIT = 0,@TI_FridayAM BIT = 0, @TI_FridayPM BIT = 0,@TI_SaturdayAM BIT = 0, @TI_SaturdayPM BIT = 0,
								 @VolOrgID INT = NULL,
								 @TI_OutPersonID INT OUTPUT, @TI_OutSucc BIT OUTPUT, @TI_ErrorMessage VARCHAR(50) ='' OUTPUT

AS

DECLARE @NewPersonID INT,
		@NewVolID INT,
		@ErrorModifier VARCHAR(75),
		@AddressValidity BIT

SELECT @AddressValidity = dbo.CheckAddressValid(@TI_AddressLine1,@TI_AddressLine2, @TI_City, @TI_County, @TI_State, @TI_PostalCode, @TI_AddressType)

BEGIN TRY
	BEGIN TRANSACTION
	--Check to make sure that PersonType is Valid
	IF NOT EXISTS(SELECT PersonTypeID FROM Person.LUPersonType WHERE @TI_PersonType = PersonTypeID)
	BEGIN
		SET @TI_OutSucc = 0;
		SET @TI_ErrorMessage = 'Invalid Person Type'
		RAISERROR(@TI_ErrorMessage, 16, 1)
	END

	IF EXISTS (SELECT PersonTypeID FROM Person.LUPersonType WHERE @TI_PersonType BETWEEN 1 AND 3) AND @AddressValidity = 0
	BEGIN
		SET @TI_OutSucc = 0;
		SELECT @ErrorModifier =  PersonType FROM Person.LUPersonType WHERE @TI_PersonType = PersonTypeID
		SET @TI_ErrorMessage = CONCAT('Person Type: ', @ErrorModifier,'. Must have a valid Address.');
		THROW 5000001, @TI_ErrorMessage, 1;
	END

	EXEC Person.InsertPerson	@FirstName = @TI_FirstName, @LastName = @TI_LastName, @DateOfBirth = @TI_DateOfBirth, @EMailAddress = @TI_EmailAddress, @EditBy = @TI_EditBy, 
								@OutPersonID = @TI_OutPersonID OUTPUT, @OutSucc = @TI_OutSucc OUTPUT, @ErrorMessage = @TI_ErrorMessage OUTPUT

	IF @TI_OutPersonID IS NULL
	BEGIN
		SET @TI_ErrorMessage = 'Person Not Created';
		THROW 5000001, @TI_ErrorMessage, 1
	END

	EXEC Person.InsertPersonType @PersonType = @TI_PersonType, @Person = @TI_OutPersonID, @UserEdit = @TI_EditBy, @ErrorMessage = @TI_ErrorMessage OUTPUT;

	IF @TI_PersonType = 2
	BEGIN
		EXEC Volunteer.InsertVolunteer @PersonID = @TI_OutPersonID, @Email = @TI_EmailAddress, @EditBy = @TI_EditBy, @ErrorMessage = @TI_ErrorMessage OUTPUT
		SELECT @NewVolID = VolunteerID FROM Volunteer.Volunteer WHERE @TI_OutPersonID = PersonID
		PRINT @NewVolID
		EXEC Volunteer.InsertAddress	@VolID = @NewVolID, @AddressLine1 = @TI_AddressLine1, @AddressLine2 = @TI_AddressLine2, @City = @TI_City, @County = @TI_County, @State = @TI_State, @PostalCode = @TI_PostalCode, 
										@Type = @TI_AddressType, @EditBy = @TI_EditBy, @ErrorMessage = @TI_ErrorMessage OUTPUT

		EXEC Volunteer.InsertAvailability	@VolID = @NewVolID, @SundayAM = @TI_SundayAM, @SundayPM = @TI_SundayPM, @MondayAM = @TI_MondayAM, @MondayPM = @TI_MondayPM, @TuesdayAM = @TI_TuesdayAM, @TuesdayPM = @TI_TuesdayPM, @WednesdayAM = @TI_WednesdayAM, @WednesdayPM = @TI_WednesdayPM,
											@ThursdayAM = @TI_ThursdayAM, @ThursdayPM = @TI_ThursdayPM, @FridayAM = @TI_FridayAM, @FridayPM = @TI_FridayPM, @SaturdayAM = @TI_SaturdayAM, @SaturdayPM = @TI_SaturdayPM, @ModifiedBy = @TI_EditBy, @ErrorMessage = @TI_ErrorMessage OUTPUT

		EXEC Volunteer.InsertJob	@VolID = @NewVolID, @JobDescID = @VolOrgID, @EditBy = @TI_EditBy, @ErrorMessage = @TI_ErrorMessage OUTPUT
	END
	ELSE
	BEGIN
		EXEC Person.InsertAddress	@PersonID = @TI_OutPersonID, @AddressLine1 = @TI_AddressLine1, @AddressLine2 = @TI_AddressLine2, @City = @TI_City, @County = @TI_County, @State = @TI_State, @PostalCode = @TI_PostalCode, 
									@Type = @TI_AddressType, @EditBy = @TI_EditBy, @ErrorMessage = @TI_ErrorMessage OUTPUT
	END

	IF @TI_PersonType = 3
	BEGIN
		EXEC Foodshelf.InsertFoodshelfClient @PersonID = @TI_OutPersonID, @EditBy = @TI_EditBy, @ErrorMessage = @TI_ErrorMessage OUTPUT
		EXEC Person.InsertProgramServiceUsed @PersonID = @TI_OutPersonID, @ProgramTypeID = 1, @EditBy =@TI_EditBy, @ErrorMessage = @TI_ErrorMessage OUTPUT
	END



	IF @TI_RelationID IS NOT NULL
		EXEC Person.InsertHousehold @PersonID = @TI_OutPersonID, @HouseHoldID = @TI_HouseHoldID, @HouseHoldRelation = @TI_RelationID, @EditBy = @TI_EditBy, @ErrorMessage = @TI_ErrorMessage OUTPUT
			
	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	SET @TI_ErrorMessage = Error_Message()
	
	SET @TI_OutSucc =0;
	SET @TI_ErrorMessage=  @TI_ErrorMessage + '-1001';
	Throw 99999, @TI_ErrorMessage, 1;

END CATCH

GO
/****** Object:  StoredProcedure [dbo].[UpdatePeopleNotVolunteers]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--This is the procedure that uses the Function.
CREATE PROCEDURE [dbo].[UpdatePeopleNotVolunteers] @UpdatedBy VARCHAR(3)
AS

	DECLARE @PersonToUpdate INT,
			@UpdateAddressLine1 VARCHAR(60),
			@UpdateAddressLine2 VARCHAR(60),
			@UpdateCity VARCHAR(30),
			@UpdateCounty VARCHAR(30),
			@UpdateState VARCHAR(2),
			@UpdateCode VARCHAR(5),
			@UpdateType INT,
			@NewVolunteerID INT,
			@VolunteerEmail VARCHAR(50),
			@AddressIDStore INT,
			@OutErrorMessage VARCHAR(40)

	SELECT TOP 1 @PersonToUpdate = PersonID FROM Person.FindVolunteerTypeNotVolunteer()
	SELECT @VolunteerEmail = EmailAddress FROM Person.FindVolunteerTypeNotVolunteer() AS PS WHERE @PersonToUpdate = PersonID

	WHILE @PersonToUpdate IS NOT NULL
	BEGIN
		EXEC Volunteer.InsertVolunteer @PersonID = @PersonToUpdate, @Email = @VolunteerEmail, @EditBy = @UpdatedBy, @ErrorMessage = @OutErrorMessage OUTPUT
		SET @NewVolunteerID = @@IDENTITY

		--Check to see if Person is in Address.
		WHILE EXISTS(SELECT PersonID FROM Person.Address WHERE @PersonToUpdate = PersonID)
		BEGIN
			
			--Sets all the variables needed to insert an address.
			SELECT	@AddressIDStore = AddressID,  @UpdateAddressLine1 = AddressLine1, @UpdateAddressLine2 = AddressLine2, @UpdateCity = City, 
					@UpdateCounty = County, @UpdateState = State, @UpdateType = AddressTypeID, @UpdateCode = PostalCode FROM Person.Address
						WHERE @PersonToUpdate = PersonID

			--Inserts the Gathered Address from Person inserts into Volunteer
			EXEC Volunteer.InsertAddress @VolID = @NewVolunteerID, @AddressLine1 = @UpdateAddressLine1, @AddressLine2 = @UpdateAddressLine2, @City = @UpdateCity, @County = @UpdateCounty,
						@State = @UpdateState, @PostalCode = @UpdateCode, @Type = @UpdateType, @EditBy = @UpdatedBy, @ErrorMessage = @OutErrorMessage OUTPUT

			--Deletes The Address from Person.Address
			EXEC Person.DeleteAddress @AddressToDeleteID = @AddressIDStore, @PersonToDeleteID = @PersonToUpdate
			
		END

		
		IF EXISTS(SELECT PersonID FROM Person.FindVolunteerTypeNotVolunteer())
		BEGIN
			SELECT TOP 1 @PersonToUpdate = PersonID FROM Person.FindVolunteerTypeNotVolunteer()
		END
		ELSE SET @PersonToUpdate = NULL
		SELECT @VolunteerEmail = EmailAddress FROM Person.FindVolunteerTypeNotVolunteer() AS PS WHERE @PersonToUpdate = PersonID

	END
GO
/****** Object:  StoredProcedure [Foodshelf].[DeleteFoodDisbursements]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Foodshelf].[DeleteFoodDisbursements] @FoodDisbursementID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Foodshelf.FoodDisbursements WHERE FoodDisbursementID = @FoodDisbursementID
COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

GO
/****** Object:  StoredProcedure [Foodshelf].[DeleteFoodshelfCertification]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Foodshelf].[DeleteFoodshelfCertification] @FoodshelfClientID INT, @FoodshelfCertificationID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Foodshelf.FoodshelfCertification WHERE @FoodshelfCertificationID = FoodshelfCertificationID AND @FoodshelfClientID = FoodshelfClientID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH
GO
/****** Object:  StoredProcedure [Foodshelf].[DeleteFoodshelfClient]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Foodshelf].[DeleteFoodshelfClient] @PersonID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Foodshelf.FoodshelfClient WHERE @PersonID = PersonID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH
GO
/****** Object:  StoredProcedure [Foodshelf].[DeleteHouseholdNotes]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Foodshelf].[DeleteHouseholdNotes] @HouseholdNotesID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Foodshelf.HouseholdNotes WHERE @HouseholdNotesID = HouseholdNotesID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH
GO
/****** Object:  StoredProcedure [Foodshelf].[InsertFoodDisbursements]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Foodshelf].[InsertFoodDisbursements] @PersonID INT, @FoodshelfClientID INT, @RecievedDate DATETIME, @FoodTypeID INT, @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
		
		IF @FoodshelfClientID IN(SELECT FoodshelfClientID FROM Foodshelf.FoodDisbursements WHERE @RecievedDate = ReceivedDate AND @FoodTypeID = FoodTypeID)
		BEGIN
			SELECT @ErrorMessage = 'Food Recieved already Recored';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO Foodshelf.FoodDisbursements	(PersonID, FoodshelfClientID, FoodDisbursementID, ReceivedDate, ModifiedDate, ModifiedBy)
										Values	(@PersonID, @FoodshelfClientID, @FoodTypeID, @RecievedDate, GETDATE(), @EditBy)
COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	THROW 5000001, @ErrorMessage, 1
END CATCH

GO
/****** Object:  StoredProcedure [Foodshelf].[InsertFoodshelfCertification]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Foodshelf].[InsertFoodshelfCertification] @PersonID INT, @FoodshelfClientID INT, @CertificationTextID INT = 1, @LastCertDate DATETIME,
														@IsPaperCert bit = NULL, @PaperCertDate DATETIME = NULL, @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT PersonID FROM FoodshelfCertification WHERE @PersonID = PersonID)
		BEGIN
			SELECT @ErrorMessage = 'Person Already Certified';
			THROW 5000001, @ErrorMessage, 1
		END
		
		INSERT INTO Foodshelf.FoodShelfCertification	(PersonID, FoodshelfClientID, CertificationTextID, LastCertificationDate, IsPaperCertification,
														PaperCertificationDate, ModifiedDate, ModifiedBy)
												VALUES	(@PersonID, @FoodShelfClientID, @CertificationTextID, @LastCertDate, @IsPaperCert,
														@PaperCertDate, GETDATE(), @EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Foodshelf].[InsertFoodshelfClient]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Foodshelf].[InsertFoodshelfClient] @PersonID INT, @HomeDelivery bit = 0, @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT PersonID FROM FoodshelfClient WHERE PersonID = @PersonID)
		BEGIN
			SELECT @ErrorMessage = 'Client ALready Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO Foodshelf.FoodshelfClient	(PersonID, HomeBoundDelivery, ModifiedDate, ModifiedBy)
										VALUES	(@PersonID, @HomeDelivery, GETDATE(), @EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Foodshelf].[InsertHouseholdNotes]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Foodshelf].[InsertHouseholdNotes] @PersonID INT, @HouseholdID INT, @FoodshelfClientID INT, @Notes VARCHAR(max), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT HouseholdID FROM Foodshelf.HouseholdNotes WHERE HouseHoldID = @HouseholdID AND @Notes = Notes)
		BEGIN
			SELECT @ErrorMessage = 'Notes Already Exist';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO Foodshelf.HouseholdNotes	(PersonID, FoodshelfClientID, HouseHoldID, Notes, ModifiedDate, ModifiedBy)
										VALUES	(@PersonID, @FoodshelfClientID, @HouseholdID, @Notes, GETDATE(), @EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH
GO
/****** Object:  StoredProcedure [Foodshelf].[InsertLUFoodType]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Foodshelf].[InsertLUFoodType] @Desc VARCHAR(50), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT FoodTypeDescription FROM LUFoodType WHERE @Desc = FoodTypeDescription)
		BEGIN
			SELECT @ErrorMessage = 'Food Exists';
			THROW 5000001, @ErrorMessage, 1
		END
		INSERT INTO [Foodshelf].[LUFoodType]
					(FoodTypeDescription,
					ModifiedDate,
					ModifiedBy)
				VALUES
				(@Desc,
				GETDATE(),
				@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[DeleteAddress]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create Procedure [Person].[DeleteAddress] @AddressToDeleteID INT, @PersonToDeleteID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Person.Address
			  WHERE @AddressToDeleteID = AddressID AND @PersonToDeleteID = PersonID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH

GO
/****** Object:  StoredProcedure [Person].[DeleteDemographics]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Person].[DeleteDemographics]	@PersonID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Person.Demographics WHERE @PersonID = PersonID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH

GO
/****** Object:  StoredProcedure [Person].[DeleteHousehold]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Procedure [Person].[DeleteHousehold] @PersonID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Person.Household WHERE PersonID = @PersonID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH
GO
/****** Object:  StoredProcedure [Person].[DeleteLanguagesSpoken]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Person].[DeleteLanguagesSpoken] @PersonID INT, @LanguageID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Person.LanguagesSpoken WHERE @PersonID = PersonID AND LanguageID = @LanguageID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH
GO
/****** Object:  StoredProcedure [Person].[DeletePersonType]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Person].[DeletePersonType] @PersonID INT, @PersonTypeID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Person.PersonType
			 WHERE
				   @PersonID = PersonID AND @PersonTypeID = PersonTypeID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

GO
/****** Object:  StoredProcedure [Person].[DeletePhone]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Person].[DeletePhone] @PersonID INT, @PhoneNumber VARCHAR(10)
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Person.Phone WHERE @PersonID = PersonID AND @PhoneNumber = PhoneNumber
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

GO
/****** Object:  StoredProcedure [Person].[DeleteProgramServiceUsed]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Person].[DeleteProgramServiceUsed] @PersonID INT, @ServiceID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Person.ProgramServicesUsed WHERE @PersonID = PersonID AND @ServiceID = ServiceID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[DeletPerson]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Person].[DeletPerson] @PersonID INT
AS
BEGIN TRY
	BEGIN TRAN
		UPDATE Person.Person SET IsDeleted = 1 WHERE PersonID = @PersonID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertAddress]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [Person].[InsertAddress] @PersonID INT, @AddressLine1 VARCHAR(60), @AddressLine2 VARCHAR(60) = NULL, @City VARCHAR(30),
	@County VARCHAR(30), @State VARCHAR(2), @PostalCode VARCHAR(10), @Type INT, @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT PersonID FROM Person.Address WHERE @PersonID = PersonID AND @AddressLine1 = AddressLine1)
		BEGIN
			SELECT @ErrorMessage = 'Address Exists';
			THROW 5000001, @ErrorMessage, 1
		END
		INSERT INTO [Person].[Address]
				   (PersonID,
					[AddressLine1]
				   ,[AddressLine2]
				   ,[City]
				   ,[County]
				   ,[State]
				   ,[PostalCode]
				   ,[AddressTypeID]
				   ,[ModifiedDate]
				   ,[ModifiedBy])
			 VALUES
				   (@PersonID
				   ,@AddressLine1
				   ,@AddressLine2
				   ,@City 
				   ,@County
				   ,@State
				   ,@PostalCode
				   ,@Type
				   ,GETDATE()
				   ,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertAddressType]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Person].[InsertAddressType] @Type VARCHAR(10), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT AddressTypeID FROM LUAddressType WHERE @Type = AddressType)
		BEGIN
			SELECT @ErrorMessage = 'Address Type Exists';
			THROW 5000001, @ErrorMessage, 1
		END


		INSERT INTO [Person].[LUAddressType]
				   ([AddressType]
				   ,[ModifiedDate]
				   ,[ModifiedBy]
				   ,[IsDeleted])
			 VALUES
				   (@Type
				   ,GETDATE()
				   ,@EditBy
				   ,0)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertDemographics]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Person].[InsertDemographics]	@PersonID INT, @EducationCategoryID INT, @HousingStatusID INT, @IncomeSourceID INT, @GenderID INT,
											@RaceID INT, @CountryOFOriginID INT, @EthnicityID INT, @Disability bit, @CSFP bit, @Veteran bit, 
											@InsuranceTypeID INT, @FoodStamps bit, @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN


		IF EXISTS(SELECT PersonID FROM Demographics WHERE PersonID = @PersonID)
		BEGIN
			SELECT @ErrorMessage = 'Demographic on File';
			THROW 5000001, @ErrorMessage, 1
		END
		INSERT INTO [Person].[Demographics]
									([PersonID],[EducationCategoryID],[HousingStatusID],[IncomeSourceID],[GenderID],
										[RaceID],[CountryOfOriginID],[EthnicityID],[Disability],[CSFP],[Veteran],[InsuranceTypeID],
										[FoodStamps],[ModifiedDate],[ModifiedBy])
								VALUES(@PersonID, @EducationCategoryID, @HousingStatusID, @IncomeSourceID, @GenderID, @RaceID,
										@CountryOFOriginID, @EthnicityID, @Disability, @CSFP, @Veteran, @InsuranceTypeID, @FoodStamps,GETDATE(), @EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertGenderType]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create Procedure [Person].[InsertGenderType] @Type VARCHAR(10), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT GenderID FROM LUGender WHERE GenderDescription = @Type)
		BEGIN
			SELECT @ErrorMessage = 'Housing Status Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [Person].[LUGender]
				   ([GenderDescription]
				   ,[DateModified]
				   ,[ModifiedBy])
			 VALUES
				   (@Type
				   ,GETDATE()
				   ,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertHousehold]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create Procedure [Person].[InsertHousehold] @PersonID INT, @HouseHoldID INT = NULL, @HouseHoldRelation INT, @EditBy VARCHAR(3), 
										@ErrorMessage VARCHAR(40) OUTPUT
AS

IF @HouseHoldID IS NULL
	SET @HouseHoldID = Person.FindCheckRelation(@PersonID, @HouseHoldRelation)

	Print @HouseHoldID

	Select @HouseHoldID AS ID

	DECLARE @startingTranCount int
	SET @startingTranCount = @@TRANCOUNT
	PRINT @startingTranCount

	

		
	BEGIN TRY

		--SAVE TRANSACTION SavePointRelation
		

		IF EXISTS(SELECT PersonID FROM Person.HouseHold WHERE PersonID = @PersonID AND @HouseHoldID = HouseHoldID)
		BEGIN
			SELECT @ErrorMessage = 'Person in Household';

			Print @ErrorMessage
		END

		IF @HouseHoldID = 0
		BEGIN
			SET @HouseHoldID = @PersonID + 100
			IF EXISTS(SELECT HouseholdID FROM Person.Household WHERE @HouseHoldID = HouseHoldID)
				SET @HouseHoldID = @HouseHoldID + 100
		END

		ELSE IF @HouseHoldID = -1
		BEGIN
			SELECT @ErrorMessage = 'Person in Household';

			Print @ErrorMessage;
			THROW 5000001, @ErrorMessage, 1;
		END

		ELSE IF @HouseHoldID = -2
		BEGIN
			SELECT @ErrorMessage = 'Person in Household';

			Print @ErrorMessage;
			THROW 5000001, @ErrorMessage, 1;
		END
		ELSE IF @HouseHoldID = -3
		BEGIN
			SELECT @ErrorMessage = 'Person in Household';

			Print @ErrorMessage;
			THROW 5000001, @ErrorMessage, 1;
		END

			INSERT INTO Person.Household	(PersonID, HouseHoldID, HouseHoldRelationID, ModifiedDate, ModifiedBy)
						VALUES	(@PersonID, @HouseHoldID, @HouseHoldRelation, GETDATE(), @EditBy)

	END TRY
	BEGIN CATCH


		THROW 5000001, @ErrorMessage, 1;
	END CATCH
GO
/****** Object:  StoredProcedure [Person].[InsertHouseHoldRelation]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Procedure [Person].[InsertHouseHoldRelation] @Type VARCHAR(25), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT HouseholdRelationID FROM LUHouseHoldRelation WHERE @Type = RelationshipDescription)
		BEGIN
			SELECT @ErrorMessage = 'Relationship Exists';
			THROW 5000001, @ErrorMessage, 1
		END
		INSERT INTO [Person].[LUHouseHoldRelation]
				   ([RelationshipDescription]
				   ,[ModifiedDate]
				   ,[ModifiedBy])
			 VALUES
				   (@Type
				   ,GETDATE()
				   ,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertLanguage]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Person].[InsertLanguage] @Name VARCHAR(25), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
	
		IF EXISTS(SELECT LanguageID FROM LULanguage WHERE @Name = LanguageName)
		BEGIN
			SELECT @ErrorMessage = 'Language Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [Person].[LULanguage]
				   ([LanguageName]
				   ,[ModifiedDate]
				   ,[ModifiedBy]
				   ,[IsDeleted])
			 VALUES
				   (@Name
				   ,GETDATE()
				   ,@EditBy
				   ,0)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertLanguagesSpoken]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Person].[InsertLanguagesSpoken] @LanguageID INT, @PersonID INT, @IsPrim bit = 0, @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
		
		IF EXISTS(SELECT PersonID FROM Person.LanguagesSpoken WHERE PersonID = @PersonID AND LanguageID = @LanguageID)
		BEGIN
			SELECT @ErrorMessage = 'Language Already Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO Person.LanguagesSpoken	(LanguageID, PersonID, IsPrimaryLanguage, ModifiedDate, ModifiedBy)
									VALUES	(@LanguageID, @PersonID, @IsPrim, GETDATE(), @EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertLUEducationCategory]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [Person].[InsertLUEducationCategory] @EducationLevel VARCHAR(50), @EditedBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
 AS
 BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT EducationLevel FROM LUEducationCategory WHERE @EducationLevel = EducationLevel)
		BEGIN
			SELECT @ErrorMessage = 'Type Already Entered';
			THROW 5000001, @ErrorMessage, 1
		END

		 INSERT INTO Person.LUEducationCategory
					(EducationLevel,
					ModifiedDate,
					ModifiedBy)
				VALUES
					(@EducationLevel,
					GETDATE(),
					@EditedBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertLUEthnicity]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Procedure [Person].[InsertLUEthnicity] @Desc VARCHAR(50), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT EthnicityID FROM LUEthnicity WHERE @Desc = EthnicityDescription)
		BEGIN
			SELECT @ErrorMessage = 'Ethnicity Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [Person].[LUEthnicity]
				   ([EthnicityDescription]
				   ,[ModifiedDate]
				   ,[ModifiedBy])
			 VALUES
				   (@Desc
				   ,GETDATE()
				   ,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertLUHousingStatus]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [Person].[InsertLUHousingStatus] @Status VARCHAR(50), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
 AS
 BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT HousingStatus FROM LUHousingStatus WHERE HousingStatus = @Status)
		BEGIN
			SELECT @ErrorMessage = 'Housing Status Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		 INSERT INTO Person.LUHousingStatus
				(HousingStatus,
				ModifiedDate,
				ModifiedBy)
			VALUES
				(@Status,
				GETDATE(),
				@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertLUIncomeSource]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create Procedure [Person].[InsertLUIncomeSource] @Type VARCHAR(25), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
	
		IF EXISTS(SELECT IncomeSourceID FROM LUIncomeSource WHERE IncomeSourceDescription = @Type)
		BEGIN
			SELECT @ErrorMessage = 'Housing Status Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [Person].[LUIncomeSource]
				   ([IncomeSourceDescription]
				   ,[ModifiedDate]
				   ,[ModifiedBy])
			 VALUES
				   (@Type
				   ,GETDATE()
				   ,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertLUInsuranceType]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Person].[InsertLUInsuranceType] @Type VARCHAR(50), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
	
		IF EXISTS(SELECT InsuranceTypeID FROM LUInsuranceType WHERE @Type = InsuranceType)
		BEGIN
			SELECT @ErrorMessage = 'Housing Status Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [Person].[LUInsuranceType]
				   ([InsuranceType]
				   ,[ModifiedDate]
				   ,[ModifiedBy])
			 VALUES
				   (@Type
				   ,GETDATE()
				   ,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertLUPersonType]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Person].[InsertLUPersonType]  @PersonType VARCHAR(50), @UserEdit VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
	
		IF EXISTS(SELECT PersonTypeID FROM LUPersonType WHERE @PersonType = PersonType)
		BEGIN
			SELECT @ErrorMessage = 'Housing Status Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO Person.LUPersonType(
				PersonType,
				[ModifiedDate],
				[ModifiedBy])
		VALUES
				(@PersonType, GETDATE(), @UserEdit)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertLUProgramType]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Person].[InsertLUProgramType] @Name VARCHAR(20), @Des VARCHAR(50), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
	
		IF EXISTS(SELECT ProgramTypeID FROM LUProgramType WHERE @Name = ProgramName)
		BEGIN
			SELECT @ErrorMessage = 'Housing Status Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO Person.LUProgramType
				   ([ProgramName],
					[ProgramDescription],
				   [ModifiedDate],
				   [ModifiedBy])
			 VALUES
				   (@Name
				   ,@Des
				   ,GETDATE()
				   ,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertLURace]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 CREATE PROCEDURE [Person].[InsertLURace] @Desc  VARCHAR(50), @EditBy  VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
 AS
 BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT RaceID FROM LURace WHERE @Desc = RaceDescription)
		BEGIN
			SELECT @ErrorMessage = 'Race Exists';
			THROW 5000001, @ErrorMessage, 1
		END
		INSERT INTO [Person].[LURace]
					([RaceDescription]
				   ,[ModifiedDate]
				   ,[ModifiedBy])
			 VALUES
				   (@Desc,
				   GETDATE(),
				   @EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertPerson]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Person].[InsertPerson]	@Title VARCHAR(8) = NULL, @FirstName dbo.Name, @MiddleName dbo.Name = NULL, @LastName dbo.Name, @Suffix VARCHAR(10) = NULL,
										@DateOfBirth DATE, @EmailAddress VARCHAR(50), @EmailPref bit = 1, @EditBy VARCHAR(3), @OutPersonID INT OUTPUT, @OutSucc BIT OUTPUT, @ErrorMessage VARCHAR(50) = '' OUTPUT
AS

SET @OutPersonID = 0

BEGIN TRY
	BEGIN TRANSACTION

		SELECT @OutPersonID = PersonID FROM Person.Person WHERE @FirstName = FirstName AND @LastName = LastName AND @EmailAddress = EmailAddress
		IF @OutPersonID <> 0
		BEGIN
			SELECT @ErrorMessage = 'Person Exists Already'
			SET @OutSucc = 0;
			Throw 50000, @ErrorMessage, 1;
		END

		IF CHARINDEX('@',@EmailAddress) = 0
		BEGIN
			SELECT @ErrorMessage = 'Incorrect Email'
			SET @OutSucc = 0;
			Throw 50000, @ErrorMessage, 1;
		END

		
		IF @@Error <> 0 
			BEGIN
				SELECT @ErrorMessage = CONVERT(nVarchar(50),@@ERROR) + '-1000';
				SET @OutSucc = 0;
				Throw 50000, @ErrorMessage, 1;
			END
		 

		INSERT INTO Person.Person	(Title, FirstName, MiddleName, LastName, Suffix, DateOfBirth, EmailAddress, 
									[EmailContactPreference], ModifiedDate, ModifiedBy, IsDeleted)
							Values	(@Title, @FirstName, @MiddleName, @LastName, @Suffix, @DateOfBirth, @EmailAddress, @EmailPref, GETDATE(), @EditBy, 0)

		SET @OutPersonID = @@IDENTITY
		SET @OutSucc = 1
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	
	PRINT 'In Person Catch'

	IF @@ERROR <> 50000
	BEGIN
		SELECT @ErrorMessage = @ErrorMessage + CONVERT(nVarchar(50), @@Error);
	END
		
	SET @OutSucc =0;
	SET @ErrorMessage=  @ErrorMessage;
	THROW 50000, @ErrorMessage, 1;
				  
END CATCH


GO
/****** Object:  StoredProcedure [Person].[InsertPersonType]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Person].[InsertPersonType] @PersonType INT, @Person INT, @UserEdit VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		IF NOT EXISTS(SELECT PersonTypeID FROM Person.LUPersonType)
		BEGIN
			SELECT @ErrorMessage = 'Not a Valid Person Type';
			THROW 50000001, @ErrorMessage, 1
		END

		IF EXISTS(SELECT PersonID FROM PersonType WHERE @Person = PersonID AND PersonType = @PersonType)
		BEGIN
			SELECT @ErrorMessage = 'Person Already Has Type';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO Person.PersonType(
					PersonID,
					PersonType,
					[ModifiedDate],
					[ModifiedBy])
			 VALUES
				   (@Person, @PersonType, GETDATE(), @UserEdit)
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertPhone]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Person].[InsertPhone] @PersonID INT, @PhoneNumber VARCHAR(10), @PhoneExtension VARCHAR(8) = NULL, @PhoneType INT, @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT PersonID FROM Person.Phone WHERE PersonID = @PersonID AND @PhoneNumber = PhoneNumber)
		BEGIN
			SELECT @ErrorMessage = 'Phone Already Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO Person.Phone	(PersonID, PhoneNumber, PhoneExtension, PhoneType, ModifiedDate, ModifiedBy)
							VALUES	(@PersonID, @PhoneNumber, @PhoneExtension, @PhoneType, GETDATE(), @EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertPhoneType]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Person].[InsertPhoneType] @Type VARCHAR(25), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
	
		IF EXISTS(SELECT PhoneTypeID FROM LUPhoneType WHERE @Type = PhoneType)
		BEGIN
			SELECT @ErrorMessage = 'Housing Status Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [Person].[LUPhoneType]
				   ([PhoneType]
				   ,[ModifiedDate]
				   ,[ModifiedBy])
			 VALUES
				   (@Type
				   ,GETDATE()
				   ,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Person].[InsertProgramServiceUsed]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Person].[InsertProgramServiceUsed] @PersonID INT, @ProgramTypeID INT, @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT PersonID FROM ProgramServicesUsed WHERE PersonID = @PersonID AND @ProgramTypeID = ProgramServiceID)
		BEGIN
			SELECT @ErrorMessage = 'ALready Resgistered For Program';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO Person.ProgramServicesUsed		(PersonID, ProgramServiceID, ModifiedDate, ModifiedBy)
											VALUES	(@PersonID, @ProgramTypeID, GETDATE(), @EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Signature].[DeleteSignature]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Signature].[DeleteSignature] @PersonID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM [Signature].[Signature] WHERE @PersonID = PersonID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH

GO
/****** Object:  StoredProcedure [Signature].[InsertSignature]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [Signature].[InsertSignature] @PersonID INT, @Sig VARCHAR(50), @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
 AS
 BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT PersonID FROM Signature.Signature WHERE PersonID = @PersonID)
		BEGIN
			SELECT @ErrorMessage = 'Signature Already On File';
			THROW 5000001, @ErrorMessage, 1
		END

		 INSERT INTO [Signature].[Signature]
						(PersonID,
						[Signature],
						ModifiedDate,
						ModifiedBy)
					VALUES
						(@PersonID,@Sig,GETDATE(),@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[CreateSchedule]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Volunteer].[CreateSchedule] @OrgID INT, @StartDate DATE, @EditBy VARCHAR(3), @ErrorMessage VARCHAR(50) OUTPUT
AS
BEGIN TRY
	BEGIN TRANSACTION
		
		IF EXISTS(SELECT OrganizationID FROM Volunteer.Schedule WHERE @StartDate = WeekStarting AND OrganizationID = @OrgID)
		BEGIN
			SELECT @ErrorMessage = 'Schedule Made for this organization';
			THROW 5000001, @ErrorMessage, 1
		END

		IF 1 <> DATEPART(DW, @StartDate)
		BEGIN
			SELECT @ErrorMessage = 'Start Date must be a Sunday';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO Volunteer.Schedule(
						OrganizationID,
						WeekStarting,
						WeekEnding,
						ModifiedDate,
						ModifiedBy)
			VALUES(@OrgID, @StartDate, DATEADD(day,6,@StartDate), GETDATE(), @EditBy)
		



		DECLARE @ScheduleID INT
		SET @ScheduleID = @@IDENTITY

			IF 0 = (SELECT o.SundayAM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET SundayAM = 'Closed' WHERE @OrgID = OrganizationID
			IF 0 = (SELECT o.SundayPM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET SundayPM = 'Closed' WHERE @OrgID = OrganizationID

			IF 0 = (SELECT o.MondayAM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET MondayAM = 'Closed' WHERE @OrgID = OrganizationID
			IF 0 = (SELECT o.MondayPM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET MondayPM = 'Closed' WHERE @OrgID = OrganizationID

			IF 0 = (SELECT o.TuesdayAM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET TuesdayAM = 'Closed' WHERE @OrgID = OrganizationID
			IF 0 = (SELECT o.TuesdayPM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET TuesdayPM = 'Closed' WHERE @OrgID = OrganizationID

			IF 0 = (SELECT o.WednesdayAM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET WednesdayAM = 'Closed' WHERE @OrgID = OrganizationID
			IF 0 = (SELECT o.WednesdayPM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET WednesdayPM = 'Closed' WHERE @OrgID = OrganizationID

			IF 0 = (SELECT o.ThursdayAM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET ThursdayAM = 'Closed' WHERE @OrgID = OrganizationID
			IF 0 = (SELECT o.ThursdayPM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET ThursdayPM = 'Closed' WHERE @OrgID = OrganizationID

			IF 0 = (SELECT o.FridayAM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET FridayAM = 'Closed' WHERE @OrgID = OrganizationID

			IF 0 = (SELECT o.FridayPM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET FridayPM = 'Closed' WHERE @OrgID = OrganizationID

			IF 0 = (SELECT o.SaturdayAM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET SaturdayAM = 'Closed' WHERE @OrgID = OrganizationID
			IF 0 = (SELECT o.SaturdayPM FROM dbo.OrganizationHours as o WHERE @OrgID = OrganizationID)
				UPDATE Volunteer.Schedule SET SaturdayPM = 'Closed' WHERE @OrgID = OrganizationID



	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 5000001, @ErrorMessage, 1
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[DeleteAddress]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Procedure [Volunteer].[DeleteAddress] @AddressID INT, @VolID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM [Volunteer].[Address]
			WHERE @AddressID = Volunteer.Address(AddressID) AND @VolID = Volunteer.Address(VolunteerID)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[DeleteAvailability]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Volunteer].[DeleteAvailability] @VolID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[DeleteDateRequest]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Volunteer].[DeleteDateRequest] @VolID INT, @Date Date
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM Volunteer.DateRequest WHERE @VolID = VolunteerID AND @Date = RequestedDate
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[DeleteJob]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Volunteer].[DeleteJob] @VolID INT, @JobID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM [Volunteer].[VolunteerJob]
			WHERE @VolID = [Volunteer].[VolunteerJob](VolunteerID) AND [Volunteer].[VolunteerJob](JobID) = @JobID
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[DeleteNote]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Volunteer].[DeleteNote] @VolID INT, @NoteID INT
AS
DELETE FROM [Volunteer].[VolunteerNotes]
      WHERE @VolID = [Volunteer].[VolunteerNotes](VolunteerID) AND [Volunteer].[VolunteerNotes](NoteID) = @NoteID

GO
/****** Object:  StoredProcedure [Volunteer].[DeletePhone]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Volunteer].[DeletePhone] @PhoneID INT, @VolID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM [Volunteer].[Phone]
			WHERE @PhoneID = Volunteer.Phone(PhoneID) AND @VolID = Volunteer.Phone(VolunteerID)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[DeleteVolunteer]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Volunteer].[DeleteVolunteer] @VolID INT
AS
BEGIN TRY
	BEGIN TRAN
		DELETE FROM [Volunteer].[Volunteer]
			  WHERE @VolID = Volunteer.Volunteer(VolunteerID)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[InsertAddress]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create Procedure [Volunteer].[InsertAddress] @VolID INT, @AddressLine1 VARCHAR(60), @AddressLine2 VARCHAR(60), @City VARCHAR(30),
	@County VARCHAR(30), @State VARCHAR(2), @PostalCode VARCHAR(10), @Type INT, @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRANSACTION

		IF EXISTS(SELECT VolunteerID FROM Volunteer.Address WHERE @VolID = VolunteerID AND @AddressLine1 = AddressLine1)
		BEGIN
			SELECT @ErrorMessage = 'Address exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [Volunteer].[Address]
				   ([VolunteerID]
				   ,[AddressLine1]
				   ,[AddressLine2]
				   ,[City]
				   ,[County]
				   ,[State]
				   ,[PostalCode]
				   ,[AddressTypeID]
				   ,[ModifiedDate]
				   ,[ModifiedBy])
			 VALUES
				   (@VolID
				   ,@AddressLine1
				   ,@AddressLine2
				   ,@City 
				   ,@County
				   ,@State
				   ,@PostalCode
				   ,@Type
				   ,GETDATE()
				   ,@EditBy)
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 5000002, @ErrorMessage, 1
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[InsertAvailability]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Volunteer].[InsertAvailability] @VolID INT,
	@SundayAM BIT = 0, @SundayPM BIT = 0,
	@MondayAM BIT = 0, @MondayPM BIT = 0,
	@TuesdayAM BIT = 0, @TuesdayPM BIT = 0,
	@WednesdayAM BIT = 0, @WednesdayPM BIT = 0,
	@ThursdayAM BIT = 0, @ThursdayPM BIT = 0,
	@FridayAM BIT = 0, @FridayPM BIT = 0,
	@SaturdayAM BIT = 0, @SaturdayPM BIT = 0,
	@ModifiedBy VARCHAR(3),  @ErrorMessage VARCHAR(50) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
		
		IF EXISTS(SELECT VolunteerID FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
		BEGIN
			SELECT @ErrorMessage = 'Volunteer already has availability set.';
			THROW 500000, @ErrorMessage, 1;
		END

		INSERT INTO Volunteer.VolunteerAvailability(
			VolunteerID,
			SundayAM, SundayPM,
			MondayAM, MondayPM,
			TuesdayAM, TuesdayPM,
			WednesdayAM, WednesdayPM,
			ThursdayAM, ThursdayPM,
			FridayAM, FridayPM,
			SaturdayAM, SaturdayPM,
			ModifiedDate, ModifiedBy)
		VALUES 	(@VolID,
			@SundayAM, @SundayPM,
			@MondayAM, @MondayPM,
			@TuesdayAM, @TuesdayPM,
			@WednesdayAM, @WednesdayPM,
			@ThursdayAM, @ThursdayPM,
			@FridayAM, @FridayPM,
			@SaturdayAM, @SaturdayPM,
			GETDATE(), @ModifiedBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	THROW 500001, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[InsertDateRequest]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Volunteer].[InsertDateRequest] @VolID INT, @DateRequested DATE, @ModifiedBy VARCHAR(3), @ErrorMessage VARCHAR(50) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
		IF EXISTS(SELECT VolunteerID FROM Volunteer.DateRequest WHERE @VolID = VolunteerID AND @DateRequested = RequestedDate)
		BEGIN
			SELECT @ErrorMessage = 'Volunteer Already requested date';
			THROW 5000001, @ErrorMessage, 1;
		END

		INSERT INTO Volunteer.DateRequest(VolunteerID, RequestedDate, ModifiedDate, ModifiedBy)
			VALUES(@VolID, @DateRequested, GETDATE(), @ModifiedBy)

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	THROW 5000001, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[InsertEmergencyContact]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Volunteer].[InsertEmergencyContact] @VolID INT,@FirstName VARCHAR(40), @LastName VARCHAR(40), @ContactRelationID INT, @PhoneNumber VARCHAR(10),@EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT ContactPhoneNumber FROM Volunteer.VolunteerEmergencyContact WHERE VolunteerID = @VolID AND @PhoneNumber = ContactPhoneNumber)
		BEGIN
			SELECT @ErrorMessage = 'Emergency Contact Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [Volunteer].[VolunteerEmergencyContact]
			([VolunteerID]
			,ContactFirstName
			,ContactLastName
			,ContactRelationID
			,[ContactPhoneNumber]
			,[ModifiedDate]
			,[ModifiedBy])
		VALUES
           (@VolID
		   ,@FirstName
		   ,@LastName
		   ,@ContactRelationID
           ,@PhoneNumber
           ,GETDATE()
           ,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[InsertJob]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Volunteer].[InsertJob] @VolID INT, @JobDescID INT,@EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT JobDescriptionID FROM Volunteer.VolunteerJob WHERE @VolID = VolunteerID AND JobDescriptionID = @JobDescID)
		BEGIN
			SELECT @ErrorMessage = 'Job Already Active';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [Volunteer].[VolunteerJob]
			([VolunteerID]
			,[JobDescriptionID]
			,[ModifiedDate]
			,[ModifiedBy])
		VALUES
			(@VolID
			,@JobDescID
			,GETDATE()
			,@EditBy)
	COMMIT TRAN;
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	THROW 500000, @ErrorMessage, 1;

END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[InsertLUVolunteerJobDescription]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Volunteer].[InsertLUVolunteerJobDescription] @OrgID INT, @Des VARCHAR(50), @ModifiedBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT VolunteerJobsID FROM LUVolunteerJobDescription WHERE @Des = JobDescription)
		BEGIN
			SELECT @ErrorMessage = 'Job Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [Volunteer].[LUVolunteerJobDescription]
				   ([OrganizationID]
				   ,[JobDescription]
				   ,[ModifiedDate]
				   ,[ModifiedBy])
			 VALUES
				   (@OrgID,
				   @Des,
				   GETDATE(),
				   @ModifiedBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[InsertNote]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Volunteer].[InsertNote] @VolID INT, @Note VARCHAR(MAX),@EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN

		IF EXISTS(SELECT VolunteerID FROM Volunteer.VolunteerNotes WHERE Note = @Note)
		BEGIN
			SELECT @ErrorMessage = 'Note Exists';
			THROW 5000001, @ErrorMessage, 1
		END
		INSERT INTO [Volunteer].[VolunteerNotes]
				   ([VolunteerID]
				   ,[Note]
				   ,[ModifiedDate]
				   ,[ModifiedBy])
			 VALUES
				   (@VolID
				   ,@Note
				   ,GETDATE()
				   ,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN;

	THROW 5000001, @ErrorMessage, 1
END CATCH
GO
/****** Object:  StoredProcedure [Volunteer].[InsertPhone]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Volunteer].[InsertPhone] @VolID INT,@PhoneNumber VARCHAR(10), @Type INT, @EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
		
		IF EXISTS(SELECT PhoneNumber FROM Volunteer.Phone WHERE PhoneNumber = @PhoneNumber)
		BEGIN
			SELECT @ErrorMessage = 'Phone Number Exists';
			THROW 5000001, @ErrorMessage, 1
		END

		INSERT INTO [Volunteer].[Phone]
			([VolunteerID]
			,[PhoneNumber]
			,[PhoneTypeID]
			,[ModifiedDate]
			,[ModifiedBy])
		VALUES
			(@VolID 
			,@PhoneNumber
			,@Type
			,GETDATE()
			,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH

GO
/****** Object:  StoredProcedure [Volunteer].[InsertVolunteer]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [Volunteer].[InsertVolunteer] @PersonID INT, @Email VARCHAR(50),@EditBy VARCHAR(3), @ErrorMessage VARCHAR(40) OUTPUT
AS
BEGIN TRY
	BEGIN TRAN
		
		IF @PersonID IN(Select PersonID FROM Volunteer.Volunteer)
		BEGIN
			SELECT @ErrorMessage = 'Volunteer Exits';
			THROW 5000001, @ErrorMessage, 1
		END


		INSERT INTO [Volunteer].[Volunteer]
				   ([PersonID]
				   ,[Email]
				   ,[IsActive]
				   ,[ModifiedDate]
				   ,[ModifiedBy])
			 VALUES
				   (@PersonID
				   ,@Email
				   ,1
				   ,GETDATE()
				   ,@EditBy)
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW 500000, @ErrorMessage, 1;
END CATCH
GO
/****** Object:  StoredProcedure [Volunteer].[InsertVolunteerIntoSchedule]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Volunteer].[InsertVolunteerIntoSchedule] @VolID INT, @ScheduleID INT
AS
BEGIN

DECLARE @StartDate DATE,
		@FullName VARCHAR(100)

SELECT @StartDate = WeekStarting FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID
SET @FullName = Volunteer.GetFullName(@VolID)

	IF (SELECT VolunteerID FROM Volunteer.DateRequest WHERE @VolID = VolunteerID AND RequestedDate = @StartDate) IS NULL
	BEGIN
		IF (SELECT SundayAM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID)  IS NULL
			IF 1 = (SELECT SundayAM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('SundayAM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET SundayAM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
		IF (SELECT SundayPM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT SundayPM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('SundayPM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET SundayPM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
	END


	IF (SELECT VolunteerID FROM Volunteer.DateRequest WHERE @VolID = VolunteerID AND RequestedDate = DATEADD(Day, 1, @StartDate)) IS NULL
	BEGIN
		IF (SELECT MondayAM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT MondayAM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('MondayAM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET MondayAM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
		IF (SELECT MondayPM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT MondayPM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('MondayPM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN	
						UPDATE Volunteer.Schedule SET MondayPM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
	END


	IF (SELECT VolunteerID FROM Volunteer.DateRequest WHERE @VolID = VolunteerID AND RequestedDate = DATEADD(Day, 2, @StartDate)) IS NULL
	BEGIN
		IF (SELECT TuesdayAM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT TuesdayAM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('TuesdayAM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET TuesdayAM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
		IF (SELECT TuesdayPM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT TuesdayPM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('TuesdayPM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN	
						UPDATE Volunteer.Schedule SET TuesdayPM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
	END



	IF (SELECT VolunteerID FROM Volunteer.DateRequest WHERE @VolID = VolunteerID AND RequestedDate = DATEADD(Day, 3, @StartDate)) IS NULL
	BEGIN
		IF (SELECT WednesdayAM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT WednesdayAM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('WednesdayAM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET WednesdayAM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
		IF (SELECT WednesdayPM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT WednesdayPM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('WednesdayPM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET WednesdayPM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
	END


	IF (SELECT VolunteerID FROM Volunteer.DateRequest WHERE @VolID = VolunteerID AND RequestedDate = DATEADD(Day, 4, @StartDate)) IS NULL
	BEGIN
		IF (SELECT ThursdayAM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT ThursdayAM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('ThursdayAM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET ThursdayAM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
		IF (SELECT ThursdayPM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT ThursdayPM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('ThursdayPM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET ThursdayPM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
	END

	IF (SELECT VolunteerID FROM Volunteer.DateRequest WHERE @VolID = VolunteerID AND RequestedDate = DATEADD(Day, 5, @StartDate)) IS NULL
	BEGIN
		IF (SELECT FridayAM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT FridayAM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('FridayAM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET FridayAM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
		IF (SELECT FridayPM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT FridayPM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('FridayPM ', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET FridayPM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
	END

	IF (SELECT VolunteerID FROM Volunteer.DateRequest WHERE @VolID = VolunteerID AND RequestedDate = DATEADD(Day, 6, @StartDate)) IS NULL
	BEGIN
		IF (SELECT SaturdayAM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT SaturdayAM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('SaturdayAM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET SaturdayAM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
		IF (SELECT SaturdayPM FROM Volunteer.Schedule WHERE @ScheduleID = ScheduleID) IS NULL
			IF 1 = (SELECT SaturdayPM FROM Volunteer.VolunteerAvailability WHERE @VolID = VolunteerID)
				IF 1 = Volunteer.CheckIfWorking('SaturdayPM', @FullName, @StartDate)
					IF 10 > (SELECT ShiftCount FROM CountTable WHERE @VolID = VolunteerID)
					BEGIN
						UPDATE Volunteer.Schedule SET SaturdayPM = @FullName WHERE @ScheduleID = ScheduleID
						UPDATE CountTable SET ShiftCount = ShiftCount + 1 WHERE @VolID = VolunteerID
					END
	END
END
GO
/****** Object:  StoredProcedure [Volunteer].[ScheduleAll]    Script Date: 2/23/2023 9:13:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Volunteer].[ScheduleAll] @CS_StartDate DATE
AS
BEGIN

	--General Declarations
	DECLARE	@CS_OrgID INT,
			@CS_ScheduleID INT,
			@CurrentRowNumber INT,

			@CS_VolID INT,
			@VolRowCount INT,
			@CS_Error VARCHAR(50)

	SET @CurrentRowNumber = 1

	--We will loop from row 1 to 5 which is the number of organizations.
	WHILE @CurrentRowNumber <= 5
	BEGIN
	
		--Sets the VolRowCount Variable used later in Script
		SET @VolRowCount = 1;


		--Create the CTE's To find out How many volunteers per organization. We start with the organizations that have the least.
		WITH NumberOfVolunteersPerJob
			AS(
				SELECT OrganizationID, COUNT(V.JobDescriptionID) AS NumberOfVolunteers FROM dbo.Organization
					INNER JOIN Volunteer.VolunteerJob AS V ON V.JobDescriptionID = OrganizationID
						GROUP BY OrganizationID),

			RowNumbers
			AS(
				SELECT OrganizationID, ROW_NUMBER() OVER(ORDER BY NumberOfVolunteers) AS RowNum FROM NumberOfVolunteersPerJob)
	



		--Gets the OrganizationID from the specific row.
		SELECT @CS_OrgID = OrganizationID FROM RowNumbers WHERE RowNum = @CurrentRowNumber




		--Generates the Empty Schedule
		EXEC Volunteer.CreateSchedule @OrgID=@CS_OrgID, @StartDate = @CS_StartDate, @EditBy = 'RMS', @ErrorMessage = @CS_Error OUTPUT;

		SET @CS_ScheduleID = @@IDENTITY



		--Loop through volunteers based on lowest number of shifts available for job.
		SET @CS_VolID = Volunteer.GetVolunteerIDFromRow(@CS_OrgID, @VolRowCount)

		WHILE @CS_VolID IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT VolunteerID FROM CountTable WHERE @CS_VolID = VolunteerID)
				INSERT INTO Volunteer.CountTable(VolunteerID, ShiftCount) VALUES (@CS_VolID, 0)

			EXEC Volunteer.InsertVolunteerIntoSchedule @VolID = @CS_VolID, @ScheduleID = @CS_ScheduleID

			SET @VolRowCount = @VolRowCount + 1
			SET @CS_VolID = Volunteer.GetVolunteerIDFromRow(@CS_OrgID, @VolRowCount)
		END

		SET @CurrentRowNumber = @CurrentRowNumber + 1
	END

	DELETE FROM Volunteer.CountTable
END

GO
USE [master]
GO
ALTER DATABASE [Champlain_Chartiy_LLC] SET  READ_WRITE 
GO
