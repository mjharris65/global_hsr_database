
//Citation: No AI assistance used. Database credentials and configuration were
//implemented solely by the team. Credentials sanitized for submission.


import mysql from "mysql2/promise";
import "dotenv/config";

const DB_HOST = process.env.DB_HOST || "classmysql.engr.oregonstate.edu";
const DB_USER = process.env.DB_USER || "cs340_harrim22";
const DB_PASSWORD = process.env.DB_PASSWORD || "";     // leave empty if you want
const DB_NAME = process.env.DB_NAME || "cs340_harrim22";

export const db = mysql.createPool({
  host: DB_HOST,
  user: DB_USER,
  password: DB_PASSWORD,
  database: DB_NAME,
});



