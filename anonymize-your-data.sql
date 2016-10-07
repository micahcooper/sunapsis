--This SQL file performs a number of step to remove identifying information from the staging database.

USE [InternationalServices-staging]

/****** SET DB TO DEVELOPMENT AND RENAME ******/
UPDATE dbo.configSunapsisEnvironment SET instance = 'dev'
UPDATE dbo.IStartGeneralSetup SET istartName='iTEST'

/****** CHANGE ENCRYPTION  ******/
UPDATE dbo.configEncryption SET encrypt=0, status='D'

/****** CHANGE THE BATCH ID TO STAGING INFO  ******/
UPDATE dbo.configBatchID SET systemValue='staging123'

/****** CHANGE LOGOUT URL  ******/
UPDATE dbo.IStartGeneralSetup SET logoutURL='https://your.logout.url'

/****** Clear notes ******/
UPDATE [dbo].[jbNotes] SET notes='This is a note from the past.  Thank you for looking.'
UPDATE [dbo].[jbInternationalBioExt] SET dob='1990-01-01 00:00:00.000'
UPDATE [dbo].[jbAddress] SET street1='a street',phone='5555555555'

/****** Change RTI links to sbtsevis ******/
UPDATE dbo.configRTILaunchPage SET systemValue='https://egov.ice.gov/sbtsevis'
UPDATE dbo.configRTIMainPageReferrer SET systemValue='https://egov.ice.gov/sbtsevis/action/common/MainPageData'

/******update staging database with a standard email address and blank network id******/
UPDATE [dbo].[jbCommunication] SET universityEmail='account@gmail.com', otherEmail='account+otheremail@gmail.com'
UPDATE [dbo].[codeAlertGroups] SET email='account+alertgroups@gmail.com'
UPDATE [dbo].[iuieBio] SET PRSN_OTHR_EMAIL_ID = 'account+iuieBio-OtherEmail@gmail.com', PRSN_GDS_CMP_EMAIL_ADDR = 'account+iuieBio-campus-email@gmail.com'
UPDATE [dbo].[configOpenDoorsCampusDetails] SET email = 'uga.oie+opendoors@gmail.com'
UPDATE [dbo].[configEmailAutoAlert] SET sender='account+emailautoalert@gmail.com'
UPDATE [dbo].[IStartEFormEmails] SET sender='account+eformemails@gmail.com', ccEmails = 'account+eform-cc-email@gmail.com'
UPDATE [dbo].[IStartEFormEmailsDefault] SET ccEmails = 'account+IStartEFormEmailsDefault-ccemail@gmail.com'
UPDATE [dbo].[IStartCampus] SET campusEmail='account+campus@gmail.com',orientationEmail='account+orientation@gmail.com',admissionEmail='account+admission@gmail.com'
UPDATE [dbo].[iuieEmployee] SET PRSN_CMP_EMAIL_ADDR = 'account+iuieEmp-campus-email@gmail.com'
UPDATE [dbo].[jbContact] SET email = 'account+jbContact@gmail.com'
UPDATE [dbo].[jbDependent] SET email = 'account+jbdependent@gmail.com'
UPDATE [dbo].[jbOrientationCheckin] set relative1Email = 'account+jbOrientation-rel1@gmail.com', relative2Email = 'account+jbOrientation-rel2@gmail.com'
UPDATE [dbo].[jbSponsoredStudentInformation] SET advisorEmail = 'account+jbSponsoredStudent-advisor@gmail.com'
UPDATE [dbo].[sevisDS2019AcademicTraining] SET supervisorEmail = 'account+acadtrainig-superviser@gmail.com'
UPDATE [dbo].[IStartDepartmentRequester] set universityEmail = 'account+departmentRequestor@gmail.com'

/****** blank out network ids ******/
UPDATE [dbo].[jbInternational] SET networkid=''
UPDATE [dbo].[iuieBio] SET PRSN_NTWRK_ID = ''

/****** Clean the create sevis batch table  ******/
truncate table [InternationalServices-itest].[dbo].[sevisCreateBatch]

/****** Clean session ids from the table  ******/
update [InternationalServices-itest].[dbo].[IOfficeUsers] set sessionid = ''

/****** SET THE APPROPRIATE DB USER PERMISSIONS  ******/
CREATE USER [InternationalServices-User-itest] FOR LOGIN [InternationalServices-User-staging]
EXEC sp_addrolemember N'db_datareader', N'InternationalServices-User-staging'
EXEC sp_addrolemember N'db_datawriter', N'InternationalServices-User-staging'
EXEC sp_addrolemember N'db_ddladmin', N'InternationalServices-User-staging'

/****** ADD STORED PROCEDURE EXECUTE PERMISSIONS FOR DB USER (NOT LOGIN)  ******/
--dataFeedCore, dataFeedCoreChecklist, dataFeedReindex, fnGetEFormFieldValue, spChecklistDepartmentReport, spCreateEFormGroup, spCreateEformGroupChecklist, spGeneratePIN,
--SUNAPSIS: dataFeeCore,dataFeedCoreChecklist,dataFeedReindex,spCreateEFormGroup,spGeneratePIN
