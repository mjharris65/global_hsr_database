import fs from "fs";
import mysql from "mysql2/promise";

async function main() {
  if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL is not set.");
  }

  // Enable multiStatements so your DDL/PL files can run.
  const pool = mysql.createPool({
    uri: process.env.DATABASE_URL,
    multipleStatements: true,
  });

  try {
    // Skip if already initialized (prevents re-running on every deploy)
    const [tables] = await pool.query("SHOW TABLES;");
    if (tables.length > 0) {
      console.log("Tables already exist — skipping init.");
      return;
    }

    console.log("Running DDL.sql...");
    const ddl = fs.readFileSync("./database/DDL.sql", "utf8");
    await pool.query(ddl);

    console.log("Running PL.sql...");
    const pl = fs.readFileSync("./database/PL.sql", "utf8");
    await pool.query(pl);

    console.log("✅ DB initialized.");
  } finally {
    await pool.end();
  }
}

main().catch((err) => {
  console.error("❌ DB init failed:", err);
  process.exit(1);
});
