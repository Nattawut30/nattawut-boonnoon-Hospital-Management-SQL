-- ========================================
-- HOSPITAL MANAGEMENT SYSTEM
-- LinkedIn: www.linkedin.com/in/nattawut-bn
-- GitHub: @Nattawut30
-- Email: nattawut.boonnoon@hotmail.com
-- Database Setup & Validation
-- ========================================

-- ========================================
-- QUERY 1: Create Database & All Tables
-- ========================================
-- PURPOSE: Initialize complete hospital database with normalized structure
-- CREATES: 13 interconnected tables for patient care, operations, and billing

DROP DATABASE IF EXISTS hospital_management;
CREATE DATABASE hospital_management;
USE hospital_management;

-- Departments
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    building VARCHAR(50),
    floor INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Insurance Providers
CREATE TABLE insurance_providers (
    provider_id INT PRIMARY KEY AUTO_INCREMENT,
    provider_name VARCHAR(100) NOT NULL UNIQUE,
    contact_phone VARCHAR(20),
    email VARCHAR(100),
    coverage_type ENUM('HMO', 'PPO', 'EPO', 'Medicaid', 'Medicare') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Patients
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    blood_type ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(2),
    zip_code VARCHAR(10),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    insurance_provider_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (insurance_provider_id) REFERENCES insurance_providers(provider_id)
) ENGINE=InnoDB;

-- Staff
CREATE TABLE staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('Doctor', 'Nurse', 'Administrative Staff', 'Technician') NOT NULL,
    department_id INT NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
) ENGINE=InnoDB;

-- Appointment Types
CREATE TABLE appointment_types (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    typical_duration_minutes INT NOT NULL,
    base_cost DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Appointments
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    staff_id INT NOT NULL,
    department_id INT NOT NULL,
    appointment_type_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status ENUM('Scheduled', 'Completed', 'Cancelled', 'No-Show') DEFAULT 'Scheduled',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (appointment_type_id) REFERENCES appointment_types(type_id)
) ENGINE=InnoDB;

-- ***** Medical History *****
CREATE TABLE medical_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    medical_condition VARCHAR(200) NOT NULL,
    diagnosed_date DATE,
    status ENUM('Active Treatment', 'Chronic', 'Resolved', 'Healthy') DEFAULT 'Active Treatment',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
) ENGINE=InnoDB;
-- The problem isn’t my SQL grammar but data semantics and naming consistency.
-- Use singular nouns for table names (medical_history),
-- Plural only if the table holds a collection conceptually (patients is fine).
-- Fixed. Thanks for the feedback!

-- Prescriptions
CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    staff_id INT NOT NULL,
    medication_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50) NOT NULL,
    frequency VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status ENUM('Active', 'Completed', 'Discontinued') DEFAULT 'Active',
    refills_remaining INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
) ENGINE=InnoDB;

-- Wards
CREATE TABLE wards (
    ward_id INT PRIMARY KEY AUTO_INCREMENT,
    ward_name VARCHAR(100) NOT NULL UNIQUE,
    ward_type ENUM('ICU', 'General Ward', 'Private Room', 'Semi-Private Room', 'Pediatric Ward', 'Maternity Ward', 'Emergency') NOT NULL,
    total_beds INT NOT NULL,
    building VARCHAR(50),
    floor INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Beds
CREATE TABLE beds (
    bed_id INT PRIMARY KEY AUTO_INCREMENT,
    ward_id INT NOT NULL,
    bed_number VARCHAR(20) NOT NULL UNIQUE,
    bed_status ENUM('Available', 'Occupied', 'Under Maintenance') DEFAULT 'Available',
    last_cleaned TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ward_id) REFERENCES wards(ward_id)
) ENGINE=InnoDB;

