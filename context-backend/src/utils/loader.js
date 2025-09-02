import config from '../../config.json'

export const getModulesByMode = (mode) => {
  const modalidad = config.modalidades[mode]
  if (!modalidad || !modalidad.enabled) {
    console.warn(\`Modalidad "\${mode}" no disponible\`)
    return []
  }
  return modalidad.modules
}
