import React, { useEffect, useState } from 'react';
import axios from 'axios';

const AlertasPage = () => {
  const [stockBajo, setStockBajo] = useState([]);
  const [proximosVencer, setProximosVencer] = useState([]);

  const fetchAlertas = async () => {
    try {
      const [resStock, resVencimiento] = await Promise.all([
        axios.get('/api/alertas/stock-bajo'),
        axios.get('/api/alertas/proximos-vencer')
      ]);
      setStockBajo(resStock.data);
      setProximosVencer(resVencimiento.data);
    } catch (error) {
      console.error('Error al cargar alertas:', error);
    }
  };

  const exportar = async (tipo) => {
    try {
      const response = await axios.get(`/api/alertas/exportar?tipo=${tipo}`, {
        responseType: 'blob'
      });

      const blob = new Blob([response.data]);
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `alertas.${tipo === 'pdf' ? 'pdf' : 'xlsx'}`);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    } catch (error) {
      console.error('Error al exportar:', error);
    }
  };

  useEffect(() => {
    fetchAlertas();
  }, []);

  return (
    <div>
      <h2>📦 Productos con Stock Bajo</h2>
      <ul>
        {stockBajo.map(p => (
          <li key={p.id}>{p.nombre} - Stock: {p.stock}</li>
        ))}
      </ul>

      <h2>⏳ Productos Próximos a Vencer</h2>
      <ul>
        {proximosVencer.map(p => (
          <li key={p.id}>{p.nombre} - Vence: {new Date(p.fecha_vencimiento).toLocaleDateString()}</li>
        ))}
      </ul>

      <button onClick={() => exportar('pdf')}>📄 Descargar PDF</button>
      <button onClick={() => exportar('excel')}>📊 Descargar Excel</button>
    </div>
  );
};

export default AlertasPage;
