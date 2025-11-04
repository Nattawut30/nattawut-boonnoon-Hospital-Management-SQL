# <p align="center">🏥 SQL: Hospital Management System 🧬<p/>
<br>**Nattawut Boonnoon**<br/>
💼 LinkedIn: www.linkedin.com/in/nattawut-bn
<br>📧 Email: nattawut.boonnoon@hotmail.com<br/>
📱 Phone: (+66) 92 271 6680

***📋 Overview***
-
My personal SQL project is creating a functional hospital management database using MySQL that tackles three operational challenges in modern healthcare facilities:

1. Patient Care Workflows = Tracks patient admissions, appointments, treatments, and medical histories in real-time to reduce wait times and improve care coordination.
2. Resource Allocation = Manages doctors, nurses, equipment, and room assignments to maximize utilization and minimize operational bottlenecks.
3. Financial Operations = Monitors billing, insurance claims, and payment processing to reduce revenue leakage and improve cash flow.

**Why It Matters:** Hospitals struggle with fragmented data systems that lead to scheduling conflicts, unused resources, and billing errors costing millions annually. I hope this database acts as a centralized backbone example, giving administrators clear visibility into operations so they can make better decisions that directly impact outcomes.

***⭐ Database Architecture***
-
**📂 Core Modules:**
- Patient Management: Complete demographics, medical records, and insurance information.
- Appointment Scheduling: A collaborative department scheduling system with status tracking.
- Staff management includes personnel data, department duties, and performance indicators
- Billing & Insurance: Financial transactions, insurance claims, and payment tracking.
- Ward/Bed Management: Real-time bed occupancy and patient admission procedures.
- Inventory Management: Track medical supplies with automated reorder alerts.

**📊 Statistics:**

- 13 Interconnected Tables
- 150 Patient Records
- 250 Staff Members (Doctors, Nurses, Administrative Staff, Technicians)
- 1,000 Appointments
- 5,000 Medical History Records
- 3,500 Prescriptions
- 180 Hospital Beds across 12 wards
- ~1,000 Billing Transactions

***🗂️ Relationship Diagram***
-
`````
                    ┌─────────────┐           ┌──────────────┐           ┌─────────────┐
                    │  Patients   │──────────▶│ Appointments │◀──────────│    Staff    │
                    └─────────────┘           └──────────────┘           └─────────────┘
                          │                           │                            │
                          │                           │                            │
                          ▼                           ▼                            ▼
                    ┌─────────────┐           ┌──────────────┐           ┌─────────────┐
                    │Medical      │           │    Billing   │           │ Departments │
                    │History      │           └──────────────┘           └─────────────┘
                    └─────────────┘                   │
                          │                           │
                          │                           ▼
                          │                   ┌──────────────┐
                          │                   │  Insurance   │
                          │                   │    Claims    │
                          └──────────────────▶└──────────────┘
`````


# <p align="center">📥 Sample Queries 📊<p/>
**Prerequisites:**

https://www.mysql.com/
- MySQL 8.0 or higher
- At least 500MB free disk space

**Installation:**
1. Clone the Repository
   ```
   git clone https://github.com/yourusername/hospital-management-system.git
   cd hospital-management-system
   ```
2. Create the Database
   ```
   mysql -u root -p < schema/Nattawut_HMS_schema.sql
   ```
3. Load Sample Data
   ```
   # Place all CSV files from data/ folder in MySQL's secure file directory
   # Then run the LOAD DATA commands in hospital_schema.sql
   # Or manually import CSVs using your MySQL client
   ```
4. Run Sample Queries
   ```
   mysql -u root -p hospital_management < queries/Nattawut_HMS_queries.sql
   ```

***💉 Basic***
-

***💊 Intermediate***
-

***⚕️ Advanced***
-

# <p align="center">🎓 Key Learning Outcomes 📚<p/>

**Technical Expertise:**
- ✅
- ✅

**Business Acumen:**

- 📈 Healthcare quality metrics (readmission rates, length of stay)
- 💰 Revenue cycle management (claims, denials, collections)
- 🏥 Clinical workflows (admissions, discharges, prescriptions)
- 👥 Resource optimization (staff workload, bed capacity, inventory)
- 📊 Operational analytics for decision-making

**Acknowledgments:**

- 🚑 Healthcare domain knowledge inspired by real-world hospital systems
- 👨🏼‍⚕️ SQL best practices from industry standards
- 👩🏼‍⚕️ Database design principles following E.F. Codd's relational model
