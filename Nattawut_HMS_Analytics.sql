-- ========================================
-- HOSPITAL MANAGEMENT SYSTEM
-- LinkedIn: www.linkedin.com/in/nattawut-bn
-- GitHub: @Nattawut30
-- Email: nattawut.boonnoon@hotmail.com
-- Phone: (+66) 92 271 6680
-- ANALYTICS QUERIES - 12 QUERIES
-- 4 Basic | 4 Intermediate | 4 Advanced
-- ========================================

-- ========================================
-- SECTION 1: BASIC QUERIES (4)
-- ========================================

-- -------------------------------------
-- QUERY 1: Patient Emergency Contact Lookup
-- -------------------------------------
-- PROBLEM: ER needs immediate patient contact info for unconscious patients
-- WHY IT MATTERS: Delays in contacting family can complicate critical care decisions
-- SOLUTION: Fast lookup by patient ID with emergency contact details

SELECT 
    patient_id,
    CONCAT(first_name, ' ', last_name) AS patient_name,
    date_of_birth,
    TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age,
    gender,
    blood_type,
    phone AS patient_phone,
    emergency_contact_name,
    emergency_contact_phone,
    CONCAT(address, ', ', city, ', ', state, ' ', zip_code) AS full_address
FROM 
    patients
WHERE 
    patient_id = 25  -- Replace with actual patient ID now
ORDER BY 
    patient_id;


-- -------------------------------------
-- QUERY 2: Top 10 Busiest Doctors This Month
-- -------------------------------------
-- PROBLEM: Identify overworked doctors to prevent burnout
-- WHY IT MATTERS: Doctor burnout leads to medical errors and staff turnover
-- SOLUTION: Rank doctors by appointment count using LIMIT

SELECT 
    s.staff_id,
    CONCAT(s.first_name, ' ', s.last_name) AS doctor_name,
    d.department_name,
    COUNT(a.appointment_id) AS total_appointments,
    COUNT(CASE WHEN a.status = 'Completed' THEN 1 END) AS completed,
    COUNT(CASE WHEN a.status = 'No-Show' THEN 1 END) AS no_shows
FROM 
    staff s
    INNER JOIN departments d ON s.department_id = d.department_id
    INNER JOIN appointments a ON s.staff_id = a.staff_id
WHERE 
    s.role = 'Doctor'
    AND a.appointment_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY 
    s.staff_id, s.first_name, s.last_name, d.department_name
ORDER BY 
    total_appointments DESC
LIMIT 10;


-- -------------------------------------
-- QUERY 3: Available Beds by Ward Type
-- -------------------------------------
-- PROBLEM: Admissions desk needs real-time bed availability
-- WHY IT MATTERS: Delays in bed assignment increase ER wait times
-- SOLUTION: Aggregate bed counts by ward using GROUP BY

SELECT 
    w.ward_name,
    w.ward_type,
    w.total_beds,
    COUNT(CASE WHEN b.bed_status = 'Available' THEN 1 END) AS available_beds,
    COUNT(CASE WHEN b.bed_status = 'Occupied' THEN 1 END) AS occupied_beds,
    COUNT(CASE WHEN b.bed_status = 'Under Maintenance' THEN 1 END) AS maintenance_beds,
    ROUND((COUNT(CASE WHEN b.bed_status = 'Occupied' THEN 1 END) * 100.0 / w.total_beds), 2) AS occupancy_rate
FROM 
    wards w
    LEFT JOIN beds b ON w.ward_id = b.ward_id
GROUP BY 
    w.ward_id, w.ward_name, w.ward_type, w.total_beds
ORDER BY 
    occupancy_rate DESC;


-- -------------------------------------
-- QUERY 4: Active Prescriptions for Patient
-- -------------------------------------
-- PROBLEM: Pharmacists must check all active meds to avoid dangerous interactions
-- WHY IT MATTERS: Drug interactions cause 100,000+ ER visits annually in US
-- SOLUTION: Filter by patient and active status with date validation

SELECT 
    pr.prescription_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    pr.medication_name,
    pr.dosage,
    pr.frequency,
    pr.start_date,
    pr.end_date,
    pr.refills_remaining,
    CONCAT(s.first_name, ' ', s.last_name) AS prescribing_doctor,
    d.department_name