-- Admissions
CREATE TABLE admissions (
    admission_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    bed_id INT NOT NULL,
    admission_date DATETIME NOT NULL,
    discharge_date DATETIME,
    diagnosis VARCHAR(500) NOT NULL,
    attending_physician_id INT NOT NULL,
    admission_type ENUM('Emergency', 'Elective', 'Transfer') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (bed_id) REFERENCES beds(bed_id),
    FOREIGN KEY (attending_physician_id) REFERENCES staff(staff_id)
) ENGINE=InnoDB;

-- Billing
CREATE TABLE billing (
    billing_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    admission_id INT,
    appointment_id INT,
    total_amount DECIMAL(10, 2) NOT NULL,
    insurance_covered DECIMAL(10, 2) DEFAULT 0,
    patient_responsibility DECIMAL(10, 2) NOT NULL,
    payment_status ENUM('Pending', 'Paid', 'Partially Paid', 'Overdue') DEFAULT 'Pending',
    billing_date DATE NOT NULL,
    payment_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (admission_id) REFERENCES admissions(admission_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
) ENGINE=InnoDB;

-- Insurance Claims
CREATE TABLE insurance_claims (
    claim_id INT PRIMARY KEY AUTO_INCREMENT,
    billing_id INT NOT NULL,
    insurance_provider_id INT NOT NULL,
    claim_amount DECIMAL(10, 2) NOT NULL,
    claim_date DATE NOT NULL,
    claim_status ENUM('Submitted', 'Approved', 'Denied', 'Under Review', 'Pending') DEFAULT 'Submitted',
    processed_date DATE,
    denial_reason VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (billing_id) REFERENCES billing(billing_id),
    FOREIGN KEY (insurance_provider_id) REFERENCES insurance_providers(provider_id)
) ENGINE=InnoDB;


-- ========================================
-- QUERY 2: Add Business Rule Constraints
-- ========================================
-- PURPOSE: Enforce data integrity rules at database level
-- VALIDATES: Age ranges, salary limits, monetary values, date logic

ALTER TABLE patients 
ADD CONSTRAINT chk_patient_age 
CHECK (TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) >= 0 AND TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) <= 120);

ALTER TABLE staff 
ADD CONSTRAINT chk_staff_salary 
CHECK (salary >= 30000 AND salary <= 500000);

ALTER TABLE billing 
ADD CONSTRAINT chk_billing_amounts 
CHECK (total_amount >= 0 AND insurance_covered >= 0 AND patient_responsibility >= 0);

ALTER TABLE insurance_claims 
ADD CONSTRAINT chk_claim_amount 
CHECK (claim_amount >= 0);

ALTER TABLE wards 
ADD CONSTRAINT chk_ward_beds 
CHECK (total_beds > 0 AND total_beds <= 100);

ALTER TABLE prescriptions 
ADD CONSTRAINT chk_prescription_dates 
CHECK (end_date IS NULL OR end_date >= start_date);

ALTER TABLE admissions 
ADD CONSTRAINT chk_admission_dates 
CHECK (discharge_date IS NULL OR discharge_date >= admission_date);


-- ========================================
-- QUERY 3: Create Performance Indexes
-- ========================================
-- PURPOSE: Optimize query performance for frequent operations
-- IMPACT: 10-100x speedup on filtered queries and JOINs

-- Patient indexes
CREATE INDEX idx_patient_name ON patients(last_name, first_name);
CREATE INDEX idx_patient_dob ON patients(date_of_birth);
CREATE INDEX idx_patient_insurance ON patients(insurance_provider_id);

-- Appointment indexes
CREATE INDEX idx_appointment_date ON appointments(appointment_date);
CREATE INDEX idx_appointment_patient ON appointments(patient_id);
CREATE INDEX idx_appointment_staff ON appointments(staff_id);
CREATE INDEX idx_appointment_status ON appointments(status);

-- Staff indexes
CREATE INDEX idx_staff_role ON staff(role);
CREATE INDEX idx_staff_dept ON staff(department_id);

-- Prescription indexes
CREATE INDEX idx_prescription_patient ON prescriptions(patient_id);
CREATE INDEX idx_prescription_dates ON prescriptions(start_date, end_date);
CREATE INDEX idx_prescription_status ON prescriptions(status);

