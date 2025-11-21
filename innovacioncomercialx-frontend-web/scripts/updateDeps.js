import { execSync } from "child_process";

const projects = [
  "./backend",
  "./innovacioncomercialx-frontend-web",
  "./innovacioncomercialx-frontend-mobile"
];

projects.forEach(dir => {
  console.log(`🔹 Actualizando dependencias en ${dir}...`);
  try {
    execSync("npx npm-check-updates -u", { cwd: dir, stdio: "inherit" });
    execSync("npm install", { cwd: dir, stdio: "inherit" });
    console.log(`✅ Dependencias actualizadas en ${dir}`);
  } catch (err) {
    console.error(`❌ Error actualizando dependencias en ${dir}`, err);
  }
});