FROM 
    prescriptions pr
    INNER JOIN patients p ON pr.patient_id = p.patient_id
    INNER JOIN staff s ON pr.staff_id = s.staff_id
    INNER JOIN departments d ON s.department_id = d.department_id
WHERE 
    pr.patient_id = 10  -- Replace with actual patient ID
    AND pr.status = 'Active'
    AND (pr.end_date IS NULL OR pr.end_date >= CURDATE())
ORDER BY 
    pr.start_date DESC;


-- ========================================
-- SECTION 2: INTERMEDIATE QUERIES (4)
-- ========================================

-- -------------------------------------
-- QUERY 5: Patient Visit Frequency (Last 6 Months)
-- -------------------------------------
-- PROBLEM: Identify frequent visitors for chronic disease management programs
-- WHY IT MATTERS: Coordinated care for high-frequency patients reduces ER visits by 25%
-- SOLUTION: Aggregate appointments per patient with HAVING filter

SELECT 
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS age,
    COUNT(a.appointment_id) AS total_visits,
    COUNT(CASE WHEN a.status = 'Completed' THEN 1 END) AS completed_visits,
    COUNT(CASE WHEN a.status = 'No-Show' THEN 1 END) AS no_shows,
    MIN(a.appointment_date) AS first_visit,
    MAX(a.appointment_date) AS last_visit,
    ROUND(COUNT(a.appointment_id) / 6.0, 1) AS avg_visits_per_month
FROM 
    patients p
    INNER JOIN appointments a ON p.patient_id = a.patient_id
WHERE 
    a.appointment_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY 
    p.patient_id, p.first_name, p.last_name, p.date_of_birth
HAVING 
    total_visits >= 4  -- Flag patients with 4+ visits
ORDER BY 
    total_visits DESC;


-- -------------------------------------
-- QUERY 6: Department Revenue Analysis (Last Quarter)
-- -------------------------------------
-- PROBLEM: Financial planning needs to know which departments drive revenue
-- WHY IT MATTERS: Revenue data guides hiring, equipment purchases, and service expansion
-- SOLUTION: Sum billing amounts by department using subquery

SELECT 
    d.department_name,
    COUNT(DISTINCT a.appointment_id) AS total_appointments,
    SUM(b.total_amount) AS total_revenue,
    SUM(b.insurance_covered) AS insurance_payments,
    SUM(b.patient_responsibility) AS patient_payments,
    ROUND(AVG(b.total_amount), 2) AS avg_transaction,
    SUM(CASE WHEN b.payment_status = 'Paid' THEN b.patient_responsibility ELSE 0 END) AS collected,
    SUM(CASE WHEN b.payment_status = 'Pending' THEN b.patient_responsibility ELSE 0 END) AS outstanding
FROM 
    departments d
    INNER JOIN appointments a ON d.department_id = a.department_id
    INNER JOIN billing b ON a.appointment_id = b.appointment_id
WHERE 
    b.billing_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY 
    d.department_id, d.department_name
HAVING 
    total_revenue > 0
ORDER BY 
    total_revenue DESC;


-- -------------------------------------
-- QUERY 7: Medication Inventory Below Reorder Level
-- -------------------------------------
-- PROBLEM: Pharmacy must avoid stockouts of critical medications
-- WHY IT MATTERS: Medication stockouts delay patient care and violate quality standards
-- SOLUTION: Subquery to calculate days until stockout based on usage rate

SELECT 
    i.inventory_id,
    i.item_name,
    i.category,
    i.quantity_in_stock,
    i.reorder_level,
    (i.reorder_level - i.quantity_in_stock) AS units_below_threshold,
    i.unit_cost,
    ROUND((i.reorder_level - i.quantity_in_stock) * i.unit_cost, 2) AS reorder_cost,
    i.last_restock_date,
    DATEDIFF(CURDATE(), i.last_restock_date) AS days_since_restock,
    -- Estimate days until stockout (assuming 5 units used per day)
    ROUND(i.quantity_in_stock / 5.0, 1) AS estimated_days_remaining
