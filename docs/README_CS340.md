<p align="center">
  <img src="./IMG_5138.jpg" alt="High-Speed Rail Banner" style="width:100%; border-radius: 8px;">
</p>

---
<!--
Citation: Claude (Anthropic, 2025) was used to help structure this README,
organize documentation sections, and refine technical descriptions.
All project details, features, and implementation specifics were provided
by the team and reflect the actual work completed.
-->

# Global High-Speed Rail Infrastructure Database  
### CS340 – Introduction to Databases   
### Project Group 90 – Michael Harris & Francisco Yinug  
🔗 **Live Demo:** https://globalhsrdatabase-production.up.railway.app/

---

## Overview

The **Global High-Speed Rail Infrastructure Database** is a full-stack web application designed to model the operational structure of major high-speed rail systems around the world. This comprehensive database system provides an administrative interface to manage countries, rail operators, rail lines, stations, construction projects, and the complex relationships between these entities.

### Purpose & Learning Objectives

The purpose of this project is to demonstrate core relational database principles taught in CS340, including:

- Designing a normalized schema following 3NF principles
- Using DDL to build tables and insert sample data  
- Implementing full CRUD operations through a server-side web application  
- Managing many-to-many relationships with intersection tables  
- Executing all **CREATE, UPDATE, DELETE** actions through **stored procedures**  
- Providing dynamic, user-friendly foreign-key selection  
- Ensuring referential integrity and preventing data anomalies  
- Creating a polished, professional user interface with enhanced UX features

The final submission includes a complete web interface with cyberpunk-inspired visual design, dynamic behaviors, comprehensive error handling, and robust database logic.

---

## Technologies Used

### **Backend**
- **Node.js** with **Express.js** - Server framework and routing
- **Express-Handlebars (HBS)** - Templating engine for dynamic HTML generation
- **MariaDB / MySQL** - Relational database management system
- **mysql2** - Database connection package with promise support
- Parameterized SQL queries and stored procedures for security

### **Frontend**
- **Handlebars templating** - Server-side rendering with reusable layouts
- **Custom HTML5/CSS3** - Semantic markup and modern styling
- **Vanilla JavaScript** - Dynamic form interactions and client-side validation
- **CSS Grid & Flexbox** - Responsive layout system
- Background video with ambient audio and playback controls

### **Deployment & Process Management**
- OSU ENGR servers (`classwork.engr.oregonstate.edu`)
- `forever` process manager for persistent application hosting

---

## Project Structure

```
project_dynamic/
│
├── app.js                     # Main Express application (routing, middleware, HBS engine)
├── package.json               # Node.js dependencies and scripts
│
├── /database/
│   ├── db-connector.js        # Database connection configuration
│   ├── DDL.sql                # Database schema definition & sample data
│   ├── DML.sql                # All SELECT queries used in the application
│   └── PL.sql                 # Stored procedures for C/U/D operations & Reset
│
├── /views/                    # Handlebars (HBS) templates
│   ├── layouts/
│   │   └── main.hbs           # Main layout wrapper with navigation
│   ├── index.hbs              # Homepage with project overview
│   ├── countries.hbs          # Countries management page
│   ├── operators.hbs          # Operators management page
│   ├── railLines.hbs          # Rail Lines management page
│   ├── stations.hbs           # Stations management page
│   ├── projects.hbs           # Projects management page
│   ├── lineStations.hbs       # Line-Station M:N relationship page
│   └── projectLines.hbs       # Project-Line M:N relationship page
│
└── /public/
    ├── styles.css             # Global stylesheet with cyberpunk theme
    ├── video/
    │   └── background.mp4     # Background video loop
    └── audio/
        └── background.mp3     # Ambient background audio
```

---

## Database Schema & Relationships

### **Main Entities**

1. **Countries** (`countryID`, `countryName`, `continent`, `populationMillions`)
   - Stores national profiles for countries with high-speed rail networks

2. **Operators** (`operatorID`, `operatorName`, `foundedYear`, `countryID`)
   - Organizations managing high-speed rail services
   - Foreign Key: `countryID` → Countries

