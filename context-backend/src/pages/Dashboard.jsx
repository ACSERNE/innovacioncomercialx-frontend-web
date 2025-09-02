import React from 'react'
import { getModulesByMode } from '../utils/loader'

const Dashboard = ({ mode }) => {
  const modules = getModulesByMode(mode)

  return (
    <div style={{ fontFamily: 'monospace', padding: '2rem' }}>
      <h2>📊 Dashboard ComercialX - Modalidad: {mode.toUpperCase()}</h2>
      <ul>
        {modules.map((mod, index) => (
          <li key={index}>✅ Módulo activo: <strong>{mod}</strong></li>
        ))}
      </ul>
      {modules.length === 0 && <p>⚠️ No hay módulos activos para esta modalidad.</p>}
    </div>
  )
}

export default Dashboard
