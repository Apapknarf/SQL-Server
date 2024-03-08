'--Identify hardcoded references in jobs
SELECT Job.name AS JobName
	,JobStep.step_name AS JobStepName
	,JOB.DESCRIPTION
	,JOBSTEP.database_name
	,REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(JOBSTEP.COMMAND)), CHAR(9), ' '), CHAR(10), ' '), CHAR(13), ' '), '[', ''), ']', ''), ';', '') as COMMAND	
 FROM msdb..sysjobs Job
	INNER JOIN msdb..sysjobsteps JobStep ON Job.job_id = JobStep.job_id 
WHERE  JOB.Category_ID <> 100
	AND Job.enabled  = 1
	AND JOBSTEP.subsystem = 'TSQL'
	AND JOBSTEP.COMMAND LIKE '%'+@@SERVERNAME+'%'
