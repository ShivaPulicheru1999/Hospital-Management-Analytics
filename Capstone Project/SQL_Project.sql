CREATE TABLE Patients (
 PatientID INT AUTO_INCREMENT PRIMARY KEY,
 Name VARCHAR(100) NOT NULL, 
Age INT NOT NULL, 
Gender ENUM('Male', 'Female', 'Other') NOT NULL,
 Address VARCHAR(255), 
PhoneNumber VARCHAR(15), 
DateOfRegistration DATE NOT NULL
);


CREATE TABLE Doctors ( 
DoctorID INT AUTO_INCREMENT PRIMARY KEY, 
Name VARCHAR(100) NOT NULL,
 Specialty VARCHAR(50) NOT NULL, 
Experience INT NOT NULL, 
PhoneNumber VARCHAR(15) UNIQUE
 ); 

CREATE TABLE Appointments (
 AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
 PatientID INT,
 DoctorID INT,
 AppointmentDate DATE NOT NULL, 
AppointmentTime TIME NOT NULL, 
Status ENUM('Completed', 'Cancelled') DEFAULT 'Completed',
 FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
 FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) 
);

CREATE TABLE Treatments ( 
TreatmentID INT AUTO_INCREMENT PRIMARY KEY, 
PatientID INT, DoctorID INT, 
Diagnosis VARCHAR(255), 
Prescription TEXT, 
TreatmentDate DATE NOT NULL,
 FOREIGN KEY (PatientID) REFERENCES Patients(PatientID), 
FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) 
); 

CREATE TABLE Billing ( 
BillID INT AUTO_INCREMENT PRIMARY KEY, 
PatientID INT, 
TreatmentID INT,
 Amount DECIMAL(10, 2) NOT NULL, 
PaymentStatus ENUM('Paid', 'Pending') DEFAULT 'Pending',
 PaymentDate DATE, 
FOREIGN KEY (PatientID) REFERENCES Patients(PatientID), 
FOREIGN KEY (TreatmentID) REFERENCES Treatments(TreatmentID)
 );
 
 *To generate 200 rows for each table, you can use MySQL Stored Procedures. Follow these steps:


DELIMITER $$

CREATE PROCEDURE PopulatePatients()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 200 DO
        INSERT INTO Patients (Name, Age, Gender, Address, PhoneNumber, DateOfRegistration)
        VALUES (
            CONCAT('Patient_', i),
            FLOOR(18 + (RAND() * 70)), -- Random age between 18 and 87
            IF(i % 2 = 0, 'Male', 'Female'),
            CONCAT('Address_', i),
            CONCAT('98765', LPAD(i, 5, '0')), -- Generates unique phone numbers
            CURDATE() - INTERVAL FLOOR(RAND() * 365) DAY
        );
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Execute the procedure
CALL PopulatePatients();
select * from Patients;

—----------------------

DELIMITER $$

CREATE PROCEDURE PopulateDoctors()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE specialties VARCHAR(255);
    SET specialties = 'Cardiologist,Dermatologist,Orthopedic,Neurologist,Pediatrician';
    
    WHILE i <= 30 DO
        INSERT INTO Doctors (Name, Specialty, Experience, PhoneNumber)
        VALUES (
            CONCAT('Doctor_', i),
            ELT(FLOOR(1 + (RAND() * 5)), 'Cardiologist', 'Dermatologist', 'Orthopedic', 'Neurologist', 'Pediatrician'),
            FLOOR(5 + (RAND() * 30)), -- Random experience between 5 and 34 years
            CONCAT('98760', LPAD(i, 5, '0')) -- Generates unique phone numbers
        );
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Execute the procedure
CALL PopulateDoctors();
select * from Doctors;

—----------------------
DELIMITER $$

CREATE PROCEDURE PopulateAppointments()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 200 DO
        INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, AppointmentTime, Status)
        VALUES (
            FLOOR(1 + (RAND() * 200)), -- Random PatientID
            FLOOR(1 + (RAND() * 30)), -- Random DoctorID
            CURDATE() - INTERVAL FLOOR(RAND() * 180) DAY, -- Random date in the past 6 months
            TIME(FROM_UNIXTIME(FLOOR(RAND() * 86400))), -- Random time
            IF(RAND() < 0.8, 'Completed', 'Cancelled') -- 80% chance for "Completed"
        );
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Execute the procedure
CALL PopulateAppointments();
select * from Appointments;

—-----------------------------

DELIMITER $$

CREATE PROCEDURE PopulateTreatments()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 200 DO
        INSERT INTO Treatments (PatientID, DoctorID, Diagnosis, Prescription, TreatmentDate)
        VALUES (
            FLOOR(1 + (RAND() * 200)), -- Random PatientID
            FLOOR(1 + (RAND() * 30)), -- Random DoctorID
            CONCAT('Diagnosis_', FLOOR(RAND() * 100)),
            CONCAT('Prescription_', FLOOR(RAND() * 100)),
            CURDATE() - INTERVAL FLOOR(RAND() * 180) DAY
        );
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Execute the procedure
CALL PopulateTreatments();
select * from Treatments;


—--------------------------

DELIMITER $$