FROM 
    inventory i
WHERE 
    i.quantity_in_stock <= i.reorder_level
ORDER BY 
    estimated_days_remaining ASC,
    reorder_cost DESC
LIMIT 20;


-- -------------------------------------
-- QUERY 8: No-Show Rate by Appointment Type
-- -------------------------------------
-- PROBLEM: No-shows waste appointment slots and cost hospitals $150-200 per instance
-- WHY IT MATTERS: Reducing no-shows by 10% can add 500+ patient visits annually
-- SOLUTION: Calculate percentage using CASE aggregation

SELECT 
    at.type_name,
    COUNT(a.appointment_id) AS total_scheduled,
    COUNT(CASE WHEN a.status = 'Completed' THEN 1 END) AS completed,
    COUNT(CASE WHEN a.status = 'No-Show' THEN 1 END) AS no_shows,
    COUNT(CASE WHEN a.status = 'Cancelled' THEN 1 END) AS cancelled,
    ROUND((COUNT(CASE WHEN a.status = 'No-Show' THEN 1 END) * 100.0 / COUNT(a.appointment_id)), 2) AS no_show_rate,
    ROUND((COUNT(CASE WHEN a.status = 'Completed' THEN 1 END) * 100.0 / COUNT(a.appointment_id)), 2) AS completion_rate,
    SUM(at.base_cost) AS potential_revenue,
    ROUND((COUNT(CASE WHEN a.status = 'No-Show' THEN 1 END) * at.base_cost), 2) AS revenue_lost
FROM 
    appointments a
    INNER JOIN appointment_types at ON a.appointment_type_id = at.type_id
WHERE 
    a.appointment_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY 
    at.type_name, at.base_cost
HAVING 
    total_scheduled >= 10  -- Only statistically significant samples
ORDER BY 
    no_show_rate DESC;


-- ========================================
-- SECTION 3: ADVANCED QUERIES (4)
-- ========================================

-- -------------------------------------
-- QUERY 9: 30-Day Readmission Analysis (Window Function)
-- -------------------------------------
-- PROBLEM: CMS penalizes hospitals with readmission rates above national average
-- WHY IT MATTERS: Each readmission costs $15K+ and indicates care quality issues
-- SOLUTION: Use LEAD window function to identify readmissions within 30 days

WITH admission_sequence AS (
    SELECT 
        ad.admission_id,
        ad.patient_id,
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        ad.admission_date,
        ad.discharge_date,
        ad.diagnosis,
        ad.admission_type,
        CONCAT(s.first_name, ' ', s.last_name) AS attending_doctor,
        d.department_name,
        LEAD(ad.admission_date) OVER (
            PARTITION BY ad.patient_id 
            ORDER BY ad.admission_date
        ) AS next_admission_date,
        LEAD(ad.diagnosis) OVER (
            PARTITION BY ad.patient_id 
            ORDER BY ad.admission_date
        ) AS next_diagnosis
    FROM 
        admissions ad
        INNER JOIN patients p ON ad.patient_id = p.patient_id
        INNER JOIN staff s ON ad.attending_physician_id = s.staff_id
        INNER JOIN departments d ON s.department_id = d.department_id
    WHERE 
        ad.discharge_date IS NOT NULL
)
SELECT 
    patient_id,
    patient_name,
    admission_date AS first_admission,
    discharge_date,
    diagnosis AS first_diagnosis,
    next_admission_date AS readmission_date,
    next_diagnosis AS readmission_diagnosis,
    DATEDIFF(next_admission_date, discharge_date) AS days_between,
    attending_doctor,
    department_name,
    CASE 
        WHEN DATEDIFF(next_admission_date, discharge_date) <= 7 THEN 'Critical (0-7 days)'
        WHEN DATEDIFF(next_admission_date, discharge_date) <= 14 THEN 'High Risk (8-14 days)'
        ELSE 'Moderate Risk (15-30 days)'
    END AS risk_level
FROM 
    admission_sequence
WHERE 
    next_admission_date IS NOT NULL
    AND DATEDIFF(next_admission_date, discharge_date) <= 30
ORDER BY 
    days_between ASC;


