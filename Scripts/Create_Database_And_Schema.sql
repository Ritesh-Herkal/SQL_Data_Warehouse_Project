/*

===================================================================================
Create DataBase and Schema
===================================================================================

Developer		: Ritesh Herkal
Developed on	: 01-March-2026

Script Purpose :
	This script creats a new Database names 'DataWareHouse' after checking if it exists.
	If the database exists, it is dropped and recreated.
	Additionally, the script creates 3 schemas i.e. Bronze, Silver and Gold.
	This project follows Medallion Datawarehouse Architecture.

WARNING : 
	Running this script will drop the entire 'DataWareHouse' database. 
	Please take the required Backups if required any.

*/


USE master;
GO

--Drop and Recreate Database if exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE NAME = 'DataWareHouse')
BEGIN
	DROP DATABASE DataWareHouse
END;
GO

--Create a New Database, 'DataWareHouse'
CREATE DATABASE DataWareHouse;
GO

Use DataWareHouse
GO

--Create the Medillion Architecture Schema
--Bronze
CREATE SCHEMA Bronze
GO

--Silver
CREATE SCHEMA Silver
GO

--Gold
CREATE SCHEMA Gold
GO