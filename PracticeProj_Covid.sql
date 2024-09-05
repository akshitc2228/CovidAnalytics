alter table EmployeeDemographics ADD (
    Age INT,
    Gender VARCHAR(6)
);

select * from employeedemographics where rownum <= 5;

INSERT into EmployeeDemographics values (1001, 'Jim', 'Halpert', 30, 'Male');
INSERT into EmployeeDemographics values (1002, 'Pam', 'Beasley', 30, 'Female');
INSERT into EmployeeDemographics values (1003, 'Dwight', 'Schrute', 29, 'Male');
INSERT into EmployeeDemographics values (1004, 'Angela', 'Martin', 31, 'Female');
INSERT into EmployeeDemographics values (1005, 'Toby', 'Flenderson', 32, 'Male');
INSERT into EmployeeDemographics values (1006, 'Michael', 'Scott', 35, 'Male');
INSERT into EmployeeDemographics values (1007, 'Meredith', 'Palmer', 32, 'Female');
INSERT into EmployeeDemographics values (1008, 'Stanley', 'Hudson', 38, 'Male');
INSERT into EmployeeDemographics values (1009, 'Kevin', 'Malone', 31, 'Male');




select top(10) from employeedemographics;

CREATE TABLE CovidDeaths ( iso_code VARCHAR2(26),
  continent VARCHAR2(26),
  location VARCHAR2(50),
  collection_date DATE,
  population NUMBER(38),
  total_cases NUMBER(38),
  new_cases NUMBER(38),
  new_cases_smoothed NUMBER(38, 3),
  total_deaths NUMBER(38),
  new_deaths NUMBER(38),
  new_deaths_smoothed NUMBER(38, 3),
  total_cases_per_million NUMBER(38, 3),
  new_cases_per_million NUMBER(38, 3),
  new_cases_smoothed_per_million NUMBER(38, 3),
  total_deaths_per_million NUMBER(38, 3),
  new_deaths_per_million NUMBER(38, 3),
  new_deaths_smoothed_per_million NUMBER(38, 3),
  reproduction_rate NUMBER(38, 2),
  icu_patients NUMBER(12),
  icu_patients_per_million NUMBER,
  hosp_patients NUMBER(12),
  hosp_patients_per_million NUMBER,
  weekly_icu_admissions NUMBER(12),
  weekly_icu_admissions_per_million NUMBER,
  weekly_hosp_admissions NUMBER(12),
  weekly_hosp_admissions_per_million NUMBER(12)) ;
  
select * from coviddeaths;