-- -------------------------------------
-- QUERY 10: Doctor Performance Dashboard (CTE)
-- -------------------------------------
-- PROBLEM: Hospital leadership needs comprehensive doctor metrics for evaluations
-- WHY IT MATTERS: Performance data drives bonuses, promotions, and improvement plans
-- SOLUTION: Multi-CTE query combining appointment, revenue, and admission metrics

WITH doctor_appointments AS (
    SELECT 
        s.staff_id,
        CONCAT(s.first_name, ' ', s.last_name) AS doctor_name,
        d.department_name,
        COUNT(a.appointment_id) AS total_appointments,
        COUNT(CASE WHEN a.status = 'Completed' THEN 1 END) AS completed_appointments,
        ROUND((COUNT(CASE WHEN a.status = 'Completed' THEN 1 END) * 100.0 / 
               COUNT(a.appointment_id)), 2) AS completion_rate
    FROM 
        staff s
        INNER JOIN departments d ON s.department_id = d.department_id
        LEFT JOIN appointments a ON s.staff_id = a.staff_id
            AND a.appointment_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
    WHERE 
        s.role = 'Doctor'
    GROUP BY 
        s.staff_id, s.first_name, s.last_name, d.department_name
),
doctor_revenue AS (
    SELECT 
        s.staff_id,
        SUM(b.total_amount) AS total_revenue,
        ROUND(AVG(b.total_amount), 2) AS avg_revenue_per_visit
    FROM 
        staff s
        LEFT JOIN appointments a ON s.staff_id = a.staff_id
        LEFT JOIN billing b ON a.appointment_id = b.appointment_id
    WHERE 
        s.role = 'Doctor'
        AND b.billing_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
    GROUP BY 
        s.staff_id
),
doctor_admissions AS (
    SELECT 
        attending_physician_id AS staff_id,
        COUNT(admission_id) AS total_admissions,
        ROUND(AVG(DATEDIFF(discharge_date, admission_date)), 1) AS avg_length_of_stay
    FROM 
        admissions
    WHERE 
        discharge_date IS NOT NULL
        AND admission_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
    GROUP BY 
        attending_physician_id
)
SELECT 
    da.staff_id,
    da.doctor_name,
    da.department_name,
    da.total_appointments,
    da.completed_appointments,
    da.completion_rate,
    COALESCE(dr.total_revenue, 0) AS total_revenue,
    COALESCE(dr.avg_revenue_per_visit, 0) AS avg_revenue_per_visit,
    COALESCE(dad.total_admissions, 0) AS total_admissions,
    COALESCE(dad.avg_length_of_stay, 0) AS avg_length_of_stay_days
FROM 
    doctor_appointments da
    LEFT JOIN doctor_revenue dr ON da.staff_id = dr.staff_id
    LEFT JOIN doctor_admissions dad ON da.staff_id = dad.staff_id
WHERE 
    da.total_appointments > 0
ORDER BY 
    total_revenue DESC, completed_appointments DESC
LIMIT 15;


-- -------------------------------------
-- QUERY 11: Patients With vs Without Insurance (UNION)
-- -------------------------------------
-- PROBLEM: Uninsured patients have different billing and care coordination needs
-- WHY IT MATTERS: Uninsured patients are 3x more likely to have unpaid balances
-- SOLUTION: Compare two patient cohorts using UNION

SELECT 
    'Insured Patients' AS patient_group,
    COUNT(DISTINCT p.patient_id) AS total_patients,
    COUNT(a.appointment_id) AS total_appointments,
    ROUND(AVG(b.total_amount), 2) AS avg_bill_amount,
    SUM(CASE WHEN b.payment_status = 'Paid' THEN 1 ELSE 0 END) AS paid_bills,
    SUM(CASE WHEN b.payment_status IN ('Pending', 'Overdue') THEN 1 ELSE 0 END) AS unpaid_bills,
    ROUND((SUM(CASE WHEN b.payment_status = 'Paid' THEN 1 ELSE 0 END) * 100.0 / 
           COUNT(b.billing_id)), 2) AS payment_rate
FROM 
    patients p
    LEFT JOIN appointments a ON p.patient_id = a.patient_id
    LEFT JOIN billing b ON a.appointment_id = b.appointment_id
