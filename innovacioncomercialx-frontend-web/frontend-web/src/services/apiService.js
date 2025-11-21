async function main() {
import axios from 'axios'

const API_BASE = 'https://api.comercialx.cl' // Reemplaza con tu endpoint real

export const login = async (email, password) => {
  const res = await axios.post(\`\${API_BASE}/auth/login\`, { email, password })
  return res.data.token
}

export const getModules = async (token) => {
  const res = await axios.get(\`\${API_BASE}/modules\`, {
    headers: { Authorization: \`Bearer \${token}\` }
  })
  return res.data
}

export const registerSale = async (token, saleData) => {
  const res = await axios.post(\`\${API_BASE}/sales\`, saleData, {
    headers: { Authorization: \`Bearer \${token}\` }
  })
  return res.data
}
}
main()
