
SELECT * FROM onyx_ap.healthcare;
--checking for distinct customer
SELECT
DISTINCT Gender 
FROM onyx_ap.healthcare;

--checking for distinct bloodtype: there are 8 bloodtypes
SELECT
DISTINCT BloodType
FROM onyx_ap.healthcare;

--checking for distinct medical condition
SELECT
DISTINCT MedicalCondition
FROM onyx_ap.healthcare;

--check if there is any null date
SELECT
*
FROM onyx_ap.healthcare
WHERE DateofAdmission IS NULL;

--find the max and min date 
SELECT
MIN(DateofAdmission),
MAX(DateofAdmission),
DATEDIFF(year, MIN(DateofAdmission), MAX(DateofAdmission)) AS date_diff
FROM onyx_ap.healthcare;

--check unique hospital and doctor
SELECT
DISTINCT Hospital
FROM onyx_ap.healthcare;

SELECT
DISTINCT Doctor
FROM onyx_ap.healthcare;

--check unique hospital and doctor
SELECT
DISTINCT InsuranceProvider
FROM onyx_ap.healthcare;

--check unique admission type, medication andd testresults
SELECT
DISTINCT AdmissionType
FROM onyx_ap.healthcare;

SELECT
DISTINCT Medication
FROM onyx_ap.healthcare;

SELECT
DISTINCT TestsResults
FROM onyx_ap.healthcare;

--number of doctor by hospital
SELECT
COUNT(Doctor) AS number_of_doc,
Hospital
FROM onyx_ap.healthcare
GROUP BY Hospital
ORDER BY number_of_doc DESC;

--bills covered by each insurance provider
SELECT
SUM(BillingAmount) total_bill_covered,
InsuranceProvider
FROM onyx_ap.healthcare
GROUP BY InsuranceProvider
ORDER BY total_bill_covered DESC;

--checking for most prescribed medication
SELECT
COUNT(Medication) AS num_of_times_prescribed,
Medication
FROM onyx_ap.healthcare
GROUP BY Medication
ORDER BY num_of_times_prescribed;



/*
SELECT
Gender,
COUNT(Gender) total_count
FROM onyx_ap.healthcare
GROUP BY Gender
ORDER BY total_count DESC;
*/

--1What are the most common age groups, genders, and blood types among patients? Are certain groups being admitted more often than others?
SELECT
age_group,
Gender,
BloodType,
AdmissionType,
--ROW_NUMBER() OVER(PARTITION BY age_group ORDER BY COUNT(*) DESC),
COUNT(*) AS total_count
FROM
(
SELECT 
CASE
	WHEN AGE BETWEEN 13 AND 19 THEN 'Teen'
	WHEN Age BETWEEN 20 AND 35 THEN 'Young Adult'
	WHEN Age BETWEEN 36 AND 55 THEN 'Middled Aged'
	WHEN Age BETWEEN 56 AND 75 THEN 'Senior'
	ELSE 'Elder'
END AS age_group,
BloodType,
AdmissionType,
Gender
FROM onyx_ap.healthcare
)t
GROUP BY age_group,
Gender,
BloodType,
AdmissionType
ORDER BY total_count Desc;

--2.Which medical conditions are diagnosed the most, and do they affect certain groups of people more than others?
SELECT
age_group,
MedicalCondition,
COUNT(*) AS total_count
FROM 
(
SELECT
CASE
	WHEN AGE BETWEEN 13 AND 19 THEN 'Teen'
	WHEN Age BETWEEN 20 AND 35 THEN 'Young Adult'
	WHEN Age BETWEEN 36 AND 55 THEN 'Middled Aged'
	WHEN Age BETWEEN 56 AND 75 THEN 'Senior'
	ELSE 'Elder'
END AS age_group,
MedicalCondition
FROM onyx_ap.healthcare
)t
GROUP BY age_group,MedicalCondition
ORDER BY age_group, total_count DESC;