3. **RailLines** (`lineID`, `lineName`, `maxSpeed`, `lengthKM`, `operatorID`)
   - Individual high-speed rail lines with technical specifications
   - Foreign Key: `operatorID` → Operators

4. **Stations** (`stationID`, `stationName`, `city`, `countryID`)
   - Major rail terminals and the cities they serve
   - Foreign Key: `countryID` → Countries

5. **Projects** (`projectID`, `projectName`, `status`, `startYear`, `endYear`)
   - Major construction and upgrade projects

### **Intersection (M:N) Tables**

1. **LineStations** (`lineID`, `stationID`, `stopOrder`)
   - Many-to-many relationship between RailLines and Stations
   - Includes `stopOrder` attribute to track station sequence on each line
   - Composite Primary Key: (`lineID`, `stationID`)

2. **ProjectLines** (`projectID`, `lineID`)
   - Many-to-many relationship between Projects and RailLines
   - Composite Primary Key: (`projectID`, `lineID`)

### **Key Relationships**
- Countries → Operators (1:M)
- Countries → Stations (1:M)
- Operators → RailLines (1:M)
- Projects ↔ RailLines (M:N via ProjectLines)
- RailLines ↔ Stations (M:N via LineStations)

### **Normalization**
All tables follow Third Normal Form (3NF) with:
- No repeating groups
- No partial dependencies
- No transitive dependencies
- Proper primary and foreign key constraints

---

## Stored Procedures (PL/SQL)

All **CREATE, UPDATE, and DELETE** operations are executed **exclusively** through MySQL stored procedures to ensure:
- Data integrity and consistency
- SQL injection prevention
- Centralized business logic
- Automatic cleanup of dependent records

### **Implemented Procedures:**

**Countries:**
- `sp_CreateCountry(name, continent, population)`
- `sp_UpdateCountry(id, name, continent, population)`
- `sp_DeleteCountry(id)`

**Operators:**
- `sp_CreateOperator(name, foundedYear, countryID)`
- `sp_UpdateOperator(id, name, foundedYear, countryID)`
- `sp_DeleteOperator(id)`

**RailLines:**
- `sp_CreateRailLine(name, maxSpeed, lengthKM, operatorID)`
- `sp_UpdateRailLine(id, name, maxSpeed, lengthKM, operatorID)`
- `sp_DeleteRailLine(id)`

**Stations:**
- `sp_CreateStation(name, city, countryID)`
- `sp_DeleteStation(id)`

**Projects:**
- `sp_CreateProject(name, status, startYear, endYear)`
- `sp_UpdateProject(id, name, status, startYear, endYear)`
- `sp_DeleteProject(id)`

**LineStations (M:N):**
- `sp_CreateLineStation(lineID, stationID, stopOrder)`
- `sp_DeleteLineStation(lineID, stationID)`

**ProjectLines (M:N):**
- `sp_CreateProjectLine(projectID, lineID)`
- `sp_UpdateProjectLine(oldProjectID, oldLineID, newProjectID, newLineID)`
- `sp_DeleteProjectLine(projectID, lineID)`

**Database Management:**
- `sp_ResetHSRDatabase()` - Restores database to original seeded state

### **Stored Procedure Benefits:**
- Duplicate checking before inserts
- Automatic cleanup of M:N mappings on deletion
- Strong referential integrity enforcement
- Parameterized queries preventing SQL injection
- Consistent error handling and validation

---

## Key Features & User Experience

### **CRUD Operations**
- **Full CRUD** on all major entities (Countries, Operators, RailLines, Projects)
- **Create & Delete** for Stations (no Update per design requirements)
- **M:N relationship management** with Create, Update, and Delete for ProjectLines
- **M:N relationship management** with Create and Delete for LineStations

### **Enhanced User Experience**
- **Success/Error Feedback** - Color-coded banners (green for success, red for errors)
- **Edit Buttons** - Quick-access buttons that auto-populate update forms
- **Smooth Scrolling** - Animated scrolling to forms when edit is clicked
- **Form Highlighting** - Visual flash animation when forms are populated
- **Dynamic Filtering** - LineStations dropdown shows only unmapped stations
- **Human-Readable Dropdowns** - Display names instead of numeric IDs
- **Referential Integrity Messages** - Clear error messages for constraint violations
- **Prepopulated Forms** - All update forms auto-fill from table row data
- **Valid Selection Only** - Delete forms show only existing valid relationships

