# Fund Metadata Migration Project

## Overview
This repository documents the process and structure involved in migrating fund metadata from a file-based storage system to a relational database, specifically SQL Server. This migration was aimed at improving the management and accessibility of fund metadata by leveraging the advanced capabilities of relational databases. It highlights the design and implementation of the database schema, including the creation of tables, constraints, and relationships.

## Project Steps
1. **Data Structure Design**

    - Engaged in discussions with account managers to clarify the fund metadata structure.
    - Designed table relationships, including one-to-many and many-to-many relationships, with considerations for unique constraints and parent-child relationships.

2. **SQL Server Table Creation**

    - Developed SQL queries to create the necessary tables in SQL Server to accommodate the fund metadata.

3. **Schema Extraction and Structure Chart Development**

    - Extracted the database schema and created a structure chart to visually convey the table structure. This was shared with stakeholders, including Wolfram Language developers and IT teams in London, to gather feedback and make improvements.

4. **Testing**

    - Populated the SQL Server with demo data to validate data types and constraints.
    - Extracted data to Wolfram and VBA for transformation into financial reports.

5. **Bulk Data Upload**

    - Created VBA scripts to facilitate the bulk uploading of data from Excel to the SQL Server database for all funds.

## Structure Chart
Included in this repository is a structure chart that visually represents the table relationships within the database, highlighting the one-to-many and many-to-many relationships.
![MetaData Migration View](https://github.com/derickkan3356/FundMetadataMigrationSQL/blob/main/MetaData%20Migration%20View.png)

## Challenges and Solutions
One significant challenge faced was implementing a cross-table unique constraint to ensure investor codes were unique within the same client but across three different tables. The solution involved creating a SQL Server trigger to enforce this constraint upon insert and update operations.

## Files Included
- SQL Query and Trigger for Creating Tables: A .sql file containing the SQL commands to create the necessary tables and the trigger for enforcing the cross-table unique constraint.
- Structure Chart: A visual representation of the table relationships.

## Contributions and Acknowledgements
This project was a collaborative effort involving discussions with account managers for clarity on fund metadata, feedback from Wolfram Language developers, and coordination with the London office's IT team for schema and data structure improvements.