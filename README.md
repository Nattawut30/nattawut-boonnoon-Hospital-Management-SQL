# <p align="center">🏥 SQL: Hospital Management System 🧬<p/>
<br>**Nattawut Boonnoon**<br/>
💼 LinkedIn: www.linkedin.com/in/nattawut-bn
<br>📧 Email: nattawut.boonnoon@hotmail.com<br/>
📱 Phone: (+66) 92 271 6680

***Overview***
-
My SQL project explores database solutions using MySQL for managing complex healthcare operations, tackling three modern major challenges:

1. Patient Care Workflows = Tracks patient admissions, appointments, treatments, and medical histories in real-time to reduce wait times and improve care coordination.
2. Resource Allocation = Manages doctors, nurses, equipment, and room assignments to maximize utilization and minimize operational bottlenecks.
3. Financial Operations = Monitors billing, insurance claims, and payment processing to reduce revenue leakage and improve cash flow.

**Why It Matters:** Hospitals struggle with fragmented data systems that lead to scheduling conflicts, unused resources, and billing errors costing millions annually. I hope this database acts as a centralized backbone example, giving administrators clear visibility into operations so they can make better decisions that directly impact outcomes.

***Database Architecture***
-
**Core Modules:**
`````
- Patient Management: Complete demographics, medical records, and insurance information.
- Appointment Scheduling: A collaborative department scheduling system with status tracking.
- Staff management includes personnel data, department duties, and performance indicators
- Billing & Insurance: Financial transactions, insurance claims, and payment tracking.
- Ward/Bed Management: Real-time bed occupancy and patient admission procedures.
- Inventory Management: Track medical supplies with automated reorder alerts.
`````

**Statistics:**
`````
- 13 Interconnected Tables
- 300 Patient Records
- 500 Staff Members (Doctors, Nurses, Administrative Staff, Technicians)
- 2,000 Appointments
- 10,000 Medical History Records
- 7,000 Prescriptions
- 340 Hospital Beds across 12 wards
- ~2,000 Billing Transactions
`````

***Entity Relationship Diagram***
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

***Basic***
-

***Intermediate***
-

***Advanced***
-
