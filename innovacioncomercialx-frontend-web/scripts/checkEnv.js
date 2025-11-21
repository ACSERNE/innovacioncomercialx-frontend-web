import fs from "fs";
import path from "path";

const projects = [
  { name: "backend", file: "./backend/.env", vars: ["DB_NAME", "DB_PASSWORD"] },
  { name: "frontend-web", file: "./innovacioncomercialx-frontend-web/.env", vars: ["REACT_APP_API_URL"] },
  { name: "frontend-mobile", file: "./innovacioncomercialx-frontend-mobile/.env", vars: ["API_URL"] },
];

projects.forEach(proj => {
  if (!fs.existsSync(proj.file)) {
    console.warn(`⚠️  ${proj.file} no existe, creando...`);
    fs.writeFileSync(proj.file, "");
  }
  let envContent = fs.readFileSync(proj.file, "utf8");
  proj.vars.forEach(v => {
    if (!envContent.includes(v)) {
      console.warn(`⚠️  Variable ${v} faltante en ${proj.file}, agregando...`);
      envContent += `\n${v}=\n`;
    }
  });
  fs.writeFileSync(proj.file, envContent.trim() + "\n");
  console.log(`✅ .env revisado: ${proj.file}`);
});
