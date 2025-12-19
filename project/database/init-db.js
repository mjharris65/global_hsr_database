import fs from "fs";
import mysql from "mysql2/promise";

async function runSqlFile(pool, path) {
  const sql = fs.readFileSync(path, "utf8");
  // Some SQL files have multiple statements; mysql2 can handle them if multiStatements is enabled.
  // But Railway DATABASE_URL won’t include that option, so we’ll execute as a single query
  // only if your file is compatible.
  await pool.query(sql);
}

async function main() {
  if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL is not set.");
  }

  const pool = mysql.createPool({
    uri: process.env.DATABASE_URL,
    multipleStatements: true, // important for running DDL/PL files
  });

  try {
    console.log("Initializing DB...");

    // Optional: skip if tables already exist
    const [rows] = await pool.query(`SHOW TABLES;`);
    if (rows.length > 0) {
      console.log("Tables already exist — skipping init.");
      process.exit(0);
    }

    await runSqlFile(pool, "./database/DDL.sql");
    await runSqlFile(pool, "./database/PL.sql");

    console.log("DB initialized successfully.");
    process.exit(0);
  } finally {
    await pool.end();
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
