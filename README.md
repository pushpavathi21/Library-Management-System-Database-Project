# Library-Management-System-Database-Project
This project implements a Library Management System in PostgreSQL, designed to manage books, authors, members, and loans in a digital library. It demonstrates relational schema design, many-to-many relationships, triggers, views, and reporting queries for real-world database operations.

🎯 Objectives:-

-> Design a normalized relational schema (Books, Authors, Members, Loans).
-> Handle many-to-many relationships via a bridge table (book_authors).
-> Create views for borrowed books, current loans, and overdue loans.
-> Implement triggers for due-date automation and overdue notifications.
-> Generate analytical reports using JOINs and aggregate functions.

🛠️ Tools Used:-

-> PostgreSQL – Relational Database Management System
-> pgAdmin 4 – GUI for managing PostgreSQL
-> GitHub – Version control and documentation

🗂️ Project Structure
Final-Project-Library/
│── library_project_postgres.sql      # Full schema, sample data, triggers, and views
│── librarydb_dump.sql                # Exported DB dump (from pgAdmin)
│── ERD.md                            # Entity-Relationship Diagram (Mermaid)
│── overdue_report_queries.sql        # Reporting queries for overdue/analytics
│── Library_Management_System_Project_Report.pdf  # 2-page project documentation
│── README.md                         # Project overview & usage instructions


📊 Database Schema:-

-> members → library members
-> books → books with title, year, price
-> authors → book authors
-> book_authors → bridge table (many-to-many)
-> loans → borrowing transactions
-> notifications → overdue alerts (via trigger)

🔗 ERD:-

See ERD.md
 (Mermaid diagram). GitHub automatically renders the relationship diagram.

🔍 Key Features

Views

v_borrowed_book_details → member + book borrow details

v_current_loans → all active loans (not returned)

v_overdue_loans → overdue books with days late

Triggers

trg_set_due_date → auto-assign due_date = borrow_date + 14 days

trg_notify_overdue → insert a notification when loan is overdue

Reports (see overdue_report_queries.sql)

Borrow count per member

Most borrowed books (Top 5)

Overdue loans with days overdue

Top authors by borrows

Monthly borrowing trends

▶️ How to Run

Open pgAdmin → Create DB librarydb.

Run library_project_postgres.sql in Query Tool.

Insert test data (already included in script).

Test queries:

SELECT * FROM v_borrowed_book_details;
SELECT * FROM v_overdue_loans;
SELECT * FROM notifications;


For reports, run queries from overdue_report_queries.sql.

📝 Deliverables

✅ Database schema + sample data

✅ ERD diagram

✅ Views & triggers

✅ Reports using SQL aggregation & joins

✅ Documentation (PDF report)

📌 Conclusion:-

This project demonstrates end-to-end database design and implementation using PostgreSQL. It automates due-date tracking, generates overdue notifications, and produces analytical insights for library operations.

THANK YOU

REGARDS,
PUSHPA
