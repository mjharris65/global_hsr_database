// Citation: ChatGPT (OpenAI, 2025) was used to help review routing structure,
// clarify Express/Handlebars integration, and verify SQL procedure usage.
// All final code was written and tested by the team.


// app.js (Project Dynamic)
import express from "express";
import { engine } from "express-handlebars";
import path from "path";
import { fileURLToPath } from "url";
import { db } from "./database/db-connector.js";
import "dotenv/config";
import Handlebars from "handlebars";



const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Auto-initialize database if tables don't exist (for Railway restarts)
async function ensureTablesExist() {
  try {
    const [tables] = await db.query("SHOW TABLES LIKE 'Countries'");
    if (tables.length === 0) {
      console.log('Tables missing - initializing database...');
      await db.query('CALL sp_ResetHSRDatabase()');
      console.log('Database initialized successfully');
    }
  } catch (error) {
    console.error('Database initialization error:', error);
  }
}

// Run on startup
await ensureTablesExist();

// Now your existing routes...


// -------------------------------
// Handlebars
// -------------------------------
app.engine(
  "hbs",
  engine({
    extname: ".hbs",
    helpers: {
      eq: (a, b) => a === b,
      json: (context) => JSON.stringify(context),
    },
  })
);

app.set("view engine", "hbs");
app.set("views", path.join(__dirname, "views"));


// -------------------------------
// Middleware
// -------------------------------
app.use(express.static(path.join(__dirname, "public")));
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

function renderPartial(req, res, template, context = {}) {
  if (req.headers["x-partial"]) {
    res.render(template, { ...context, layout: false });
  } else {
    res.render(template, {
      ...context,
      layout: "main",
      title: context.title || "Global HSR",
    });
  }
}

// -------------------------------
// Home
// -------------------------------
app.get("/", (req, res) =>
  renderPartial(req, res, "index", {
    title: "Global High-Speed Rail Infrastructure Database",
  })
);

// ====================================================================
// COUNTRIES — FULL CRUD
// ====================================================================
app.get("/countries", async (req, res) => {
  try {
    const [countries] = await db.query(`
      SELECT countryID, countryName, continent, populationMillions
      FROM Countries ORDER BY countryID;
    `);

    let editCountry = null;

    if (req.query.edit) {
      const [result] = await db.query(
        "SELECT * FROM Countries WHERE countryID = ?",
        [req.query.edit]
      );
      editCountry = result[0] || null;
    }

    renderPartial(req, res, "countries", {
      title: "Countries",
      countries,
      editCountry,
      error: req.query.error || null,
      success: req.query.success || null
    });

  } catch (err) {
    console.error("Error loading countries:", err);
    res.status(500).send("Error loading countries");
  }
});



app.post("/countries/create", async (req, res) => {
  const { countryName, continent, populationMillions } = req.body;

  try {
    await db.query("CALL sp_CreateCountry(?, ?, ?)", [
      countryName,
      continent,
      populationMillions,
    ]);

    res.redirect("/countries?success=create");
  } catch (error) {
    console.error("Country CREATE Error:", error);
    res.redirect("/countries?error=duplicate-create");
  }
});


app.post("/countries/update", async (req, res) => {
  const {
    update_countryID,
    update_countryName,
    update_continent,
    update_populationMillions
  } = req.body;

  try {
    await db.query("CALL sp_UpdateCountry(?, ?, ?, ?)", [
      update_countryID,
      update_countryName,
      update_continent,
      update_populationMillions,
    ]);

    res.redirect("/countries?success=update");
  } catch (error) {
    console.error("Country UPDATE Error:", error);
    res.redirect("/countries?error=duplicate-update");
  }
});


app.post("/countries/delete", async (req, res) => {
  const { delete_countryID } = req.body;
  
  try {
    await db.query("CALL sp_DeleteCountry(?);", [delete_countryID]);
    res.redirect("/countries?success=delete");
  } catch (error) {
    console.error("Country DELETE Error:", error);
    res.redirect("/countries?error=delete-failed");
  }
});

