# 📦 Frontend Mobile Cockpitizado

Visor exportado con Expo y federado visualmente para Chile, México y España. Incluye trazabilidad técnica, badges SVG por país y dashboard auditado.

---

## 🚀 Deploy multiplataforma

Puedes publicar el visor desde `web-build/` en cualquiera de estas plataformas:

| Plataforma       | Acción recomendada                                  |
|------------------|------------------------------------------------------|
| **GitHub Pages** | Subir carpeta `web-build/` a rama `gh-pages`         |
| **Netlify**      | Deploy directo desde `web-build/` como carpeta base  |
| **Railway**      | Usar imagen Docker generada con Nginx                |

---

## 🧭 Artefactos federados

| Archivo                  | Propósito                          |
|--------------------------|------------------------------------|
| `index.html`             | Entrada visual federada            |
| `visor-frontend.html`    | Visor cockpitizado con dashboard   |
| `dashboard-frontend.json`| Estado, timestamp y países         |
| `badge-cl.svg`           | Estado visual para Chile           |
| `badge-mx.svg`           | Estado visual para México          |
| `badge-es.svg`           | Estado visual para España          |

---

## 🔍 Validación remota

Ejecuta el script `validar-visor.sh` para verificar accesibilidad de los artefactos en producción:

```bash
chmod +x validar-visor.sh
./validar-visor.sh
