# MediFlow EHR System

## Prerequisites

- Python 3.x
- Flask
- mysql-connector-python
- A local MySQL Server (e.g., XAMPP)

## Setup Instructions

1. Open phpMyAdmin or your MySQL client.
2. Create a new database named `ehr_system`.
3. Import the provided `ehr_system.sql` file into this database to create all necessary tables.
4. Open your terminal in the project folder and install the required Python libraries:

&#x20;  pip install flask mysql-connector-python
5. Run the application:

&#x20;  python app.py

6. Open your browser and go to http://127.0.0.1:5000