// ====================================================================
// OPERATORS — FULL CRUD
// ====================================================================
app.get("/operators", async (req, res) => {
  const [operators] = await db.query(`
    SELECT o.operatorID, o.operatorName, o.foundedYear,
           o.countryID, c.countryName
    FROM Operators o
    JOIN Countries c ON o.countryID = c.countryID
    ORDER BY o.operatorID;
  `);

  const [countries] = await db.query(`
    SELECT countryID, countryName FROM Countries ORDER BY countryName;
  `);

  renderPartial(req, res, "operators", {
    title: "Operators",
    operators,
    countries,
    error: req.query.error || null,
    success: req.query.success || null
  });
});


app.post("/operators/create", async (req, res) => {
  const { operatorName, foundedYear, countryID } = req.body;

  try {
    await db.query("CALL sp_CreateOperator(?, ?, ?)", [
      operatorName,
      foundedYear,
      countryID,
    ]);

    res.redirect("/operators?success=create");
  } catch (error) {
    console.error("Operator CREATE Error:", error);
    res.redirect("/operators?error=create-failed");
  }
});


app.post("/operators/update", async (req, res) => {
  console.log("UPDATE OPERATOR BODY:", req.body);

  const {
    update_operatorID,
    update_operatorName,
    update_foundedYear,
    update_countryID
  } = req.body;

  try {
    await db.query("CALL sp_UpdateOperator(?, ?, ?, ?)", [
      update_operatorID,
      update_operatorName,
      update_foundedYear,
      update_countryID
    ]);

    res.redirect("/operators?success=update");
  } catch (error) {
    console.error("Operator UPDATE Error:", error);
    res.redirect("/operators?error=update-failed");
  }
});



app.post("/operators/delete", async (req, res) => {
  const { delete_operatorID } = req.body;

  try {
    await db.query("CALL sp_DeleteOperator(?)", [
      delete_operatorID
    ]);

    res.redirect("/operators?success=delete");
  } catch (error) {
    console.error("Operator DELETE Error:", error);
    res.redirect("/operators?error=delete-failed");
  }
});


// ====================================================================
// RAIL LINES — FULL CRUD
// ====================================================================
app.get("/railLines", async (req, res) => {
  const [railLines] = await db.query(`
    SELECT r.lineID, r.lineName, r.maxSpeed, r.lengthKM, 
           r.operatorID, o.operatorName
    FROM RailLines r
    JOIN Operators o ON r.operatorID = o.operatorID
    ORDER BY r.lineID;
  `);

  const [operators] = await db.query(`
    SELECT operatorID, operatorName FROM Operators ORDER BY operatorName;
  `);

  renderPartial(req, res, "railLines", {
    railLines,
    operators,
    title: "Rail Lines",
    error: req.query.error || null,
    success: req.query.success || null
  });
});

app.post("/railLines/create", async (req, res) => {
  const { lineName, maxSpeed, lengthKM, operatorID } = req.body;

  try {
    await db.query("CALL sp_CreateRailLine(?, ?, ?, ?)", [
      lineName,
      maxSpeed,
      lengthKM,
      operatorID
    ]);

    res.redirect("/railLines?success=create");
  } catch (error) {
    console.error("RailLine CREATE Error:", error);
    res.redirect("/railLines?error=create-failed");
  }
});


app.post("/railLines/update", async (req, res) => {
  const {
    update_lineID,
    update_lineName,
    update_maxSpeed,
    update_lengthKM,
    update_operatorID
  } = req.body;

  try {
    await db.query("CALL sp_UpdateRailLine(?, ?, ?, ?, ?)", [
      update_lineID,
      update_lineName,
      update_maxSpeed,
      update_lengthKM,
      update_operatorID
    ]);

    res.redirect("/railLines?success=update");
  } catch (error) {
    console.error("RailLine UPDATE Error:", error);
    res.redirect("/railLines?error=update-failed");
  }
});


app.post("/railLines/delete", async (req, res) => {
  const { delete_lineID } = req.body;
  
  try {
    await db.query("CALL sp_DeleteRailLine(?);", [delete_lineID]);
    res.redirect("/railLines?success=delete");
  } catch (error) {
    console.error("RailLine DELETE Error:", error);
    res.redirect("/railLines?error=delete-failed");
  }
});

// ====================================================================
// STATIONS — CREATE + DELETE (no update in design)
// ====================================================================
app.get("/stations", async (req, res) => {
  const [stations] = await db.query(`
    SELECT s.stationID, s.stationName, s.city, 
           s.countryID, c.countryName
    FROM Stations s
    JOIN Countries c ON s.countryID = c.countryID
    ORDER BY s.stationID;
  `);

  const [countries] = await db.query(`
    SELECT countryID, countryName FROM Countries ORDER BY countryName;
  `);

  renderPartial(req, res, "stations", {
    stations,
    countries,
    title: "Stations",
    error: req.query.error || null,
    success: req.query.success || null
  });
});

