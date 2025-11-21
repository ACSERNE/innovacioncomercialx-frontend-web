const fs = require('fs');
const file = './innovacioncomercialx-frontend-mobile/App.js';
if (fs.existsSync(file)) {
  const template = `
import React from 'react';
import { Text, View } from 'react-native';
export default function App() {
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Text>🚀 App lista para Expo!</Text>
    </View>
  );
}
`;
  fs.writeFileSync(file, template);
  console.log('✅ App.js corregido');
} else {
  console.log('⚠️ App.js no encontrado');
}
