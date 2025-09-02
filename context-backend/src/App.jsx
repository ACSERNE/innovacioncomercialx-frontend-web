import React, { useState } from 'react'
import Selector from './components/Selector'
import Dashboard from './pages/Dashboard'

const App = () => {
  const [mode, setMode] = useState(null)

  return (
    <div>
      {!mode ? (
        <Selector onSelect={setMode} />
      ) : (
        <Dashboard mode={mode} />
      )}
    </div>
  )
}

export default App
