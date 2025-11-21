import React, { useState } from 'react'

const Selector = ({ onSelect }) => {
  const [selected, setSelected] = useState(null)

  const opciones = {
    physical: '🏪 Tienda Física',
    online: '🌐 Tienda en Línea',
    hybrid: '🧩 Física + En Línea'
  }

  const handleSelect = (key) => {
    setSelected(key)
    onSelect(key)
  }

  return (
    <div style={{ fontFamily: 'monospace', padding: '2rem' }}>
      <h2>Selecciona tu modalidad ComercialX</h2>
      {Object.entries(opciones).map(([key, label]) => (
        <button
          key={key}
          onClick={() => handleSelect(key)}
          style={{
            margin: '0.5rem',
            padding: '1rem',
            backgroundColor: selected === key ? '#222' : '#eee',
            color: selected === key ? '#fff' : '#000',
            border: '1px solid #ccc',
            cursor: 'pointer'
          }}
        >
          {label}
        </button>
      ))}
      {selected && <p>✅ Modalidad seleccionada: <strong>{opciones[selected]}</strong></p>}
    </div>
  )
}

export default Selector
