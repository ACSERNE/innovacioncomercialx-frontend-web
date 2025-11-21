const fs = require('fs');

const envFiles = [
  { file: './backend/.env', vars: ['POSTGRES_USER', 'POSTGRES_PASSWORD', 'POSTGRES_DB'] },
  { file: './innovacioncomercialx-frontend-web/.env', vars: ['REACT_APP_API_URL'] },
  { file: './innovacioncomercialx-frontend-mobile/.env', vars: ['API_URL'] }
];

envFiles.forEach(({ file, vars }) => {
  if (!fs.existsSync(file)) fs.writeFileSync(file, '');
  let content = fs.readFileSync(file, 'utf-8');
  vars.forEach(v => {
    if (!content.includes(v)) fs.appendFileSync(file, `${v}=\n`);
  });
  console.log(`✅ .env revisado: ${file}`);
});