WHERE 
    p.insurance_provider_id IS NOT NULL

UNION ALL

SELECT 
    'Uninsured Patients' AS patient_group,
    COUNT(DISTINCT p.patient_id),
    COUNT(a.appointment_id),
    ROUND(AVG(b.total_amount), 2),
    SUM(CASE WHEN b.payment_status = 'Paid' THEN 1 ELSE 0 END),
    SUM(CASE WHEN b.payment_status IN ('Pending', 'Overdue') THEN 1 ELSE 0 END),
    ROUND((SUM(CASE WHEN b.payment_status = 'Paid' THEN 1 ELSE 0 END) * 100.0 / 
           COUNT(b.billing_id)), 2)
FROM 
    patients p
    LEFT JOIN appointments a ON p.patient_id = a.patient_id
    LEFT JOIN billing b ON a.appointment_id = b.appointment_id
WHERE 
    p.insurance_provider_id IS NULL;


-- -------------------------------------
-- QUERY 12: Insurance Claim Denial Analysis by Provider
-- -------------------------------------
-- PROBLEM: Claim denials cost hospitals millions in lost revenue annually
-- WHY IT MATTERS: Each denied claim costs $25-100 in administrative rework
-- SOLUTION: Multi-level analysis using CTE and subquery for denial patterns

WITH claim_analysis AS (
    SELECT 
        ic.claim_id,
        ip.provider_name,
        ip.coverage_type,
        ic.claim_amount,
        ic.claim_status,
        ic.denial_reason,
        b.total_amount,
        CASE 
            WHEN b.admission_id IS NOT NULL THEN 'Inpatient'
            WHEN b.appointment_id IS NOT NULL THEN 'Outpatient'
        END AS claim_type,
        CASE 
            WHEN ic.claim_amount < 500 THEN 'Small (<$500)'
            WHEN ic.claim_amount < 2000 THEN 'Medium ($500-$2K)'
            WHEN ic.claim_amount < 10000 THEN 'Large ($2K-$10K)'
            ELSE 'Very Large ($10K+)'
        END AS claim_size
    FROM 
        insurance_claims ic
        INNER JOIN insurance_providers ip ON ic.insurance_provider_id = ip.provider_id
        INNER JOIN billing b ON ic.billing_id = b.billing_id
    WHERE 
        ic.claim_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
)
SELECT 
    provider_name,
    coverage_type,
    COUNT(*) AS total_claims,
    COUNT(CASE WHEN claim_status = 'Approved' THEN 1 END) AS approved,
    COUNT(CASE WHEN claim_status = 'Denied' THEN 1 END) AS denied,
    COUNT(CASE WHEN claim_status IN ('Pending', 'Under Review') THEN 1 END) AS pending,
    ROUND((COUNT(CASE WHEN claim_status = 'Approved' THEN 1 END) * 100.0 / COUNT(*)), 2) AS approval_rate,
    ROUND((COUNT(CASE WHEN claim_status = 'Denied' THEN 1 END) * 100.0 / COUNT(*)), 2) AS denial_rate,
    ROUND(SUM(claim_amount), 2) AS total_claimed,
    ROUND(SUM(CASE WHEN claim_status = 'Approved' THEN claim_amount ELSE 0 END), 2) AS total_approved,
    ROUND(SUM(CASE WHEN claim_status = 'Denied' THEN claim_amount ELSE 0 END), 2) AS total_denied,
    -- Most common denial reason (subquery)
    (SELECT denial_reason 
     FROM claim_analysis ca2 
     WHERE ca2.provider_name = ca.provider_name 
       AND ca2.denial_reason IS NOT NULL 
     GROUP BY denial_reason 
     ORDER BY COUNT(*) DESC 
     LIMIT 1) AS top_denial_reason
FROM 
    claim_analysis ca
GROUP BY 
    provider_name, coverage_type
HAVING 
    total_claims >= 5  -- Only providers with meaningful sample size
ORDER BY 
    denial_rate DESC, total_denied DESC;

-- ========================================
-- END OF ANALYTICS QUERIES
-- THANK YOU
-- ========================================