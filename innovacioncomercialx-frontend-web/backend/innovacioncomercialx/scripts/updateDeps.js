const { execSync } = require('child_process');

['./backend', './innovacioncomercialx-frontend-web', './innovacioncomercialx-frontend-mobile'].forEach(dir => {
  console.log(`🔹 Actualizando dependencias en ${dir}...`);
  execSync(`cd ${dir} && npx npm-check-updates -u && npm install --legacy-peer-deps`, { stdio: 'inherit' });
  console.log(`✅ Dependencias actualizadas en ${dir}`);
});
