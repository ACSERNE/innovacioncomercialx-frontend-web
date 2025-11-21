import pg from "pg";

const { Client } = pg;

async function checkDB() {
  const client = new Client({
    user: process.env.POSTGRES_USER || "postgres",
    password: process.env.POSTGRES_PASSWORD || "postgres",
    database: process.env.POSTGRES_DB || "postgres",
    host: "db",
    port: 5432
  });

  for (let i = 0; i < 30; i++) {
    try {
      await client.connect();
      console.log("✅ PostgreSQL está lista.");
      await client.end();
      return;
    } catch (e) {
      console.log("⏳ Esperando a que PostgreSQL esté lista...");
      await new Promise(r => setTimeout(r, 2000));
    }
  }
  console.error("❌ PostgreSQL no respondió a tiempo.");
  process.exit(1);
}

checkDB();