--3.How long do patients typically stay in the hospital for different conditions? 
--Does this vary depending on the hospital or type of admission (emergency, urgent, or planned)?
SELECT 
MedicalCondition,
Hospital,
AdmissionType,
ROUND(AVG(DATEDIFF(day, DateofAdmission, DischargeDate)), 2) AS AvgLengthOfStay
FROM onyx_ap.healthcare
GROUP BY 
MedicalCondition,
Hospital,
AdmissionType
ORDER BY Hospital, AvgLengthOfStay DESC;

--4.How much does treatment usually cost for each condition? Are there big differences in costs between hospitals or insurance providers?
--cost for one condition
SELECT
MedicalCondition,
ROUND(AVG(BillingAmount), 2) AS total_amount
FROM onyx_ap.healthcare
GROUP BY
MedicalCondition
ORDER BY total_amount DESC;

SELECT
MedicalCondition,
Hospital,
InsuranceProvider,
AVG(BillingAmount) AS avg_cost
FROM onyx_ap.healthcare
GROUP BY
MedicalCondition,
Hospital,
InsuranceProvider
ORDER BY Hospital, avg_cost DESC;

--5.Which hospitals are treating the most patients, and how do they compare in terms of patient outcomes, like test results?
SELECT
Hospital,
TestsResults,
COUNT(*) total_count
FROM onyx_ap.healthcare
GROUP BY Hospital, TestsResults
ORDER BY TestsResults, total_count DESC;

--6.What medications are most often prescribed for each condition? Are they being used consistently across hospitals?
SELECT
*
FROM
(
SELECT
MedicalCondition,
Medication,
COUNT(Medication) AS total_count,
ROW_NUMBER() OVER(PARTITION BY MedicalCondition ORDER BY COUNT(Medication) DESC) AS rank_med
--Hospital
FROM onyx_ap.healthcare
GROUP BY 
MedicalCondition,
Medication
)t
WHERE rank_med = 1
ORDER BY total_count DESC;

--Are they being used consistently across hospitals?
SELECT
*
FROM 
(
SELECT
MedicalCondition,
Medication,
Hospital,
COUNT(Medication) AS total_count,
ROW_NUMBER() OVER(PARTITION BY MedicalCondition, Hospital ORDER BY COUNT(Medication) DESC) AS rank_med
FROM onyx_ap.healthcare
GROUP BY 
MedicalCondition,
Hospital,
Medication
)t
WHERE rank_med = 1
ORDER BY MedicalCondition, total_count DESC;

--7.How are patients admitted - mostly through emergency, urgent, or planned admissions - and how does that impact the length of stay or treatment costs?
SELECT
AdmissionType,
--DateofAdmission,
--DischargeDate,
SUM(BillingAmount) AS total_cost,
AVG(DATEDIFF(day, DateofAdmission, DischargeDate)) AS avg_days,
COUNT(*) AS total_count
FROM onyx_ap.healthcare
GROUP BY AdmissionType
ORDER BY total_cost DESC;

--8.Which insurance companies are covering the most patients, and how does that relate to treatment costs and patient outcomes?
SELECT
InsuranceProvider,
TestsResults,
SUM(BillingAmount) AS treatment_cost,
COUNT(*) OVER(PARTITION BY InsuranceProvider, TestsResults)
--COUNT(*) AS total_count
FROM onyx_ap.healthcare
GROUP BY InsuranceProvider, TestsResults
ORDER BY treatment_cost DESC;

--9.Where are the hospitals located, and are there any regional differences in health conditions, treatment quality, or billing amounts?
SELECT
Hospital,
HospitalLatitude,
HospitalLongitude,
MedicalCondition,
TestsResults,
COUNT(*) AS total_count,
AVG(BillingAmount) AS avg_cost
FROM onyx_ap.healthcare
GROUP BY 
Hospital,
HospitalLatitude,
HospitalLongitude,
MedicalCondition,
TestsResults
ORDER BY HospitalLatitude,HospitalLongitude DESC;