-- Admission indexes
CREATE INDEX idx_admission_patient ON admissions(patient_id);
CREATE INDEX idx_admission_dates ON admissions(admission_date, discharge_date);
CREATE INDEX idx_admission_physician ON admissions(attending_physician_id);

-- Billing indexes
CREATE INDEX idx_billing_patient ON billing(patient_id);
CREATE INDEX idx_billing_status ON billing(payment_status);
CREATE INDEX idx_billing_date ON billing(billing_date);

-- Bed indexes
CREATE INDEX idx_bed_status ON beds(bed_status);
CREATE INDEX idx_bed_ward ON beds(ward_id);

-- Claim indexes
CREATE INDEX idx_claim_status ON insurance_claims(claim_status);
CREATE INDEX idx_claim_provider ON insurance_claims(insurance_provider_id);


-- ========================================
-- QUERY 4: Verify Referential Integrity
-- ========================================
-- PURPOSE: Detect orphan records where foreign keys point to non-existent parents
-- USE CASE: Critical data quality check after data imports

SELECT 'Patients with invalid insurance' AS integrity_issue, COUNT(*) AS record_count
FROM patients p
LEFT JOIN insurance_providers ip ON p.insurance_provider_id = ip.provider_id
WHERE p.insurance_provider_id IS NOT NULL AND ip.provider_id IS NULL

UNION ALL

SELECT 'Appointments with invalid patients', COUNT(*)
FROM appointments a
LEFT JOIN patients p ON a.patient_id = p.patient_id
WHERE p.patient_id IS NULL

UNION ALL

SELECT 'Appointments with invalid staff', COUNT(*)
FROM appointments a
LEFT JOIN staff s ON a.staff_id = s.staff_id
WHERE s.staff_id IS NULL

UNION ALL

SELECT 'Prescriptions with invalid doctors', COUNT(*)
FROM prescriptions pr
LEFT JOIN staff s ON pr.staff_id = s.staff_id
WHERE s.staff_id IS NULL

UNION ALL

SELECT 'Admissions with invalid beds', COUNT(*)
FROM admissions ad
LEFT JOIN beds b ON ad.bed_id = b.bed_id
WHERE b.bed_id IS NULL

UNION ALL

SELECT 'Billing with invalid patients', COUNT(*)
FROM billing b
LEFT JOIN patients p ON b.patient_id = p.patient_id
WHERE p.patient_id IS NULL;


-- ========================================
-- QUERY 5: Duplicate Patient Detection
-- ========================================
-- PURPOSE: Identify potential duplicate patient records for merging
-- WHY IT MATTERS: Duplicate patients lead to fragmented medical history and billing errors

SELECT 
    first_name,
    last_name,
    date_of_birth,
    COUNT(*) AS duplicate_count,
    GROUP_CONCAT(patient_id ORDER BY patient_id) AS patient_ids
FROM patients
GROUP BY first_name, last_name, date_of_birth
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ========================================
-- QUERY 6: Critical Null Value Audit
-- ========================================
-- PURPOSE: Track missing data in critical fields that impact care and operations
-- USE CASE: Prioritize data completion efforts

SELECT 
    'Patients missing emergency contacts' AS data_quality_issue,
    COUNT(*) AS record_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM patients), 2) AS percentage
FROM patients
WHERE emergency_contact_name IS NULL OR emergency_contact_phone IS NULL

UNION ALL

SELECT 
    'Patients without insurance',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM patients), 2)
FROM patients
WHERE insurance_provider_id IS NULL

UNION ALL

SELECT 
    'Active admissions without discharge dates',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM admissions), 2)
FROM admissions
WHERE discharge_date IS NULL

UNION ALL

SELECT 
    'Prescriptions without end dates',
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM prescriptions), 2)
FROM prescriptions
WHERE end_date IS NULL AND status = 'Active';


