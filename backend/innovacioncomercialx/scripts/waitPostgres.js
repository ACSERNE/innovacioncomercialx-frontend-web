const { execSync } = require('child_process');

console.log('⏳ Esperando a que PostgreSQL esté lista...');
let ready = false;
while (!ready) {
  try {
    execSync('docker exec innovacioncomercialx-db-1 pg_isready -U ');
    ready = true;
  } catch (err) {
    process.stdout.write('.');
    require('child_process').execSync('sleep 2');
  }
}
console.log('\n✅ PostgreSQL lista');