### **Visual Design**
- Modern cyberpunk-inspired dark theme
- Neon accent colors (red-orange and yellow)
- Backdrop blur effects for depth
- Looping background video with controls
- Consistent table layouts and spacing
- Responsive forms and navigation
- Professional typography with Inter font family

---

## Installation & Setup

### **Prerequisites**
- Node.js (v14 or higher)
- MySQL/MariaDB database server
- npm (Node Package Manager)

### **Local Development Setup**

1. **Clone or extract the project files**

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure database connection:**
   Edit `/database/db-connector.js`:
   ```javascript
   export const db = mysql.createPool({
     host: 'classmysql.engr.oregonstate.edu',
     user: 'cs340_harrim22',
     password: 'YOUR_PASSWORD',
     database: 'cs340_harrim22',
     waitForConnections: true,
     connectionLimit: 10,
     queueLimit: 0
   }).promise();
   ```

4. **Set up the database:**
   ```sql
   -- Run in MySQL client
   source /path/to/DDL.sql;
   source /path/to/PL.sql;
   ```

5. **Start the server:**
   ```bash
   node app.js
   ```

6. **Access the application:**
   ```
   http://localhost:2181/
   ```

### **OSU ENGR Server Deployment**

1. **SSH into the server:**
   ```bash
   ssh yourONID@access.engr.oregonstate.edu
   ```

2. **Navigate to project directory:**
   ```bash
   cd ~/CS340/project_dynamic
   ```

3. **Install dependencies:**
   ```bash
   npm install
   ```

4. **Start with forever (required for deployment):**
   ```bash
   forever start app.js
   ```

5. **Check logs:**
   ```bash
   forever logs 0
   ```

6. **Stop the process:**
   ```bash
   forever stop 0
   ```

7. **Access your application:**
   ```
   http://classwork.engr.oregonstate.edu:2181/
   ```

---

## Usage Guide

### **Managing Countries**
1. Navigate to the **Countries** page
2. Use **Add Country** form to create new entries
3. Click **Edit** button to auto-populate the update form
4. Form scrolls and highlights for visual feedback
5. Delete countries (only if no dependent operators or stations exist)

### **Managing Operators**
1. Navigate to the **Operators** page
2. Select a country from dropdown when creating
3. Edit operator details including name, founding year, and country
4. Delete operators (only if no rail lines depend on them)

### **Managing Rail Lines**
1. Navigate to the **Rail Lines** page
2. Create lines with name, max speed, length, and operator
3. Update technical specifications as needed
4. Delete lines (only if not assigned to projects or stations)

### **Managing Stations**
1. Navigate to the **Stations** page
2. Add stations with name, city, and country
3. Delete stations (only if not assigned to any rail lines)
4. **Note:** Stations do not have Update functionality per design

### **Managing Projects**
1. Navigate to the **Projects** page
2. Create projects with name, status, start year, and optional end year
3. Update status as construction progresses
4. Delete completed or cancelled projects

### **Managing Line-Station Relationships**
1. Navigate to **Line-Station Mapping** page
2. Select a rail line from dropdown
3. **Dynamic filtering:** Only unmapped stations appear in station dropdown
4. Assign stations with stop order numbers
5. Delete mappings in the delete section
6. Delete form shows only existing line-station pairs

### **Managing Project-Line Relationships**
1. Navigate to **Project-Line Mapping** page
2. Create mappings to assign lines to projects
3. **Update mappings:** Select existing mapping, then choose new project/line
4. Delete mappings to remove associations
5. All forms show human-readable names with IDs

---

## API Routes

### **Main Pages**
- `GET /` - Homepage
- `GET /countries` - Countries management
- `GET /operators` - Operators management
- `GET /railLines` - Rail Lines management
- `GET /stations` - Stations management
- `GET /projects` - Projects management
- `GET /lineStations` - Line-Station mapping
- `GET /projectLines` - Project-Line mapping