-- ========================================
-- QUERY 7: Date Logic Validation
-- ========================================
-- PURPOSE: Catch impossible or illogical date sequences
-- VALIDATES: Discharge before admission, prescription end before start

SELECT 
    'Admissions: discharge before admission' AS date_logic_error,
    COUNT(*) AS error_count
FROM admissions
WHERE discharge_date IS NOT NULL AND discharge_date < admission_date

UNION ALL

SELECT 
    'Prescriptions: end date before start date',
    COUNT(*)
FROM prescriptions
WHERE end_date IS NOT NULL AND end_date < start_date

UNION ALL

SELECT 
    'Staff: future hire dates',
    COUNT(*)
FROM staff
WHERE hire_date > CURDATE()

UNION ALL

SELECT 
    'Appointments: scheduled in the past with Scheduled status',
    COUNT(*)
FROM appointments
WHERE appointment_date < CURDATE() AND status = 'Scheduled';


-- ========================================
-- QUERY 8: Cross-Table Billing Consistency
-- ========================================
-- PURPOSE: Verify billing math is correct (insurance + patient = total)
-- WHY IT MATTERS: Billing errors cause claim denials and patient complaints

SELECT 
    billing_id,
    patient_id,
    total_amount,
    insurance_covered,
    patient_responsibility,
    (insurance_covered + patient_responsibility) AS calculated_total,
    ROUND(ABS(total_amount - (insurance_covered + patient_responsibility)), 2) AS discrepancy
FROM billing
WHERE ABS(total_amount - (insurance_covered + patient_responsibility)) > 0.01
ORDER BY discrepancy DESC
LIMIT 20;


-- ========================================
-- QUERY 9: Record Count Verification
-- ========================================
-- PURPOSE: Quick health check showing data volume across all tables
-- USE CASE: Verify data loaded correctly after import

SELECT 'departments' AS table_name, COUNT(*) AS record_count FROM departments
UNION ALL SELECT 'insurance_providers', COUNT(*) FROM insurance_providers
UNION ALL SELECT 'appointment_types', COUNT(*) FROM appointment_types
UNION ALL SELECT 'wards', COUNT(*) FROM wards
UNION ALL SELECT 'patients', COUNT(*) FROM patients
UNION ALL SELECT 'staff', COUNT(*) FROM staff
UNION ALL SELECT 'medical_history', COUNT(*) FROM medical_history
UNION ALL SELECT 'appointments', COUNT(*) FROM appointments
UNION ALL SELECT 'prescriptions', COUNT(*) FROM prescriptions
UNION ALL SELECT 'beds', COUNT(*) FROM beds
UNION ALL SELECT 'admissions', COUNT(*) FROM admissions
UNION ALL SELECT 'billing', COUNT(*) FROM billing
UNION ALL SELECT 'insurance_claims', COUNT(*) FROM insurance_claims
ORDER BY record_count DESC;


-- ========================================
-- QUERY 10: Sample Data Preview
-- ========================================
-- PURPOSE: Visual verification that data looks realistic and properly formatted
-- USE CASE: Quick sanity check after data import

-- Patient sample
SELECT 
    'PATIENTS' AS data_sample,
    patient_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age,
    gender,
    blood_type,
    phone
FROM patients
ORDER BY patient_id
LIMIT 5;

-- Staff sample
SELECT 
    'STAFF' AS data_sample,
    staff_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    role,
    d.department_name,
    hire_date
FROM staff s
INNER JOIN departments d ON s.department_id = d.department_id
ORDER BY staff_id
LIMIT 5;

-- Appointment sample
SELECT 
    'APPOINTMENTS' AS data_sample,
    appointment_id,
    appointment_date,
    appointment_time,
    status,
    at.type_name AS appointment_type
FROM appointments a
INNER JOIN appointment_types at ON a.appointment_type_id = at.type_id
ORDER BY appointment_date DESC
LIMIT 5;

-- ========================================
-- END OF SCHEMA FILE
-- THANK YOU
-- ========================================