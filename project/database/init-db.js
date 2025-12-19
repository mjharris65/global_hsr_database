import fs from "fs";
import mysql from "mysql2/promise";

const pool = mysql.createPool(process.env.DATABASE_URL);

async function run() {
  const ddl = fs.readFileSync("./database/DDL.sql", "utf8");
  const pl  = fs.readFileSync("./database/PL.sql", "utf8");

  console.log("Running DDL...");
  await pool.query(ddl);

  console.log("Running PL...");
  await pool.query(pl);

  console.log("Database initialized.");
  process.exit(0);
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