app.post("/stations/create", async (req, res) => {
  const { stationName, city, countryID } = req.body;

  try {
    await db.query("CALL sp_CreateStation(?, ?, ?)", [
      stationName,
      city,
      countryID
    ]);

    res.redirect("/stations?success=create");
  } catch (error) {
    console.error("Station CREATE Error:", error);
    res.redirect("/stations?error=create-failed");
  }
});


app.post("/stations/delete", async (req, res) => {
  const { delete_stationID } = req.body;
  
  try {
    await db.query("CALL sp_DeleteStation(?);", [delete_stationID]);
    res.redirect("/stations?success=delete");
  } catch (error) {
    console.error("Station DELETE Error:", error);
    res.redirect("/stations?error=delete-failed");
  }
});

// ====================================================================
// PROJECTS — FULL CRUD
// ====================================================================
app.get("/projects", async (req, res) => {
  const [projects] = await db.query(`
    SELECT projectID, projectName, status, startYear, endYear
    FROM Projects ORDER BY projectID;
  `);

  renderPartial(req, res, "projects", {
    title: "Projects",
    projects,
    error: req.query.error || null,
    success: req.query.success || null
  });
});

app.post("/projects/create", async (req, res) => {
  const { projectName, status, startYear, endYear } = req.body;

  try {
    await db.query("CALL sp_CreateProject(?, ?, ?, ?)", [
      projectName,
      status,
      startYear,
      endYear || null
    ]);

    res.redirect("/projects?success=create");
  } catch (error) {
    console.error("Project CREATE Error:", error);
    res.redirect("/projects?error=create-failed");
  }
});


app.post("/projects/update", async (req, res) => {
  const {
    update_projectID,
    update_projectName,
    update_status,
    update_startYear,
    update_endYear
  } = req.body;

  try {
    await db.query("CALL sp_UpdateProject(?, ?, ?, ?, ?)", [
      update_projectID,
      update_projectName,
      update_status,
      update_startYear,
      update_endYear || null
    ]);

    res.redirect("/projects?success=update");
  } catch (error) {
    console.error("Project UPDATE Error:", error);
    res.redirect("/projects?error=update-failed");
  }
});


app.post("/projects/delete", async (req, res) => {
  const { delete_projectID } = req.body;
  
  try {
    await db.query("CALL sp_DeleteProject(?);", [delete_projectID]);
    res.redirect("/projects?success=delete");
  } catch (error) {
    console.error("Project DELETE Error:", error);
    res.redirect("/projects?error=delete-failed");
  }
});

// ====================================================================
// PROJECT–LINE (M:N)
// ====================================================================
app.get("/projectLines", async (req, res) => {
  const [projectLines] = await db.query(`
    SELECT pl.projectID, p.projectName,
           pl.lineID, r.lineName
    FROM ProjectLines pl
    JOIN Projects p ON pl.projectID = p.projectID
    JOIN RailLines r ON pl.lineID = r.lineID
    ORDER BY pl.projectID, pl.lineID;
  `);

  const [projects] = await db.query(`
    SELECT projectID, projectName FROM Projects ORDER BY projectName;
  `);

  const [railLines] = await db.query(`
    SELECT lineID, lineName FROM RailLines ORDER BY lineName;
  `);

  renderPartial(req, res, "projectLines", {
    title: "Project–Line Mapping",
    projectLines,
    projects,
    railLines,
    error: req.query.error || null,
    success: req.query.success || null
  });
});

// CREATE
app.post("/projectLines/create", async (req, res) => {
  const { projectID, lineID } = req.body;

  try {
    await db.query("CALL sp_CreateProjectLine(?, ?);", [projectID, lineID]);
    res.redirect("/projectLines?success=create");
  } catch (error) {
    console.error("ProjectLines CREATE Error:", error);
    res.redirect("/projectLines?error=duplicate");
  }
});