CREATE PROCEDURE PopulateBilling()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 200 DO
        INSERT INTO Billing (PatientID, TreatmentID, Amount, PaymentStatus, PaymentDate)
        VALUES (
            FLOOR(1 + (RAND() * 200)), -- Random PatientID
            FLOOR(1 + (RAND() * 200)), -- Random TreatmentID
            ROUND(RAND() * 950 + 50, 2), -- Random amount between 50 and 1000
            IF(RAND() < 0.7, 'Paid', 'Pending'), -- 70% chance for "Paid"
            IF(RAND() < 0.7, CURDATE() - INTERVAL FLOOR(RAND() * 180) DAY, NULL)
        );
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

-- Execute the procedure
CALL PopulateBilling();
select * from Billing;


------------------------ QUERIES

-- 1.Fetch all patient details who registered in the last 30 days.

SELECT 
    *
FROM
    patients
WHERE
    DateOfRegistration >= CURDATE() - INTERVAL 30 DAY;

-- 2.List all appointments for a specific doctor in a given date range

SELECT 
    *
FROM
    Appointments a
        JOIN
    Doctors d ON a.DoctorID = d.DoctorID
WHERE
    d.Name = 'Doctor_1'
        AND a.AppointmentDate BETWEEN '2024-10-01' AND '2024-11-30';
    
-- 3.Identify the doctor with the most appointments in the last month.

SELECT 
    Name, COUNT(a.AppointmentID) AS Appointment_Count
FROM
    Doctors d
        JOIN
    Appointments a ON d.DoctorID = a.DoctorID
WHERE
    a.AppointmentDate BETWEEN '2024-11-01' AND '2024-11-30'
GROUP BY d.doctorID
ORDER BY Appointment_Count DESC;

-- 4.Calculate the total revenue generated by the hospital in the last quarter.
select * from billing;

SELECT 
    SUM(Amount) AS Total_Revenue
FROM
    billing
WHERE
    PaymentDate BETWEEN '2024-07-01' AND '2024-09-30'
        AND PaymentStatus = 'Paid';

-- 5.Find patients who have missed or cancelled more than 1 appointments.

SELECT 
    Name, COUNT(Status) AS CanceledCount
FROM
    patients p
        JOIN
    appointments a ON p.PatientID = a.PatientID
WHERE
    a.Status = 'Cancelled'
GROUP BY a.PatientID
HAVING COUNT(Status) > 1;

-- 6.Determine the most common diagnosis provided by each doctor.

SELECT 
    DoctorID, Diagnosis, COUNT(Diagnosis)
FROM
    treatments t
GROUP BY DoctorID , Diagnosis
HAVING COUNT(Diagnosis) = (SELECT 
        MAX(DiagnosisCount)
    FROM
        (SELECT 
            DoctorID, Diagnosis, COUNT(Diagnosis) AS DiagnosisCount
        FROM
            treatments
        GROUP BY DoctorID , Diagnosis) AS SubQuery
    WHERE
        Subquery.DoctorID = t.DoctorID)
ORDER BY DoctorID;


-- 7. Generate a monthly revenue breakdown by doctor specialty.
SELECT 
    d.Specialty,
    YEAR(b.PaymentDate) AS Year,
    MONTH(b.PaymentDate) AS Month,
    SUM(b.Amount) AS MonthlyRevenue
FROM
    Billing b
        JOIN
    Treatments t ON b.TreatmentID = t.TreatmentID
        JOIN
    Doctors d ON t.DoctorID = d.DoctorID
WHERE
    b.PaymentStatus = 'Paid'
GROUP BY d.Specialty , YEAR(b.PaymentDate) , MONTH(b.PaymentDate)
ORDER BY Year DESC , Month DESC , d.Specialty;
    
-- 8.Analyze peak hours for appointments and suggest time slots for more efficient scheduling.

SELECT 
    Hours, No_Of_Appointments
FROM
    (SELECT 
        HOUR(AppointmentTime) AS Hours,
            COUNT(*) AS No_Of_Appointments
    FROM
        appointments
    GROUP BY HOUR(AppointmentTime)) AS subquery
WHERE
    No_Of_Appointments = (SELECT 
            MAX(No_Of_Appointments)
        FROM
            (SELECT 
                COUNT(*) AS No_Of_Appointments
            FROM
                Appointments
            GROUP BY HOUR(AppointmentTime)) AS inner_Query);
 
 -- END
 
 -- DESCRIPTIVE ANALYSIS
 -- 1. A Total of 20 PATIENTS REGISTERED IN THE LAST 30 DAYS.alter.
 -- 2. A TOTAL 3 APPONITMENTS HAD REGISTERED FOR DOCTOR_1 IN BETWEEN '2024-10-01' AND '2024-11-30'.
 -- 3. DOCTOR_29 HAVE THE MAX [5] OF APPOINTMENTS IN THE LAST MONTH.
 -- 4. A REVENUE OF ₹29462.92 WAS GENERATED IN THE LAST QUARTER.
 -- 5. OVERALL 5 PATIENTS CANCELLED THEIR APPOINTMENTS MORE THAN 1 TIME.
 -- 6. DIAGNOSIS_75,67,72,7,84 ARE MOSTLY USED BY DOCTORS.
 -- 7. 2PM AND 3PM HAVE MORE APPOINTMENTS COMPARING TO OTHER TIMINGS.

