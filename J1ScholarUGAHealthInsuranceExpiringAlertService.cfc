<cfcomponent extends="AbstractAlertService">

<!--- the logic of the alert is to assign, for the db query, anyone who has a bad date the date of 1800-01-01. Since the alert is for upcoming expiring dates, 1800-01-01 will not be on that list. --->

	<!--- Returns all meta information about that service object --->
	<cffunction name="getAlertType" access="public" returntype="AlertType">
		<cfscript>
			var alertType = createObject("component", "AlertType");
			alertType.serviceID = getImplementedServiceID();
			alertType.alertName = getServiceLabelType() & "J-1 Health Insurance Expiring";
			alertType.alertDescription = "INSTITUTION ISSUE: health insurance.   
										  <br><br>RESOLUTION: they need something on the custom table";
			alertType.levelDescription = "DANGER ZONE";	
			alertType.override = true;
		</cfscript>
		<cfreturn alertType>
	</cffunction>
		
	<!--- Returns query data for the implementing alert service. This is the population alerts will  
	be constructed on (see below for definition of required fields for this dataset). The query 
	should be defined to return values based on either the threat level btw 1-5 or an idnumber 
	(particular international record) that is greater than 0. --->
	<cffunction name="getQueryData" access="private" returntype="query">
		<cfargument name="threatLevel" type="numeric" required="true">
		<cfargument name="idnumber" type="numeric" required="true">			
		<cfquery name="dataset">
			<cfif getSunapsisEnvironment().getModule() eq "iom">
				SELECT DISTINCT jbInternational.idnumber, jbInternational.lastname, jbInternational.firstname, jbInternational.midname, 
				jbInternational.campus, jbInternational.universityid, jbInternational.sevisid, jbInternational.citizenship, 
				jbInternational.immigrationstatus, jcustom.expireDate
       
				FROM jbInternational WITH (nolock)
				inner join sevisDS2019Program as program on program.idnumber = jbInternational.idnumber
				<!---this is where I grab the custom table and its expiration dates--->
				inner join (
					select idnumber,
					<!---I deal with non-date data by using a case operation with the isdate function--->
					case when isdate(jbCustomFields1.customField18)=1 then cast(jbCustomFields1.customField18 as date) else '1800-01-01' end as expireDate 
					from jbCustomFields1
					<!---this is the part of the query that eliminates past custom table rows and keeps the most current expiration date--->
					where not exists (
					select 0 from jbCustomFields1 limiter
					where jbCustomFields1.idnumber=limiter.idnumber 
					AND jbCustomFields1.recnum < limiter.recnum))
				<!---I’m in essence creating a new pseudo table so I can access the jcustom.expireDate (see select above)--->
				as jcustom on jcustom.idnumber = jbInternational.idnumber
			</cfif>
			
			WHERE 
			
			<cfif threatLevel eq 0>
				jbCustomFields1.customField18 < '2016-03-01'
			<cfelseif threatLevel eq 1>
			<cfelseif threatLevel eq 2>
			<cfelseif threatLevel eq 3>					
			<cfelseif threatLevel eq 4>						
			<cfelseif threatLevel eq 5>
				<!---ds2019 status is A for 'Active' or V for 'Active (No Batch)'--->
				program.status in ('A')
				AND jbInternational.immigrationstatus in ('J1')
				AND expireDate < DATEADD(DAY,15,CURRENT_TIMESTAMP) AND expireDate NOT IN ('1800-01-01')
			<cfelse>AND jbInternational.idnumber = 0
			</cfif>
						
			<cfif idnumber gt 0>AND jbInternational.idnumber = <cfqueryparam cfsqltype="cf_sql_integer" value="#idnumber#"></cfif>

			AND jbInternational.idnumber NOT IN (SELECT idnumber
            									 FROM jbAlertsOverride WITH (nolock)
												 WHERE serviceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#getImplementedServiceID()#" />
                                                 AND (forever = 1 OR endDate > CURRENT_TIMESTAMP) )
				
			ORDER BY jbInternational.lastname, jbInternational.firstname, jbInternational.midname
		</cfquery>
		<cfreturn dataset>
	</cffunction>
	
	<!--- Returns a threat level based on a given row of the dataset (i.e. state of the rowset 
	at moment query is given to the method) the function will determine the threat level. This 
	is most useful on identifying differing threat levels for alerts queried by idnumber. --->	
	<cffunction name="getAlertDataThreatLevel" access="private" returntype="numeric">
		<cfargument name="dataset" type="query" required="true">
		<cfscript>
			var threatLevel = 5;
			


		</cfscript>
		<cfreturn threatLevel>
	</cffunction>
	
	<!--- Returns a message string based on a given row of the dataset (i.e. state of the rowset 
	at moment query is given to the method) the function will build an individualized alert message.  
	This provides a greater detail on the alert issue. --->		
	<cffunction name="getAlertDataMessage" access="private" returntype="string">
		<cfargument name="dataset" type="query" required="true">
		<cfscript>
			var alertMessage = "Expires on #dataset.expireDate#";
		</cfscript>
		<cfreturn alertMessage>
	</cffunction>

</cfcomponent>