// UPDATE
app.post("/projectLines/update", async (req, res) => {
  const { currentMapping, new_projectID, new_lineID } = req.body;

  const [oldProjectID, oldLineID] = currentMapping.split("-");

  try {
    await db.query("CALL sp_UpdateProjectLine(?, ?, ?, ?);", [
      oldProjectID,
      oldLineID,
      new_projectID,
      new_lineID,
    ]);
    res.redirect("/projectLines?success=update");
  } catch (error) {
    console.error("ProjectLines UPDATE Error:", error);
    res.redirect("/projectLines?error=update-duplicate");
  }
});


// DELETE
app.post("/projectLines/delete", async (req, res) => {
  const { lineID_projectID_pair } = req.body;

  const [projectID, lineID] = lineID_projectID_pair.split("-");

  try {
    await db.query("CALL sp_DeleteProjectLine(?, ?);", [projectID, lineID]);
    res.redirect("/projectLines?success=delete");
  } catch (error) {
    console.error("ProjectLines DELETE Error:", error);
    res.redirect("/projectLines?error=delete-failed");
  }
});

// ====================================================================
// LINE–STATION (M:N)
// ====================================================================
app.get("/lineStations", async (req, res) => {
  // For CREATE dropdowns
  const [railLines] = await db.query(`
    SELECT lineID, lineName 
    FROM RailLines 
    ORDER BY lineName;
  `);

  const [stations] = await db.query(`
    SELECT stationID, stationName 
    FROM Stations 
    ORDER BY stationName;
  `);

  // Fetch existing mappings
  const [rawMappings] = await db.query(`
    SELECT 
      ls.lineID,
      rl.lineName,
      ls.stationID,
      s.stationName,
      ls.stopOrder
    FROM LineStations ls
    JOIN RailLines rl ON rl.lineID = ls.lineID
    JOIN Stations s   ON s.stationID = ls.stationID
    ORDER BY rl.lineName, s.stationName;
  `);

  // Group stations by lineID for dynamic filtering
  const mappingsByLine = {};
  rawMappings.forEach(m => {
    if (!mappingsByLine[m.lineID]) mappingsByLine[m.lineID] = [];
    mappingsByLine[m.lineID].push({
      stationID: m.stationID,
      stationName: m.stationName
    });
  });

  renderPartial(req, res, "lineStations", {
    railLines,
    stations,
    lineStations: rawMappings,
    lineStationMappings: rawMappings,
    mappingsByLine,
    title: "Line–Station Mapping",
    error: req.query.error || null,
    success: req.query.success || null
  });
});

// CREATE
app.post("/lineStations/create", async (req, res) => {
  const { lineID, stationID, stopOrder } = req.body;

  try {
    await db.query("CALL sp_CreateLineStation(?, ?, ?);", [
      lineID,
      stationID,
      stopOrder || null,
    ]);

    res.redirect("/lineStations?success=create");
  } catch (error) {
    console.error("LineStations CREATE Error:", error);
    res.redirect("/lineStations?error=duplicate");
  }
});

// DELETE
app.post("/lineStations/delete", async (req, res) => {
  try {
    // Value looks like: "3,12"
    const [lineID, stationID] = req.body.mapping.split(",");

    await db.query(`CALL sp_DeleteLineStation(?, ?)`, [
      lineID,
      stationID
    ]);

    res.redirect("/lineStations?success=delete");

  } catch (err) {
    console.error("Delete LineStation Mapping error:", err);
    res.redirect("/lineStations?error=delete-failed");
  }
});




// ====================================================================
// RESET DATABASE
// ====================================================================
app.get("/reset-database", async (req, res) => {
  await db.query("CALL sp_ResetHSRDatabase();");
  res.redirect("/");
});


import fs from "fs";
import mysql from "mysql2/promise";

app.get("/__init-db", async (req, res) => {
  // Simple guard so only YOU can run it
  if (req.query.key !== process.env.INIT_KEY) {
    return res.status(403).send("Forbidden");
  }

  try {
    const pool = mysql.createPool(process.env.DATABASE_URL);

    const ddl = fs.readFileSync("./database/DDL.sql", "utf8");
    const pl  = fs.readFileSync("./database/PL.sql", "utf8");

    await pool.query(ddl);
    await pool.query(pl);

    res.send("✅ Database initialized successfully.");
  } catch (err) {
    console.error(err);
    res.status(500).send(String(err));
  }
});

// ====================================================================
// Start Server
// ====================================================================
app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});


