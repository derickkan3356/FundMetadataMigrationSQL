-- core table

create table tblClient(
    ClientID int identity(1,1) primary key,
    ClientName varchar(255),
    MasterBU varchar(20) unique not null,
    FolderPath nvarchar(4000) check(FolderPath like 'P:\%')
);

create table tblSPV(
    SPVID int identity(1,1) primary key,
    SPVCode varchar(20) not null,
    SPVName varchar(255),
    ClientID int not null foreign key references tblClient(ClientID)
);

create table tblProject(
    ProjectID int identity(1,1) primary key,
    ProjectCode varchar(20) not null,
    ClientID int foreign key references tblClient(ClientID),
    InvestmentName varchar(255) not null,
    LegalName varchar(255),
    Industry varchar(255),
    [Location] varchar(255),
    TypeOfInvestment varchar(255),
    DateOfInitialInvestment datetime,
    DescriptionOfBusiness varchar(255),
    StageOfInitialInvestment varchar(255),
    PercentageOwnership float check(PercentageOwnership <= 1),
    FundBoardRepresentation varchar(255),
    IsBridge bit,
    Remarks varchar(255),
    constraint UQ_Project_Client unique(ProjectCode, ClientID)
);

create table tblFund(
    FundID int identity(1,1) primary key,
    FundCode varchar(20) unique not null,
    FundName varchar(255) not null,
    ClientID int not null foreign key references tblClient(ClientID),
    ClosingDate datetime,
    FinalClosingDate datetime,
    Term varchar(255),
    InceptionDate datetime,
    CommitmentPeriod varchar(255),
    FundDomicile varchar(255),
    LegalFormStructure varchar(255),
    InvestmentFocusGeography varchar(255)
);

create table tblAccountCode(
    AccountCodeID int identity(1,1) primary key,
    AccountCode varchar(20) not null,
    [Description] varchar(255)
);

create table tblCIGroupPercentage(
    CIGroupPercentageID int identity(1,1) primary key,
    CIGroupPercentageName varchar(6) not null unique
);

create table tblInvestor(
    InvestorID int identity(1,1) primary key,
    InvestorCode varchar(20) not null,
    InvestorName varchar(255) not null,
    InvestorType varchar(255) not null,
    CIGroupPercentageID int foreign key references tblCIGroupPercentage(CIGroupPercentageID),
);

-- analysis code table

create table tblInstruments(
    InstrumentsID int identity(1,1) primary key,
    InstrumentsCode varchar(20) unique not null,
    [Description] varchar(255)
);

create table tblSpare(
    SpareID int identity(1,1) primary key,
    SpareCode varchar(20) unique not null,
    [Description] varchar(255)
);

create table tblGSTCode(
    GSTCodeID int identity(1,1) primary key,
    GSTCode varchar(20) unique not null,
    [Description] varchar(255)
);

create table tblVendor(
    VendorID int identity(1,1) primary key,
    VendorCode varchar(20) unique not null,
    [Description] varchar(255)
);

create table tblUseOfFund(
    UseOfFundID int identity(1,1) primary key,
    UseOfFundCode varchar(20) unique not null,
    [Description] varchar(255)
);

create table tblProfitAllocation(
    ProfitAllocationID int identity(1,1) primary key,
    ProfitAllocationCode varchar(20) unique not null,
    [Description] varchar(255),
    ProfitBasis float
);

create table tblILPA(
    ILPAID int identity(1,1) primary key,
    ILPACode varchar(20) unique not null,
    [Description] varchar(255)
);

create table tblFundPerformance(
    FundPerformanceID int identity(1,1) primary key,
    FundPerformanceCode varchar(20) unique not null,
    [Description] varchar(255)
);

-- junction table

create table tblFundInvestor(
    FundID int foreign key references tblFund(FundID),
    InvestorID int foreign key references tblInvestor(InvestorID),
    primary key(FundID, InvestorID)
);

create table tblFundAccountCode(
    FundID int foreign key references tblFund(FundID),
    AccountCodeID int foreign key references tblAccountCode(AccountCodeID),
    primary key(FundID, AccountCodeID)
);

create table tblFundInstruments(
    FundID int foreign key references tblFund(FundID),
    InstrumentsID int foreign key references tblInstruments(InstrumentsID),
    primary key (FundID, InstrumentsID)
);

create table tblFundGSTCode(
    FundID int foreign key references tblFund(FundID),
    GSTCodeID int foreign key references tblGSTCode(GSTCodeID),
    primary key (FundID, GSTCodeID)
);

create table tblFundSpare(
    FundID int foreign key references tblFund(FundID),
    SpareID int foreign key references tblSpare(SpareID),
    primary key (FundID, SpareID)
);

create table tblFundVendor(
    FundID int foreign key references tblFund(FundID),
    VendorID int foreign key references tblVendor(VendorID),
    primary key (FundID, VendorID)
);

create table tblFundUseOfFund(
    FundID int foreign key references tblFund(FundID),
    UseOfFundID int foreign key references tblUseOfFund(UseOfFundID),
    primary key (FundID, UseOfFundID)
);

create table tblProfitAllocationMapping(
    AccountCodeID int foreign key references tblAccountCode(AccountCodeID),
    ProfitAllocationID int foreign key references tblProfitAllocation(ProfitAllocationID),
    primary key (AccountCodeID, ProfitAllocationID)
);

create table tblILPAMapping(
    AccountCodeID int foreign key references tblAccountCode(AccountCodeID),
    ILPAID int foreign key references tblILPA(ILPAID),
    primary key (AccountCodeID, ILPAID)
);

create table tblFundPerformanceMapping(
    AccountCodeID int foreign key references tblAccountCode(AccountCodeID),
    FundPerformanceID int foreign key references tblFundPerformance(FundPerformanceID),
    primary key (AccountCodeID, FundPerformanceID)
);

-- trigger

create trigger trg_ClientInvestorCodeUniqueness
on tblFundInvestor
after insert, update
as
begin
    -- if it is nested trigger, return nothing to prevent infinite loop
    if trigger_nestlevel() > 1 return;

    -- Check for duplicate investor code within the same client across all funds
    IF EXISTS (
        SELECT 1
        FROM inserted AS ins
        INNER JOIN tblFund AS insFund ON ins.FundID = insFund.FundID
        INNER JOIN tblInvestor AS insInvestor ON ins.InvestorID = insInvestor.InvestorID
        INNER JOIN tblFund AS existingFunds ON insFund.ClientID = existingFunds.ClientID
        INNER JOIN tblFundInvestor AS existingFI ON existingFunds.FundID = existingFI.FundID
        INNER JOIN tblInvestor AS existingInvestor ON existingFI.InvestorID = existingInvestor.InvestorID
        WHERE existingInvestor.InvestorCode = insInvestor.InvestorCode
        AND existingFI.InvestorID != ins.InvestorID -- Ensure not matching the same investor (for updates)
    )
    begin
        raiserror('Contain duplicate investor code within same client', 16, 1);
        rollback transaction;
    end
end;