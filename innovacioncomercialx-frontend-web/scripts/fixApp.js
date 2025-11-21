import fs from "fs";

const appPath = "./innovacioncomercialx-frontend-mobile/App.js";

if (!fs.existsSync(appPath)) {
  console.error("❌ No existe App.js en frontend-mobile");
  process.exit(1);
}

let content = fs.readFileSync(appPath, "utf8");

if (!content.includes("export default function App()")) {
  content = `
import { Text, View } from 'react-native';

export default function App() {
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Text>🚀 Expo funcionando correctamente</Text>
    </View>
  );
}
`.trim();
  fs.writeFileSync(appPath, content);
  console.log("✅ App.js corregido para Expo");
} else {
  console.log("✅ App.js ya estaba correcto");
}
