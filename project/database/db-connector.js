
//Citation: No AI assistance used. Database credentials and configuration were
//implemented solely by the team. Credentials sanitized for submission.

import mysql from "mysql2/promise";
import "dotenv/config";

// Prefer a single DATABASE_URL (Railway), fall back to individual DB_* vars (local/OSU).
const connectionOptions = process.env.DATABASE_URL
  ? process.env.DATABASE_URL
  : {
      host: process.env.DB_HOST || "classmysql.engr.oregonstate.edu",
      user: process.env.DB_USER || "cs340_harrim22",
      password: process.env.DB_PASSWORD || "",
      database: process.env.DB_NAME || "cs340_harrim22",
      port: Number(process.env.DB_PORT || 3306),
    };

export const db = mysql.createPool(connectionOptions);




