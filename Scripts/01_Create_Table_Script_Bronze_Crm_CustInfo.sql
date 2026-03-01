USE DataWareHouse
GO

/*
Developer		 : Ritesh Herkal
Developed on	 : 01-March-2026
				 
Script Purpose	 : Creation of table Crm_CustInfo
Script Objective : To store Data coming from one the CRM source Files
How to Run		 : Select * from Bronze.Crm_CustInfo

Revision History:
Developed By		Developed On			Description
Ritesh Herkal		01-March-2026			Initial Draft

*/

CREATE TABLE Bronze.Crm_CustInfo
(
	cst_id				INT,
	cst_key				NVARCHAR(50),
	cst_firstname		NVARCHAR(100),
	cst_lastname		NVARCHAR(100),
	cst_marital_status	NVARCHAR(10),
	cst_gndr			NVARCHAR(10),
	cst_create_date		DATE
);
GO