### **Countries**
- `POST /countries/create` - Create new country
- `POST /countries/update` - Update existing country
- `POST /countries/delete` - Delete country

### **Operators**
- `POST /operators/create` - Create new operator
- `POST /operators/update` - Update existing operator
- `POST /operators/delete` - Delete operator

### **Rail Lines**
- `POST /railLines/create` - Create new rail line
- `POST /railLines/update` - Update existing rail line
- `POST /railLines/delete` - Delete rail line

### **Stations**
- `POST /stations/create` - Create new station
- `POST /stations/delete` - Delete station

### **Projects**
- `POST /projects/create` - Create new project
- `POST /projects/update` - Update existing project
- `POST /projects/delete` - Delete project

### **Line-Station Mapping**
- `POST /lineStations/create` - Create new line-station mapping
- `POST /lineStations/delete` - Delete line-station mapping

### **Project-Line Mapping**
- `POST /projectLines/create` - Create new project-line mapping
- `POST /projectLines/update` - Update existing project-line mapping
- `POST /projectLines/delete` - Delete project-line mapping

### **Database Management**
- `GET /reset-database` - Reset database to original seeded state

---

## Database Reset Instructions (For Graders)

To restore the database to its original seeded state for testing:

1. Click the **Reset Database** link in the navigation bar
2. Confirm the reset action
3. The stored procedure `sp_ResetHSRDatabase()` will:
   - Clear all tables in proper order (respecting foreign keys)
   - Reinsert the complete sample dataset
   - Ensure all foreign key relationships remain valid
   - Restore all M:N mappings

**Purpose:** This allows destructive operations (deletions, updates) to be tested repeatedly without permanently breaking the system or requiring manual database restoration.

---

## Citations & Academic Integrity

This project was authored by **Michael Harris** and **Francisco Yinug** for CS340 at Oregon State University.

Per OSU's Code Citation Policy and academic integrity guidelines:

### **AI Assistance Usage:**
- **ChatGPT (OpenAI, 2025)** was used for:
  - Debugging assistance and error troubleshooting
  - Clarifying Express.js and Handlebars syntax
  - Refining CSS organization and aesthetic suggestions
  - Improving code comments and documentation structure
  
- **Claude (Anthropic, 2025)** was used for:
  - Structuring this README documentation
  - Organizing technical descriptions
  - Refining CSS table layouts and responsive design
  - Debugging JavaScript form interactions

### **Original Work:**
All core functionality was created by the team, including:
- Complete database schema design and ERD
- All SQL queries and stored procedures
- Server routing logic and middleware
- Business logic and validation rules
- Form handling and user interaction flows
- Visual design concepts and theme implementation

### **Citation Blocks:**
Each source file includes a citation block at the top describing:
- The scope and nature of AI assistance
- Which portions were refined vs. generated
- The date of assistance

**No uncredited code was copied from external repositories or other students.**

---

## Known Limitations & Future Enhancements

### **Current Limitations:**
- Stations do not have Update operation (by design choice)
- Large datasets may benefit from pagination
- Background video may not autoplay on some browsers due to autoplay policies
- No user authentication or role-based access control

### **Potential Future Enhancements:**
- **Pagination** for tables with many records
- **Advanced Search & Filtering** capabilities across all entities
- **Data Visualization** - Charts showing rail network statistics, project timelines
- **Geographic Maps** - Visual representation of rail lines and stations
- **User Authentication** - Login system with role-based permissions
- **Export Functionality** - Generate CSV or PDF reports
- **Mobile Optimization** - Enhanced responsive design for mobile devices
- **Real-time Updates** - WebSocket integration for live data updates
- **Audit Logging** - Track all database changes with timestamps

---

## Contact Information

For questions regarding this project or grading access:

**Michael Harris**  
Email: harrim22@oregonstate.edu

**Francisco Yinug**  
Email: yinugf@oregonstate.edu

**Course:** CS340 - Introduction to Databases  
**Term:** Fall 2025  
**Institution:** Oregon State University

---

## License

This project was created for educational purposes as part of CS340 - Introduction to Databases at Oregon State University. All rights reserved by the authors.
